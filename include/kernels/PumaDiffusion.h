//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

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
