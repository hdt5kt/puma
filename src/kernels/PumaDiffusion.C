//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "PumaDiffusion.h"

registerMooseObject("PumaApp", PumaDiffusion);

InputParameters
PumaDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Diffusion of a species in a porous media");
  params.addRequiredParam<MaterialPropertyName>("diffusivity", "Diffusivity of this species");
  params.addRequiredParam<MaterialPropertyName>(
      "diffusivity_derivative", "Derivative of the diffusivity w.r.t. the species concentration");
  return params;
}

PumaDiffusion::PumaDiffusion(const InputParameters & parameters)
  : Kernel(parameters),
    _D(getMaterialProperty<Real>("diffusivity")),
    _dD(getMaterialProperty<Real>("diffusivity_derivative"))
{
}

Real
PumaDiffusion::computeQpResidual()
{
  return _grad_test[_i][_qp] * _D[_qp] * _grad_u[_qp];
}

Real
PumaDiffusion::computeQpJacobian()
{
  return _grad_test[_i][_qp] * _dD[_qp] * _grad_u[_qp] * _phi[_j][_qp] +
         _grad_test[_i][_qp] * _D[_qp] * _grad_phi[_j][_qp];
}
