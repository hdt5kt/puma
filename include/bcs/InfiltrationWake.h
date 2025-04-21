// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "IntegratedBC.h"

class Function;

class InfiltrationWake : public IntegratedBC
{
public:
  static InputParameters validParams();

  InfiltrationWake(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  /// Volume fraction of the solid phase (and its derivative w.r.t. the species concentration)
  const MaterialProperty<Real> & _phi_s;
  const MaterialProperty<Real> & _dphi_s;

  /// Volume fraction of the product phase (and its derivative w.r.t. the species concentration)
  const MaterialProperty<Real> & _phi_p;
  const MaterialProperty<Real> & _dphi_p;

  /// Sharpness of the heaviside function
  const Real _sharpness;

  /// Non-liquid volume fraction when transition to zero flux begins
  const Real _transistion;

  /// The suction flux from the wake into the solid
  const Function & _inlet_flux;
  /// The extraction flux for out flow
  const Function & _outlet_flux;

  /// The multiplier for the inlet and outlet fluxes
  const VariableValue * _M;
  const Real _M0;
};
