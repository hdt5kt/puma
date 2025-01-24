// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "PumaPressure.h"

registerMooseObject("PumaApp", PumaPressure);

InputParameters
PumaPressure::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("xxx");
  params.addRequiredParam<MaterialPropertyName>("material_pressure", "Nxxx");
  params.addRequiredParam<MaterialPropertyName>("material_pressure_derivative", "Nxxx");
  params.addRequiredCoupledVar("liquid_saturation", "xxxx");
  return params;
}

PumaPressure::PumaPressure(const InputParameters & parameters)
  : Kernel(parameters),
    _alpha_num(coupled("liquid_saturation")),
    _Pmat(getMaterialProperty<Real>("material_pressure")),
    _dPmat(getMaterialProperty<Real>("material_pressure_derivative"))
{
}

Real
PumaPressure::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _Pmat[_qp]);
}

Real
PumaPressure::computeQpJacobian()
{
  return _test[_i][_qp] * _phi[_j][_qp];
}

Real
PumaPressure::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _alpha_num)
    return _test[_i][_qp] * _dPmat[_qp] * _phi[_j][_qp];
  return 0.0;
}
