//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "TimeKernel.h"
#include "GradientOperator.h"

class PumaCoupledTimeDerivative : public TimeKernel
{
public:
  static InputParameters validParams();

  PumaCoupledTimeDerivative(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  virtual void precalculateOffDiagJacobian(unsigned int component) override;
  virtual void precalculateJacobianDisplacement(unsigned int component);
  virtual RankTwoTensor gradTrial(unsigned int component);

  const MaterialProperty<Real> & _M;

  const bool _stabilize_strain;

  // temperature
  // const VariableValue * _T; //* instead of & since this variable is optional
  unsigned int _T_id;
  const VariablePhiValue * _T_phi;
  const MaterialProperty<Real> * _dMdT;

  // pressure
  // const VariableValue * _P; //* instead of & since this variable is optional
  unsigned int _P_id;
  const VariablePhiValue * _P_phi;
  const MaterialProperty<Real> * _dMdP;

  // fluid fraction
  // const VariableValue * _vf; //* instead of & since this variable is optional
  unsigned int _vf_id;
  const VariablePhiValue * _vf_phi;
  const MaterialProperty<Real> * _dMdvf;

  // solid mechanics
  const MaterialProperty<RankTwoTensor> * _F_ust;
  const MaterialProperty<RankTwoTensor> * _F_avg;
  unsigned int _ndisp;
  std::vector<unsigned int> _disp_id;
  std::vector<const VariablePhiValue *> _disp_phi;
  std::vector<const VariablePhiGradient *> _disp_grad_phi;
  const MaterialProperty<RankTwoTensor> * _dMdF;

  std::vector<std::vector<RankTwoTensor>> _avg_grad_trial;

private:
  /// The unstabilized trial function gradient
  virtual RankTwoTensor gradTrialUnstabilized(unsigned int component);

  /// The stabilized trial function gradient
  virtual RankTwoTensor gradTrialStabilized(unsigned int component);
};
