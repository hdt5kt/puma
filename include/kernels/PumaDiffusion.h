// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"

class PumaDiffusion : public Kernel
{
public:
  static InputParameters validParams();

  PumaDiffusion(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const MaterialProperty<Real> & _D;
  const MaterialProperty<Real> & _dD;
  const unsigned int _P_num;
  const VariableGradient & _Pgrad;

  const Real _coef;
};
