#include "PumaCoupledDarcyFlowBase.h"
#include "CoordSysInstantiation.h"

template <class G>
InputParameters
PumaCoupledDarcyFlowBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel, G>::validParams();

  params.addClassDescription("Darcy flow with coefficients as material "
                             "properties for coupled variables");

  params.addRequiredCoupledVar("coupled_variable", "the coupled advective variable");
  params.addParam<Real>("coefficients", 1.0, "The constant coefficient");

  return params;
}

template <class G>
PumaCoupledDarcyFlowBase<G>::PumaCoupledDarcyFlowBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel, G>(parameters),
    _coupled_id(this->coupled("coupled_variable")),
    _coeff(this->template getParam<Real>("coefficients"))
{
  if (this->isCoupled("temperature"))
  {
    if (this->_T_id == _coupled_id)
    {
      _grad_var = &this->coupledGradient("temperature");
      _coupled_phi = &this->getVar("temperature", 0)->phi();
      _coupled_grad_phi = &this->getVar("temperature", 0)->gradPhi();
    }
  }

  if (this->isCoupled("pressure"))
  {
    if (this->_P_id == _coupled_id)
    {
      _grad_var = &this->coupledGradient("pressure");
      _coupled_phi = &this->getVar("pressure", 0)->phi();
      _coupled_grad_phi = &this->getVar("pressure", 0)->gradPhi();
    }
  }

  if (this->isCoupled("fluid_fraction"))
  {
    if (this->_vf_id == _coupled_id)
    {
      _grad_var = &this->coupledGradient("fluid_fraction");
      _coupled_phi = &this->getVar("fluid_fraction", 0)->phi();
      _coupled_grad_phi = &this->getVar("fluid_fraction", 0)->gradPhi();
    }
  }
}

template <class G>
Real
PumaCoupledDarcyFlowBase<G>::computeQpResidual()
{
  return _coeff * this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] *
         (*_grad_var)[this->_qp];
}

template <class G>
Real
PumaCoupledDarcyFlowBase<G>::computeQpJacobian()
{

  if (this->isCoupled("temperature"))
    if (this->_T_id == this->variable().number())
      return _coeff * this->_grad_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (*_grad_var)[this->_qp] * (*this->_dMdT)[this->_qp];

  if (this->isCoupled("pressure"))
    if (this->_P_id == this->variable().number())
      return _coeff * this->_grad_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (*_grad_var)[this->_qp] * (*this->_dMdP)[this->_qp];

  if (this->isCoupled("fluid_fraction"))
    if (this->_vf_id == this->variable().number())
      return _coeff * this->_grad_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (*_grad_var)[this->_qp] * (*this->_dMdvf)[this->_qp];

  return 0.0;
}

template <class G>
Real
PumaCoupledDarcyFlowBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{

  if (this->isCoupled("temperature"))
    if (jvar == this->_T_id)
    {
      auto R = _coeff * this->_grad_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
               (*this->_T_phi)[this->_j][this->_qp] * (*_grad_var)[this->_qp];
      if (this->_T_id == _coupled_id)
        R += _coeff * this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] *
             (*_coupled_grad_phi)[this->_j][this->_qp];
      return R;
    }

  if (this->isCoupled("pressure"))
    if (jvar == this->_P_id)
    {
      auto R = _coeff * this->_grad_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
               (*this->_P_phi)[this->_j][this->_qp] * (*_grad_var)[this->_qp];
      if (this->_P_id == _coupled_id)
        R += _coeff * this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] *
             (*_coupled_grad_phi)[this->_j][this->_qp];
      return R;
    }

  if (this->isCoupled("fluid_fraction"))
    if (jvar == this->_vf_id)
    {
      auto R = _coeff * this->_grad_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
               (*this->_vf_phi)[this->_j][this->_qp] * (*_grad_var)[this->_qp];
      if (this->_vf_id == _coupled_id)
        R += _coeff * this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] *
             (*_coupled_grad_phi)[this->_j][this->_qp];
      return R;
    }

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return _coeff * this->_grad_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k)) *
               (*_grad_var)[this->_qp];

  return 0.0;
}

INSTANTIATE_PUMA_KERNEL(PumaCoupledDarcyFlow,
                        PumaCoupledDarcyFlowBase,
                        GradientOperatorCartesian,
                        Moose::COORD_XYZ,
                        "Cartesian");

INSTANTIATE_PUMA_KERNEL(PumaCoupledDarcyFlowAxisymmetricCylindrical,
                        PumaCoupledDarcyFlowBase,
                        GradientOperatorAxisymmetricCylindrical,
                        Moose::COORD_RZ,
                        "Cylindrical");

INSTANTIATE_PUMA_KERNEL(PumaCoupledDarcyFlowCentrosymmetricSpherical,
                        PumaCoupledDarcyFlowBase,
                        GradientOperatorCentrosymmetricSpherical,
                        Moose::COORD_RSPHERICAL,
                        "Spherical");
