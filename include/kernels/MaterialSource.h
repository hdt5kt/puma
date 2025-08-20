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
