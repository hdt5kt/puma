// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "PumaCoupledKernelInterface.h"
#include "Kernel.h"

template <typename G>
class CoupledMaterialSourceBase : public PumaCoupledKernelInterface<Kernel, G>
{
public:
  static InputParameters validParams();

  CoupledMaterialSourceBase(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _coeff;
};
