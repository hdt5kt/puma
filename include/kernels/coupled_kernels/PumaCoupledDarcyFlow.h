// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"
#include "PumaCoupledKernelInterface.h"

class PumaCoupledDarcyFlow : public PumaCoupledKernelInterface<Kernel>
{
public:
  static InputParameters validParams();

  PumaCoupledDarcyFlow(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  unsigned int _coupled_id;
  const VariableGradient * _grad_var;
  const VariablePhiValue * _coupled_phi;
  const VariablePhiGradient * _coupled_grad_phi;

  Real _coeff;
};
