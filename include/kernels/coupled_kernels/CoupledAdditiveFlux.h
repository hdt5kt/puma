// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "PumaCoupledKernelInterface.h"
#include "Kernel.h"

class CoupledAdditiveFlux : public PumaCoupledKernelInterface<Kernel>
{
public:
  static InputParameters validParams();

  CoupledAdditiveFlux(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const RealVectorValue & _g;
};
