// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "MaterialSource.h"

registerMooseObject("PumaApp", MaterialSource);

InputParameters
MaterialSource::validParams()
{
  InputParameters params = KernelValue::validParams();
  params.addClassDescription("Source term defined by the material property");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addRequiredParam<MaterialPropertyName>(
      "prop_derivative", "Name of the material property derivative to provide the multiplier");
  params.addParam<Real>("coefficient", -1, "Coefficient to be multiplied to the source");
  return params;
}

MaterialSource::MaterialSource(const InputParameters & parameters)
  : KernelValue(parameters),
    _prop(getMaterialProperty<Real>("prop")),
    _dprop(getMaterialProperty<Real>("prop_derivative")),
    _coef(getParam<Real>("coefficient"))
{
}

Real
MaterialSource::precomputeQpResidual()
{
  return _coef * _prop[_qp];
}

Real
MaterialSource::precomputeQpJacobian()
{
  return _coef * _dprop[_qp];
}
