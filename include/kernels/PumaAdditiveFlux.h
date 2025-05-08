// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
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
