// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Kernel.h"

class PumaPressure : public Kernel
{
public:
  static InputParameters validParams();

  PumaPressure(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const unsigned int _alpha_num;
  const MaterialProperty<Real> & _Pmat;
  const MaterialProperty<Real> & _dPmat;
};
