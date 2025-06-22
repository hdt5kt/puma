//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

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
