//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#pragma once

#include "PumaCoupledKernelInterface.h"
#include "TimeKernel.h"

/**
 * Time derivative kernel using material property and coupled physics (temperature, pressure, etc.).
 */
template <class G>
class PumaCoupledTimeDerivativeBase : public PumaCoupledKernelInterface<TimeKernel, G>
{
public:
  static InputParameters validParams();
  PumaCoupledTimeDerivativeBase(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;
};
