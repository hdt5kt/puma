//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PumaTimeDerivative.h"

// MOOSE includes
#include "Assembly.h"
#include "MooseVariableFE.h"

#include "libmesh/quadrature.h"

registerMooseObject("MooseApp", PumaTimeDerivative);

InputParameters
PumaTimeDerivative::validParams()
{
  InputParameters params = TimeKernel::validParams();
  params.addClassDescription("Time derivative with a material constant.");

  params.addRequiredParam<MaterialPropertyName>("material_prop", "Material constant multiply by the time derivative");
  params.addRequiredParam<MaterialPropertyName>(
      "material_prop_derivative", "Derivative of the material_prop w.r.t. the variable");
  return params;
}

PumaTimeDerivative::PumaTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
  _M(getMaterialProperty<Real>("material_prop")),
  _dM(getMaterialProperty<Real>("material_prop_derivative"))
{
}

Real
PumaTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * _M[_qp] * _u_dot[_qp];
}

Real
PumaTimeDerivative::computeQpJacobian()
{
  return _test[_i][_qp] * _phi[_j][_qp] * _du_dot_du[_qp] * _M[_qp] 
        + _test[_i][_qp] * _phi[_j][_qp] * _u_dot[_qp] * _dM[_qp];
}