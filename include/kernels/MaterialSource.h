//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#pragma once

#include "KernelValue.h"

class MaterialSource : public KernelValue
{
public:
  static InputParameters validParams();

  MaterialSource(const InputParameters & parameters);

protected:
  virtual Real precomputeQpResidual() override;
  virtual Real precomputeQpJacobian() override;

  const MaterialProperty<Real> & _prop;
  const MaterialProperty<Real> & _dprop;

  const Real _coef;
};
