// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "PumaDiffusion.h"

registerMooseObject("PumaApp", PumaDiffusion);

InputParameters
PumaDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("xxx");
  params.addRequiredParam<MaterialPropertyName>("diffusivity", "Nxxx");
  params.addRequiredParam<MaterialPropertyName>("diffusivity_derivative", "Nxxx");
  params.addRequiredCoupledVar("pressure", "Nxxx");
  params.addParam<Real>("coefficient", 1, "Coefficient to be multiplied to the source");
  return params;
}

PumaDiffusion::PumaDiffusion(const InputParameters & parameters)
  : Kernel(parameters),
    _D(getMaterialProperty<Real>("diffusivity")),
    _dD(getMaterialProperty<Real>("diffusivity_derivative")),
    _P_num(coupled("pressure")),
    _Pgrad(coupledGradient("pressure")),
    _coef(getParam<Real>("coefficient"))
{
}

Real
PumaDiffusion::computeQpResidual()
{
  return _coef * _grad_test[_i][_qp] * (_D[_qp] * _grad_u[_qp] - _Pgrad[_qp]);
}

Real
PumaDiffusion::computeQpJacobian()
{
  return _coef * _grad_test[_i][_qp] * _dD[_qp] * _grad_u[_qp] * _phi[_j][_qp] +
         _coef * _grad_test[_i][_qp] * _D[_qp] * _grad_phi[_j][_qp];
}

Real
PumaDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _P_num)
    return -_coef * _grad_test[_i][_qp] * _grad_phi[_j][_qp];
  return 0.0;
}