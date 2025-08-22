//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#pragma once

#include "Kernel.h"

class PumaAdditiveFlux : public Kernel
{
public:
  static InputParameters validParams();

  PumaAdditiveFlux(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;

  const RealVectorValue & _g;

  const Real _coef;
};
