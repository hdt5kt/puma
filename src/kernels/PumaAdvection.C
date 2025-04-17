// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PumaAdvection.h"
#include "Assembly.h"

registerMooseObject("PumaApp", PumaAdvection);

InputParameters
PumaAdvection::validParams()
{
  InputParameters params = Kernel::validParams();

  params.addClassDescription("coupled advection - saturation flow");

  params.addRequiredCoupledVar("pressure", "the coupled advective pressure");

  params.addRequiredParam<MaterialPropertyName>("density", "Material density");
  params.addRequiredParam<MaterialPropertyName>("viscosity", "Material viscosity");

  params.addRequiredParam<MaterialPropertyName>("permeability", "Background material permeability");
  params.addRequiredParam<MaterialPropertyName>(
      "permeability_derivative",
      "Derivative of the material permeability w.r.t. the flow species concentration");

  params.addParam<Real>("coefficients", 1.0, "The constant coefficient");

  return params;
}

PumaAdvection::PumaAdvection(const InputParameters & parameters)
  : Kernel(parameters),
    _P_id(coupled("pressure")),
    _grad_P(coupledGradient("pressure")),
    _P_var(*getVar("pressure", 0)),
    _P_grad_phi(_P_var.gradPhi()),
    _rho(getMaterialProperty<Real>("density")),
    _nu(getMaterialProperty<Real>("viscosity")),
    _k(getMaterialProperty<Real>("permeability")),
    _dk_dalpha(getMaterialProperty<Real>("permeability_derivative")),
    _coeff(getParam<Real>("coefficients"))
{
}

Real
PumaAdvection::computeQpResidual()
{
  return _grad_test[_i][_qp] * _coeff * _rho[_qp] / _nu[_qp] * _k[_qp] * _grad_P[_qp];
}

Real
PumaAdvection::computeQpJacobian()
{
  return _grad_test[_i][_qp] * _coeff * _rho[_qp] / _nu[_qp] * _dk_dalpha[_qp] * _phi[_j][_qp] *
         _grad_P[_qp];
}

Real
PumaAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _P_id)
    return _coeff * _grad_test[_i][_qp] * _rho[_qp] / _nu[_qp] * _k[_qp] * _P_grad_phi[_j][_qp];

  return 0.0;
}
