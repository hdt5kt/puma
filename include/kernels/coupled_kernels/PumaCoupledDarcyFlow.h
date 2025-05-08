// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"

class PumaCoupledDarcyFlow : public Kernel
{
public:
  static InputParameters validParams();

  PumaCoupledDarcyFlow(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const MaterialProperty<Real> & _M;
  unsigned int _coupled_id;
  const VariableGradient * _grad_var;
  const VariablePhiValue * _coupled_phi;
  const VariablePhiGradient * _coupled_grad_phi;

  Real _coeff;

  // temperature
  unsigned int _T_id;
  const VariablePhiValue * _T_phi;
  const MaterialProperty<Real> * _dMdT;

  // pressure
  unsigned int _P_id;
  const VariablePhiValue * _P_phi;
  const MaterialProperty<Real> * _dMdP;

  // fluid fraction
  unsigned int _vf_id;
  const VariablePhiValue * _vf_phi;
  const MaterialProperty<Real> * _dMdvf;
};
