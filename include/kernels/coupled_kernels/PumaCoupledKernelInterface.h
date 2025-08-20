#pragma once

// MOOSE includes
#include "MathUtils.h"
#include "MooseArray.h"
#include "StabilizationUtils.h"
#include "InputParameters.h"
#include "RankTwoTensor.h"
#include "FEProblemBase.h"

/**
 * Interface class to provide common input parameters, members, and methods for the Puma Coupled.
 */
template <class T, class G>
class PumaCoupledKernelInterface : public T, G
{
public:
  static InputParameters validParams();

  PumaCoupledKernelInterface(const InputParameters & parameters);

protected:
  virtual void precalculateOffDiagJacobian(unsigned int component) override;
  virtual void precalculateJacobianDisplacement(unsigned int component);
  virtual RankTwoTensor gradTrial(unsigned int component);

  const MaterialProperty<Real> & _M;

  const bool _stabilize_strain;

  // temperature
  // const VariableValue * _T; //* instead of & since this variable is optional
  unsigned int _T_id;
  const VariablePhiValue * _T_phi;
  const MaterialProperty<Real> * _dMdT;

  // pressure
  // const VariableValue * _P; //* instead of & since this variable is optional
  unsigned int _P_id;
  const VariablePhiValue * _P_phi;
  const MaterialProperty<Real> * _dMdP;

  // fluid fraction
  // const VariableValue * _vf; //* instead of & since this variable is optional
  unsigned int _vf_id;
  const VariablePhiValue * _vf_phi;
  const MaterialProperty<Real> * _dMdvf;

  // solid mechanics
  const MaterialProperty<RankTwoTensor> * _F_ust;
  const MaterialProperty<RankTwoTensor> * _F_avg;
  unsigned int _ndisp;
  std::vector<unsigned int> _disp_id;
  std::vector<const VariablePhiValue *> _disp_phi;
  std::vector<const VariablePhiGradient *> _disp_grad_phi;
  const MaterialProperty<RankTwoTensor> * _dMdF;

  std::vector<std::vector<RankTwoTensor>> _avg_grad_trial;

private:
  /// The unstabilized trial function gradient
  virtual RankTwoTensor gradTrialUnstabilized(unsigned int component);

  /// The stabilized trial function gradient
  virtual RankTwoTensor gradTrialStabilized(unsigned int component);
};

template <class T, class G>
InputParameters
PumaCoupledKernelInterface<T, G>::validParams()
{
  InputParameters params = T::validParams();

  params.addCoupledVar("temperature", "The temperature");
  params.addCoupledVar("pressure", "The pressure");
  params.addCoupledVar("fluid_fraction", "Volume fraction of the product");
  params.addCoupledVar("displacements", "The displacements");

  params.addRequiredParam<MaterialPropertyName>(
      "material_prop", "Material constant multiply by the time derivative");

  params.addParam<MaterialPropertyName>("material_temperature_derivative",
                                        "Derivative of the material_prop w.r.t. the temperature");
  params.addParam<MaterialPropertyName>("material_pressure_derivative",
                                        "Derivative of the material_prop w.r.t. the pressure");
  params.addParam<MaterialPropertyName>(
      "material_fluid_fraction_derivative",
      "Derivative of the material_prop w.r.t. the fluid fraction");
  params.addParam<MaterialPropertyName>(
      "material_deformation_gradient_derivative",
      "Derivative of the material_prop w.r.t. the deformation gradient");

  params.addParam<bool>("stabilize_strain", false, "Average the volumetric strains");

  return params;
}

