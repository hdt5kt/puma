// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PumaCoupledDarcyFlow.h"

registerMooseObject("PumaApp", PumaCoupledDarcyFlow);

InputParameters
PumaCoupledDarcyFlow::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel>::validParams();

  params.addClassDescription("Darcy flow with coefficients as material "
                             "properties for coupled variables");

  params.addRequiredCoupledVar("coupled_variable", "the coupled advective variable");
  params.addParam<Real>("coefficients", 1.0, "The constant coefficient");

  return params;
}

PumaCoupledDarcyFlow::PumaCoupledDarcyFlow(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel>(parameters),
    _coupled_id(coupled("coupled_variable")),
    _coeff(getParam<Real>("coefficients"))
{
  if (isCoupled("temperature"))
  {
    if (_T_id == _coupled_id)
    {
      _grad_var = &coupledGradient("temperature");
      _coupled_phi = &getVar("temperature", 0)->phi();
      _coupled_grad_phi = &getVar("temperature", 0)->gradPhi();
    }
  }

  if (isCoupled("pressure"))
  {
    if (_P_id == _coupled_id)
    {
      _grad_var = &coupledGradient("pressure");
      _coupled_phi = &getVar("pressure", 0)->phi();
      _coupled_grad_phi = &getVar("pressure", 0)->gradPhi();
    }
  }

  if (isCoupled("fluid_fraction"))
  {
    if (_vf_id == _coupled_id)
    {
      _grad_var = &coupledGradient("fluid_fraction");
      _coupled_phi = &getVar("fluid_fraction", 0)->phi();
      _coupled_grad_phi = &getVar("fluid_fraction", 0)->gradPhi();
    }
  }
}

Real
PumaCoupledDarcyFlow::computeQpResidual()
{
  return _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_grad_var)[_qp];
}

Real
PumaCoupledDarcyFlow::computeQpJacobian()
{
  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdT)[_qp];

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdP)[_qp];

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdvf)[_qp];

  return 0.0;
}

Real
PumaCoupledDarcyFlow::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (isCoupled("temperature"))
    if (jvar == _T_id)
    {
      auto R =
          _coeff * _grad_test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp] * (*_grad_var)[_qp];
      if (_T_id == _coupled_id)
        R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
      return R;
    }

  if (isCoupled("pressure"))
    if (jvar == _P_id)
    {
      auto R =
          _coeff * _grad_test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp] * (*_grad_var)[_qp];
      if (_P_id == _coupled_id)
        R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
      return R;
    }

  if (isCoupled("fluid_fraction"))
    if (jvar == _vf_id)
    {
      auto R =
          _coeff * _grad_test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp] * (*_grad_var)[_qp];
      if (_vf_id == _coupled_id)
        R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
      return R;
    }

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return _coeff * _grad_test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k)) *
               (*_grad_var)[_qp];

  return 0.0;
}
