//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

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

  params.addRequiredParam<MaterialPropertyName>("product_fraction",
                                                "Volume fraction of the product");
  params.addRequiredParam<MaterialPropertyName>(
      "product_fraction_derivative",
      "Derivative of the product fraction w.r.t. the species concentration");

  params.addParam<Real>("sharpness", 10, "Sharpness of the heaviside function");

  params.addParam<Real>("no_flux_fraction_transition",
                        0.05,
                        "The non-liquid fraction where the flux starts the transistion to zero "
                        "flux, following Hermite smoothstep function");

  params.addRequiredParam<FunctionName>(
      "inlet_flux", "The function describing the suction flux from the wake into the solid");
  params.addRequiredParam<FunctionName>(
      "outlet_flux", "The function describing the extraction flux from the wake into the solid");

  params.addCoupledVar("multiplier", "The multiplier for the inlet and outlet fluxes");
  params.addParam<Real>(
      "multiplier_residual", 0.05, "The residual multiplier for when the fluxes are zero");

  return params;
}

InfiltrationWake::InfiltrationWake(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _phi_s(getMaterialProperty<Real>("solid_fraction")),
    _dphi_s(getMaterialProperty<Real>("solid_fraction_derivative")),
    _phi_p(getMaterialProperty<Real>("product_fraction")),
    _dphi_p(getMaterialProperty<Real>("product_fraction_derivative")),
    _sharpness(getParam<Real>("sharpness")),
    _transistion(getParam<Real>("no_flux_fraction_transition")),
    _inlet_flux(getFunction("inlet_flux")),
    _outlet_flux(getFunction("outlet_flux")),
    _M(isCoupled("multiplier") ? &coupledValue("multiplier") : nullptr),
    _M0(getParam<Real>("multiplier_residual"))
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
hermite(Real x, Real xu)
{
  auto xr = x / xu;
  if (xr < 0)
    return 0.0;
  else if (xr > 1)
    return 1.0;
  else
    return 3 * xr * xr - 2 * xr * xr * xr;
}

Real
dhermite(Real x, Real xu)
{
  auto xr = x / xu;
  auto dxrdx = 1 / xu;
  if (xr < 0)
    return 0.0;
  else if (xr > 1)
    return 0.0;
  else
    return 6 * xr * dxrdx - 6 * xr * xr * dxrdx;
}

Real
InfiltrationWake::computeQpResidual()
{
  const Real dis_tol = libMesh::TOLERANCE;

  const auto cap = 1 - _phi_s[_qp] - _phi_p[_qp];
  auto x = _u[_qp] / (cap + dis_tol);

  const auto a = _inlet_flux.value(_t, _q_point[_qp]);
  const auto b = _outlet_flux.value(_t, _q_point[_qp]);
  const auto scale = (-heaviside(x - 1, _sharpness) * (a + b) + a) * hermite(cap, _transistion);

  const auto r = -_test[_i][_qp] * scale;
  return _M ? std::max((*_M)[_qp] - _M0, 0.0) * r : r;
}

Real
InfiltrationWake::computeQpJacobian()
{
  const Real dis_tol = libMesh::TOLERANCE;

  const auto cap = 1 - _phi_s[_qp] - _phi_p[_qp];
  auto x = _u[_qp] / (cap + dis_tol);
  const auto a = _inlet_flux.value(_t, _q_point[_qp]);
  const auto b = _outlet_flux.value(_t, _q_point[_qp]);

  const auto dcap_dx = -_u[_qp] / (x * x + dis_tol);
  const auto dscale_dx =
      (-dheaviside(x - 1, _sharpness) * (a + b)) * hermite(cap, _transistion) +
      (-dheaviside(x - 1, _sharpness) * (a + b) + a) * dhermite(cap, _transistion) * dcap_dx;

  const auto dx_dphi_l = 1 / (cap + dis_tol);
  const auto dx_dcap = -_u[_qp] / (cap * cap + dis_tol);

  const Real dcap_dphi_s = -1.0;
  const Real dcap_dphi_p = -1.0;

  const auto dscale_dphil = dscale_dx * dx_dphi_l +
                            dscale_dx * dx_dcap * dcap_dphi_s * _dphi_s[_qp] +
                            dscale_dx * dx_dcap * dcap_dphi_p * _dphi_p[_qp];

  const auto J = -_test[_i][_qp] * dscale_dphil * _phi[_j][_qp];
  return _M ? std::max((*_M)[_qp] - _M0, 0.0) * J : J;
}
