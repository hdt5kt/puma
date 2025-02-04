// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "KernelScalarBase.h"

class LevelsetMaterialization : public KernelScalarBase
{
public:
  static InputParameters validParams();

  LevelsetMaterialization(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobianScalar(unsigned int jvar) override;

  void residualSetup() override;

  Real computeScalarQpResidual() override;
  Real computeScalarQpJacobian() override;

  /// dot(h)
  const VariableValue & _h_dot;
  /// Derivative of dot(h) w.r.t. h
  const VariableValue & _dh_dot_dh;

  /// Volume rate of change
  const PostprocessorValue & _V_dot;

  /// Derivative of the levelset function w.r.t. the Lagrange multiplier
  const MaterialProperty<Real> & _L;
  const MaterialProperty<Real> & _dL_dh;
  const MaterialProperty<Real> & _d2L_dh2;

  /// Derivative of the materialization function w.r.t. the levelset function
  const MaterialProperty<Real> & _dM_dL;
  const MaterialProperty<Real> & _d2M_dL2;
};
