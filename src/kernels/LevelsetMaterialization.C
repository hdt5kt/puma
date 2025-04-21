// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "LevelsetMaterialization.h"
#include "MooseVariableScalar.h"

registerMooseObject("PumaApp", LevelsetMaterialization);

InputParameters
LevelsetMaterialization::validParams()
{
  InputParameters params = KernelScalarBase::validParams();
  params.addClassDescription(
      "Update the levelset variable to reflect the change in material volume.");
  params.addRequiredParam<PostprocessorName>("volume_change_rate",
                                             "The rate of change of the volume");
  params.addRequiredParam<MaterialPropertyName>("levelset_function", "The levelset function");
  params.addRequiredParam<MaterialPropertyName>(
      "levelset_function_derivative",
      "Derivative of the levelset function w.r.t. the Lagrange multiplier");
  params.addRequiredParam<MaterialPropertyName>(
      "levelset_function_second_derivative",
      "Second derivative of the levelset function w.r.t. the Lagrange multiplier");
  params.addRequiredParam<MaterialPropertyName>(
      "materialization_function_derivative",
      "Derivative of the materialization function w.r.t. the levelset function");
  params.addRequiredParam<MaterialPropertyName>(
      "materialization_function_second_derivative",
      "Second derivative of the materialization function w.r.t. the levelset function");
  return params;
}

LevelsetMaterialization::LevelsetMaterialization(const InputParameters & parameters)
  : KernelScalarBase(parameters),
    _h_dot(_kappa_var_ptr->uDot()),
    _dh_dot_dh(_kappa_var_ptr->duDotDu()),
    _V_dot(getPostprocessorValue("volume_change_rate")),
    _L(getMaterialProperty<Real>("levelset_function")),
    _dL_dh(getMaterialProperty<Real>("levelset_function_derivative")),
    _d2L_dh2(getMaterialProperty<Real>("levelset_function_second_derivative")),
    _dM_dL(getMaterialProperty<Real>("materialization_function_derivative")),
    _d2M_dL2(getMaterialProperty<Real>("materialization_function_second_derivative"))
{
  mooseAssert(_kappa_var_ptr->order() == 1,
              "LevelsetMaterialization uses Lagrange multiplier with one and only one component");
}

Real
LevelsetMaterialization::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _L[_qp]);
}

Real
LevelsetMaterialization::computeQpJacobian()
{
  return _test[_i][_qp] * _phi[_j][_qp];
}

Real
LevelsetMaterialization::computeQpOffDiagJacobianScalar(unsigned int jvar)
{
  if (jvar != scalarVariable().number())
    return 0.;

  return -_test[_i][_qp] * _dL_dh[_qp];
}

void
LevelsetMaterialization::residualSetup()
{
  if (processor_id() != 0)
    return;
  std::vector<Real> r{_V_dot};

  addResiduals(_assembly, r, _kappa_var_ptr->dofIndices(), _kappa_var_ptr->scalingFactor());
}

Real
LevelsetMaterialization::computeScalarQpResidual()
{
  return -_dM_dL[_qp] * _dL_dh[_qp] * _h_dot[0];
}

Real
LevelsetMaterialization::computeScalarQpJacobian()
{
  return -_dM_dL[_qp] * _dL_dh[_qp] * _dh_dot_dh[0] - _dM_dL[_qp] * _d2L_dh2[_qp] * _h_dot[0];
}
