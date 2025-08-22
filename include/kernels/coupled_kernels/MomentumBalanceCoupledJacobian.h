//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#pragma once

#include "Kernel.h"
#include "GradientOperator.h"

class MomentumBalanceCoupledJacobian : public Kernel, GradientOperatorCartesian
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
