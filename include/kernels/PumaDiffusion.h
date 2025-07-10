#pragma once

#include "Kernel.h"

class PumaDiffusion : public Kernel
{
public:
  static InputParameters validParams();

  PumaDiffusion(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const MaterialProperty<Real> & _D;
  const MaterialProperty<Real> & _dD;
};
