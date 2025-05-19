// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PumaAdditiveFlux.h"

registerMooseObject("PumaApp", PumaAdditiveFlux);

InputParameters
PumaAdditiveFlux::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("The additive term for the flux in the diffusion equation");

  params.addRequiredParam<RealVectorValue>("value", "Value to add to the flux");

  params.addParam<Real>("coefficient", 1, "Coefficient to be multiplied to the value");
  return params;
}

PumaAdditiveFlux::PumaAdditiveFlux(const InputParameters & parameters)
  : Kernel(parameters), _g(getParam<RealVectorValue>("value")), _coef(getParam<Real>("coefficient"))
{
}

Real
PumaAdditiveFlux::computeQpResidual()
{
  return _grad_test[_i][_qp] * _g;
}
