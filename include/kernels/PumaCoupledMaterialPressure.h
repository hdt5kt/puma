// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"

class PumaCoupledMaterialPressure : public Kernel
{
public:
  static InputParameters validParams();

  PumaCoupledMaterialPressure(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  unsigned int _alpha_id;

  const VariableValue & _alpha;
  MooseVariable & _alpha_var;

  const VariablePhiValue & _alpha_phi;

  const MaterialProperty<Real> & _Pc;
  const MaterialProperty<Real> & _dPc_dalpha;
};
