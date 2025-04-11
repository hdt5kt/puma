// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PumaCoupledMaterialPressure.h"
#include "Assembly.h"

registerMooseObject("PumaApp", PumaCoupledMaterialPressure);

InputParameters
PumaCoupledMaterialPressure::validParams()
{
  InputParameters params = Kernel::validParams();

  params.addClassDescription("Coupled material pressure for flow inside porous media");

  params.addRequiredCoupledVar("flow_concentration", "the flow species concentration");

  params.addRequiredParam<MaterialPropertyName>("material_pressure", "Material point pressure");
  params.addRequiredParam<MaterialPropertyName>(
      "coupled_pressure_derivative",
      "Derivative of the material pressure w.r.t. the species concentration");
  params.addRequiredParam<MaterialPropertyName>(
      "material_pressure_derivative",
      "Derivative of the material pressure w.r.t. the coupled variable (pressure)");
  return params;
}

PumaCoupledMaterialPressure::PumaCoupledMaterialPressure(const InputParameters & parameters)
  : Kernel(parameters),
    _alpha_id(coupled("flow_concentration")),
    _alpha(coupledValue("flow_concentration")),
    _alpha_var(*getVar("flow_concentration", 0)),
    _alpha_phi(_assembly.phi(_alpha_var)),
    _Pc(getMaterialProperty<Real>("material_pressure")),
    _dPc_dalpha(getMaterialProperty<Real>("coupled_pressure_derivative")),
    _dPc_dP(getMaterialProperty<Real>("material_pressure_derivative"))
{
}
Real
PumaCoupledMaterialPressure::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _Pc[_qp]);
}

Real
PumaCoupledMaterialPressure::computeQpJacobian()
{
  return _test[_i][_qp] * (_phi[_j][_qp] - _dPc_dP[_qp]);
}

Real
PumaCoupledMaterialPressure::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _alpha_id)
    return -_test[_i][_qp] * _dPc_dalpha[_qp] * _alpha_phi[_j][_qp];
  else
    return 0.0;
}