template <class T, class G>
PumaCoupledKernelInterface<T, G>::PumaCoupledKernelInterface(const InputParameters & parameters)
  : T(parameters),
    _M(this->template getMaterialProperty<Real>("material_prop")),
    _stabilize_strain(this->template getParam<bool>("stabilize_strain"))
{
  if (this->isCoupled("temperature"))
  {
    if (!this->isParamValid("material_temperature_derivative"))
      this->paramError(
          "material_temperature_derivative",
          "If temperature is coupled, material_temperature_derivative must be provided.");
    // _T = &this->coupledValue("temperature");
    _T_id = this->coupled("temperature");
    _T_phi = &this->getVar("temperature", 0)->phi();
    _dMdT = &this->template getMaterialProperty<Real>("material_temperature_derivative");
  }

  if (this->isCoupled("pressure"))
  {
    if (!this->isParamValid("material_pressure_derivative"))
      this->paramError("material_pressure_derivative",
                       "If pressure is coupled, material_pressure_derivative must be provided.");
    _P_id = this->coupled("pressure");
    _P_phi = &this->getVar("pressure", 0)->phi();
    _dMdP = &this->template getMaterialProperty<Real>("material_pressure_derivative");
  }

  if (this->isCoupled("fluid_fraction"))
  {
    if (!this->isParamValid("material_fluid_fraction_derivative"))
      this->paramError(
          "material_fluid_fraction_derivative",
          "If fluid_fraction is coupled, material_fluid_fraction_derivative must be provided.");
    _vf_id = this->coupled("fluid_fraction");
    _vf_phi = &this->getVar("fluid_fraction", 0)->phi();
    _dMdvf = &this->template getMaterialProperty<Real>("material_fluid_fraction_derivative");
  }

  if (this->isCoupled("displacements"))
  {
    _ndisp = this->coupledComponents("displacements");
    if (!this->isParamValid("material_deformation_gradient_derivative"))
      this->paramError("material_deformation_gradient_derivative",
                       "If displacements are coupled, material_deformation_gradient_derivative "
                       "must be provided.");

    _avg_grad_trial.resize(_ndisp);
    _F_ust = &this->template getMaterialPropertyByName<RankTwoTensor>(
        "unstabilized_deformation_gradient");
    _F_avg =
        &this->template getMaterialPropertyByName<RankTwoTensor>("average_deformation_gradient");

    const std::vector<VariableName> & _disp_name =
        this->template getParam<std::vector<VariableName>>("displacements");

    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
    {
      if (this->coupled("displacements", k) == this->variable().number())
        this->paramError("variable", "Variable cannot be displacement.");
      _disp_id.push_back(this->coupled("displacements", k));
      _disp_phi.push_back(&this->getVar("displacements", k)->phi());
      _disp_grad_phi.push_back(&this->getVar("displacements", k)->gradPhi());
    }

    _dMdF = &this->template getMaterialProperty<RankTwoTensor>(
        "material_deformation_gradient_derivative");
  }
}

template <class T, class G>
void
PumaCoupledKernelInterface<T, G>::precalculateOffDiagJacobian(unsigned int jvar)
{
  if (!_stabilize_strain)
    return;

  for (auto beta : make_range(_ndisp))
    if (jvar == _disp_id[beta])
    {
      this->_fe_problem.prepareShapes(jvar, this->_tid);
      _avg_grad_trial[beta].resize(this->_phi.size());
      precalculateJacobianDisplacement(beta);
    }
}

template <class T, class G>
void
PumaCoupledKernelInterface<T, G>::precalculateJacobianDisplacement(unsigned int component)
{
  for (auto j : make_range(this->_phi.size()))
    _avg_grad_trial[component][j] = StabilizationUtils::elementAverage(
        [this, component, j](unsigned int qp)
        {
          return G::gradOp(component,
                           (*this->_disp_grad_phi[component])[j][qp],
                           (*this->_disp_phi[component])[j][qp],
                           this->_q_point[qp]);
        },
        this->_JxW,
        this->_coord);
}

template <class T, class G>
RankTwoTensor
PumaCoupledKernelInterface<T, G>::gradTrial(unsigned int component)
{
  return _stabilize_strain ? gradTrialStabilized(component) : gradTrialUnstabilized(component);
}

template <class T, class G>
RankTwoTensor
PumaCoupledKernelInterface<T, G>::gradTrialUnstabilized(unsigned int component)
{
  return G::gradOp(component,
                   (*this->_disp_grad_phi[component])[this->_j][this->_qp],
                   (*this->_disp_phi[component])[this->_j][this->_qp],
                   this->_q_point[this->_qp]);
}

template <class T, class G>
RankTwoTensor
PumaCoupledKernelInterface<T, G>::gradTrialStabilized(unsigned int component)
{
  const auto Gb = G::gradOp(component,
                            (*this->_disp_grad_phi[component])[this->_j][this->_qp],
                            (*this->_disp_phi[component])[this->_j][this->_qp],
                            this->_q_point[this->_qp]);
  const auto Ga = _avg_grad_trial[component][this->_j];

  const Real dratio = std::pow((*_F_avg)[this->_qp].det() / (*_F_ust)[this->_qp].det(), 1.0 / 3.0);
  const Real fact = ((*_F_avg)[this->_qp].inverse().transpose().doubleContraction(Ga) -
                     (*_F_ust)[this->_qp].inverse().transpose().doubleContraction(Gb)) /
                    3.0;
  return dratio * (Gb + fact * (*_F_ust)[this->_qp]);
}
