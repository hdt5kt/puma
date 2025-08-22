//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

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
