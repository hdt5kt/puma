// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "InfiltrationWake.h"
#include "Function.h"

registerMooseObject("PumaApp", InfiltrationWake);

InputParameters
InfiltrationWake::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addClassDescription("Mimic the immersion of the boundary in a wake of molten material");

  params.addRequiredParam<MaterialPropertyName>("solid_fraction", "Volume fraction of the solid");
  params.addRequiredParam<MaterialPropertyName>(
      "solid_fraction_derivative",
      "Derivative of the solid fraction w.r.t. the species concentration");
  params.addRequiredParam<MaterialPropertyName>("liquid_fraction", "Volume fraction of the liquid");
  params.addRequiredParam<MaterialPropertyName>(
      "liquid_fraction_derivative",
      "Derivative of the liquid fraction w.r.t. the species concentration");
  params.addRequiredParam<MaterialPropertyName>("product_fraction",
                                                "Volume fraction of the product");
  params.addRequiredParam<MaterialPropertyName>(
      "product_fraction_derivative",
      "Derivative of the product fraction w.r.t. the species concentration");

  params.addParam<Real>("sharpness", 10, "Sharpness of the heaviside function");
  params.addRequiredParam<FunctionName>(
      "inlet_flux", "The function describing the suction flux from the wake into the solid");
  params.addRequiredParam<FunctionName>(
      "outlet_flux", "The function describing the extraction flux from the wake into the solid");

  return params;
}

InfiltrationWake::InfiltrationWake(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _phi_s(getMaterialProperty<Real>("solid_fraction")),
    _dphi_s(getMaterialProperty<Real>("solid_fraction_derivative")),
    _phi_l(getMaterialProperty<Real>("liquid_fraction")),
    _dphi_l(getMaterialProperty<Real>("liquid_fraction_derivative")),
    _phi_p(getMaterialProperty<Real>("product_fraction")),
    _dphi_p(getMaterialProperty<Real>("product_fraction_derivative")),
    _sharpness(getParam<Real>("sharpness")),
    _inlet_flux(getFunction("inlet_flux")),
    _outlet_flux(getFunction("outlet_flux"))
{
}

Real
heaviside(Real x, Real k)
{
  return 0.5 * (1 + tanh(k * x));
}

Real
dheaviside(Real x, Real k)
{
  return 0.5 * k * (1 - tanh(k * x) * tanh(k * x));
}

Real
InfiltrationWake::computeQpResidual()
{
  const auto cap = 1 - _phi_s[_qp] - _phi_p[_qp];
  auto x = _phi_l[_qp] / cap;
  const auto a = _inlet_flux.value(_t, _q_point[_qp]);
  const auto b = _outlet_flux.value(_t, _q_point[_qp]);
  const auto scale = -heaviside(x - 1, _sharpness) * (a + b) + a;

  return -_test[_i][_qp] * scale;
}

Real
InfiltrationWake::computeQpJacobian()
{
  const auto cap = 1 - _phi_s[_qp] - _phi_p[_qp];
  auto x = _phi_l[_qp] / cap;
  const auto a = _inlet_flux.value(_t, _q_point[_qp]);
  const auto b = _outlet_flux.value(_t, _q_point[_qp]);
  const auto dscale_dx = -dheaviside(x - 1, _sharpness) * (a + b);
  const auto dx_dphi_l = 1 / cap;
  const auto dx_dcap = -_phi_l[_qp] / (cap * cap);
  const Real dcap_dphi_s = -1.0;
  const Real dcap_dphi_p = -1.0;

  const auto dscale_dalpha = dscale_dx * dx_dphi_l * _dphi_l[_qp] +
                             dscale_dx * dx_dcap * dcap_dphi_s * _dphi_s[_qp] +
                             dscale_dx * dx_dcap * dcap_dphi_p * _dphi_p[_qp];

  return -_test[_i][_qp] * dscale_dalpha * _phi[_j][_qp];
}
