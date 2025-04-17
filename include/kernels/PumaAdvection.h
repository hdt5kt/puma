// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"

class PumaAdvection : public Kernel
{
public:
  static InputParameters validParams();

  PumaAdvection(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  unsigned int _P_id;
  const VariableGradient & _grad_P;
  MooseVariable & _P_var;
  const VariablePhiGradient & _P_grad_phi;

  const MaterialProperty<Real> & _rho;
  const MaterialProperty<Real> & _nu;

  const MaterialProperty<Real> & _k;
  const MaterialProperty<Real> & _dk_dalpha;

  Real _coeff;
};
