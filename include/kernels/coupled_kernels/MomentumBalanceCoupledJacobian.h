//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Kernel.h"
#include "GradientOperator.h"

class MomentumBalanceCoupledJacobian : public Kernel
{
public:
  static InputParameters validParams();

  MomentumBalanceCoupledJacobian(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;
  virtual RankTwoTensor gradTest(unsigned int component);

  unsigned int _component;

  // temperature
  unsigned int _T_id;
  const VariablePhiValue * _T_phi;
  const MaterialProperty<RankTwoTensor> * _dSdT;

  // pressure
  unsigned int _P_id;
  const VariablePhiValue * _P_phi;
  const MaterialProperty<RankTwoTensor> * _dSdP;

  // fluid fraction
  unsigned int _vf_id;
  const VariablePhiValue * _vf_phi;
  const MaterialProperty<RankTwoTensor> * _dSdvf;
};
