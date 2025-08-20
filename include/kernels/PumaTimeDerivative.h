#pragma once

#include "TimeKernel.h"

class PumaTimeDerivative : public TimeKernel
{
public:
  static InputParameters validParams();

  PumaTimeDerivative(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const MaterialProperty<Real> & _M;
  const MaterialProperty<Real> & _dM;
};
