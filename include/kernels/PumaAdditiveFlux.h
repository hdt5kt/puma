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
