//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PumaCoupledTimeDerivative.h"

// MOOSE includes
#include "Assembly.h"
#include "MooseVariableFE.h"
#include "RankTwoTensor.h"
#include "StabilizationUtils.h"
#include "FEProblem.h"

#include "libmesh/quadrature.h"

registerMooseObject("MooseApp", PumaCoupledTimeDerivative);

InputParameters
PumaCoupledTimeDerivative::validParams()
{
  InputParameters params = TimeKernel::validParams();
  params.addClassDescription(
      "Time derivative with a material constant for different coupled variables.");

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

PumaCoupledTimeDerivative::PumaCoupledTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
    _M(getMaterialProperty<Real>("material_prop")),
    _stabilize_strain(getParam<bool>("stabilize_strain"))
{
  if (isCoupled("temperature"))
  {
    if (!isParamValid("material_temperature_derivative"))
      paramError("material_temperature_derivative",
                 "If temperature is coupled, material_temperature_derivative must be provided.");
    // _T = &coupledValue("temperature");
    _T_id = coupled("temperature");
    _T_phi = &getVar("temperature", 0)->phi();
    _dMdT = &getMaterialProperty<Real>("material_temperature_derivative");
  }

  if (isCoupled("pressure"))
  {
    if (!isParamValid("material_pressure_derivative"))
      paramError("material_pressure_derivative",
                 "If pressure is coupled, material_pressure_derivative must be provided.");
    // _P = &coupledValue("pressure");
    _P_id = coupled("pressure");
    _P_phi = &getVar("pressure", 0)->phi();
    _dMdP = &getMaterialProperty<Real>("material_pressure_derivative");
  }

  if (isCoupled("fluid_fraction"))
  {
    if (!isParamValid("material_fluid_fraction_derivative"))
      paramError(
          "material_fluid_fraction_derivative",
          "If fluid_fraction is coupled, material_fluid_fraction_derivative must be provided.");
    // _vf = &coupledValue("fluid_fraction");
    _vf_id = coupled("fluid_fraction");
    _vf_phi = &getVar("fluid_fraction", 0)->phi();
    _dMdvf = &getMaterialProperty<Real>("material_fluid_fraction_derivative");
  }

  if (isCoupled("displacements"))
  {
    _ndisp = coupledComponents("displacements");
    if (!isParamValid("material_deformation_gradient_derivative"))
      paramError("material_deformation_gradient_derivative",
                 "If displacements are coupled, material_deformation_gradient_derivative must be "
                 "provided.");

    _avg_grad_trial.resize(_ndisp);
    _F_ust = &getMaterialPropertyByName<RankTwoTensor>("unstabilized_deformation_gradient");
    _F_avg = &getMaterialPropertyByName<RankTwoTensor>("average_deformation_gradient");

    const std::vector<VariableName> & _disp_name =
        getParam<std::vector<VariableName>>("displacements");

    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
    {
      if (coupled("displacements", k) == variable().number())
        paramError("variable", "Variable cannot be displacement.");
      _disp_id.push_back(coupled("displacements", k));
      _disp_phi.push_back(&getVar("displacements", k)->phi());
      _disp_grad_phi.push_back(&getVar("displacements", k)->gradPhi());
    }
    _dMdF = &getMaterialProperty<RankTwoTensor>("material_deformation_gradient_derivative");
  }
}

Real
PumaCoupledTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * _M[_qp] * _u_dot[_qp];
}

Real
PumaCoupledTimeDerivative::computeQpJacobian()
{
  auto R = _test[_i][_qp] * _phi[_j][_qp] * _du_dot_du[_qp] * _M[_qp];

  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      R += _test[_i][_qp] * (*_T_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdT)[_qp];

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      R += _test[_i][_qp] * (*_P_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdP)[_qp];

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      R += _test[_i][_qp] * (*_vf_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdvf)[_qp];

  return R;
}

Real
PumaCoupledTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _T_id)
    return _test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp] * _u_dot[_qp];

  if (jvar == _P_id)
    return _test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp] * _u_dot[_qp];

  if (jvar == _vf_id)
    return _test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp] * _u_dot[_qp];

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return _test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k)) * _u_dot[_qp];

  return 0.0;
}

void
PumaCoupledTimeDerivative::precalculateOffDiagJacobian(unsigned int jvar)
{
  // Skip if we are not doing stabilization
  if (!_stabilize_strain)
    return;

  for (auto beta : make_range(_ndisp))
    if (jvar == _disp_id[beta])
    {
      // We need the gradients of shape functions in the reference frame
      _fe_problem.prepareShapes(jvar, _tid);
      _avg_grad_trial[beta].resize(_phi.size());
      precalculateJacobianDisplacement(beta);
    }
}

void
PumaCoupledTimeDerivative::precalculateJacobianDisplacement(unsigned int component)
{
  // For total Lagrangian, the averaging is taken on the reference frame regardless of geometric
  // nonlinearity. Convenient!
  for (auto j : make_range(_phi.size()))
    _avg_grad_trial[component][j] = StabilizationUtils::elementAverage(
        [this, component, j](unsigned int qp)
        {
          return GradientOperatorCartesian::gradOp(component,
                                                   (*_disp_grad_phi[component])[j][qp],
                                                   (*_disp_phi[component])[j][qp],
                                                   _q_point[qp]);
        },
        _JxW,
        _coord);
}

RankTwoTensor
PumaCoupledTimeDerivative::gradTrial(unsigned int component)
{
  return _stabilize_strain ? gradTrialStabilized(component) : gradTrialUnstabilized(component);
}

RankTwoTensor
PumaCoupledTimeDerivative::gradTrialUnstabilized(unsigned int component)
{
  // Without F-bar stabilization, simply return the gradient of the trial functions
  return GradientOperatorCartesian::gradOp(component,
                                           (*_disp_grad_phi[component])[_j][_qp],
                                           (*_disp_phi[component])[_j][_qp],
                                           _q_point[_qp]);
}

RankTwoTensor
PumaCoupledTimeDerivative::gradTrialStabilized(unsigned int component)
{
  // The base unstabilized trial function gradient
  const auto Gb = GradientOperatorCartesian::gradOp(component,
                                                    (*_disp_grad_phi[component])[_j][_qp],
                                                    (*_disp_phi[component])[_j][_qp],
                                                    _q_point[_qp]);
  // The average trial function gradient
  const auto Ga = _avg_grad_trial[component][_j];

  // Horrible thing, see the documentation for how we get here
  const Real dratio = std::pow((*_F_avg)[_qp].det() / (*_F_ust)[_qp].det(), 1.0 / 3.0);
  const Real fact = ((*_F_avg)[_qp].inverse().transpose().doubleContraction(Ga) -
                     (*_F_ust)[_qp].inverse().transpose().doubleContraction(Gb)) /
                    3.0;
  return dratio * (Gb + fact * (*_F_ust)[_qp]);
}