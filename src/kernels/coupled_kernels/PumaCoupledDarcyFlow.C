// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PumaCoupledDarcyFlow.h"

registerMooseObject("PumaApp", PumaCoupledDarcyFlow);

InputParameters
PumaCoupledDarcyFlow::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addCoupledVar("temperature", "The temperature");
  params.addCoupledVar("pressure", "The pressure");
  params.addCoupledVar("fluid_fraction", "Volume fraction of the product");
  params.addCoupledVar("displacements", "The displacements");

  params.addRequiredParam<MaterialPropertyName>("material_prop", "Material based source term");
  params.addRequiredCoupledVar("coupled_variable", "the coupled advective variable");

  params.addParam<MaterialPropertyName>("material_temperature_derivative",
                                        "Derivative of the material_prop w.r.t. the temperature");
  params.addParam<MaterialPropertyName>("material_pressure_derivative",
                                        "Derivative of the material_prop w.r.t. the pressure");
  params.addParam<MaterialPropertyName>(
      "material_fluid_fraction_derivative",
      "Derivative of the material_prop w.r.t. the fluid fraction");
  params.addParam<MaterialPropertyName>(
      "material_deformation_gradient_derivative",
      "Derivative of the material_prop w.r.t. the deformation gradient");

  params.addParam<Real>("coefficients", 1.0, "The constant coefficient");

  return params;
}

PumaCoupledDarcyFlow::PumaCoupledDarcyFlow(const InputParameters & parameters)
  : Kernel(parameters),
    _M(getMaterialProperty<Real>("material_prop")),
    _coupled_id(coupled("coupled_variable")),
    _coeff(getParam<Real>("coefficients"))
{
  if (isCoupled("temperature"))
  {
    if (!isParamValid("material_temperature_derivative"))
      paramError("material_temperature_derivative",
                 "If temperature is coupled, material_temperature_derivative must be provided.");
    _T_id = coupled("temperature");
    _T_phi = &getVar("temperature", 0)->phi();
    _dMdT = &getMaterialProperty<Real>("material_temperature_derivative");
    if (_T_id == _coupled_id)
    {
      _grad_var = &coupledGradient("temperature");
      _coupled_phi = &getVar("temperature", 0)->phi();
      _coupled_grad_phi = &getVar("temperature", 0)->gradPhi();
    }
  }

  if (isCoupled("pressure"))
  {
    if (!isParamValid("material_pressure_derivative"))
      paramError("material_pressure_derivative",
                 "If pressure is coupled, material_pressure_derivative must be provided.");
    _P_id = coupled("pressure");
    _P_phi = &getVar("pressure", 0)->phi();
    _dMdP = &getMaterialProperty<Real>("material_pressure_derivative");
    if (_P_id == _coupled_id)
      if (_P_id == _coupled_id)
      {
        _grad_var = &coupledGradient("pressure");
        _coupled_phi = &getVar("pressure", 0)->phi();
        _coupled_grad_phi = &getVar("pressure", 0)->gradPhi();
      }
  }

  if (isCoupled("fluid_fraction"))
  {
    if (!isParamValid("material_fluid_fraction_derivative"))
      paramError(
          "material_fluid_fraction_derivative",
          "If fluid_fraction is coupled, material_fluid_fraction_derivative must be provided.");
    _vf_id = coupled("fluid_fraction");
    _vf_phi = &getVar("fluid_fraction", 0)->phi();
    _dMdvf = &getMaterialProperty<Real>("material_fluid_fraction_derivative");
    if (_vf_id == _coupled_id)
      if (_vf_id == _coupled_id)
      {
        _grad_var = &coupledGradient("fluid_fraction");
        _coupled_phi = &getVar("fluid_fraction", 0)->phi();
        _coupled_grad_phi = &getVar("fluid_fraction", 0)->gradPhi();
      }
  }
}

Real
PumaCoupledDarcyFlow::computeQpResidual()
{
  return _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_grad_var)[_qp];
}

Real
PumaCoupledDarcyFlow::computeQpJacobian()
{
  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdT)[_qp];

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdP)[_qp];

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      return _coeff * _grad_test[_i][_qp] * _phi[_j][_qp] * (*_grad_var)[_qp] * (*_dMdvf)[_qp];

  return 0.0;
}

Real
PumaCoupledDarcyFlow::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _T_id)
  {
    auto R = _coeff * _grad_test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp] * (*_grad_var)[_qp];
    if (_T_id == _coupled_id)
      R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
    return R;
  }

  if (jvar == _P_id)
  {
    auto R = _coeff * _grad_test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp] * (*_grad_var)[_qp];
    if (_P_id == _coupled_id)
      R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
    return R;
  }

  if (jvar == _vf_id)
  {
    auto R =
        _coeff * _grad_test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp] * (*_grad_var)[_qp];
    if (_vf_id == _coupled_id)
      R += _coeff * _grad_test[_i][_qp] * _M[_qp] * (*_coupled_grad_phi)[_j][_qp];
    return R;
  }

  return 0.0;
}
