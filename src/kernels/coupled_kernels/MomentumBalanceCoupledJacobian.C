//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MomentumBalanceCoupledJacobian.h"

// MOOSE includes
#include "Assembly.h"
#include "MooseVariableFE.h"
#include "RankTwoTensor.h"

#include "libmesh/quadrature.h"

registerMooseObject("MooseApp", MomentumBalanceCoupledJacobian);

InputParameters
MomentumBalanceCoupledJacobian::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Add in the coupled variables to the off diagonal of the momentum "
                             "balance - stress divergence condition. Input variable has to be the "
                             "correct displacements variables");

  params.addCoupledVar("temperature", "The temperature");
  params.addCoupledVar("pressure", "The pressure");
  params.addCoupledVar("fluid_fraction", "Volume fraction of the product");

  params.addRequiredParam<unsigned int>("component",
                                        "Displacement component (0 = x, 1 = y, 2 = z)");

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

  return params;
}

MomentumBalanceCoupledJacobian::MomentumBalanceCoupledJacobian(const InputParameters & parameters)
  : Kernel(parameters), _component(getParam<unsigned int>("component"))
{
  if (isCoupled("temperature"))
  {
    if (!isParamValid("material_temperature_derivative"))
      paramError("material_temperature_derivative",
                 "If temperature is coupled, material_temperature_derivative must be provided.");
    _T_id = coupled("temperature");
    _T_phi = &getVar("temperature", 0)->phi();
    _dSdT = &getMaterialProperty<RankTwoTensor>("material_temperature_derivative");
  }

  if (isCoupled("pressure"))
  {
    if (!isParamValid("material_pressure_derivative"))
      paramError("material_pressure_derivative",
                 "If pressure is coupled, material_pressure_derivative must be provided.");
    _P_id = coupled("pressure");
    _P_phi = &getVar("pressure", 0)->phi();
    _dSdP = &getMaterialProperty<RankTwoTensor>("material_pressure_derivative");
  }

  if (isCoupled("fluid_fraction"))
  {
    if (!isParamValid("material_fluid_fraction_derivative"))
      paramError(
          "material_fluid_fraction_derivative",
          "If fluid_fraction is coupled, material_fluid_fraction_derivative must be provided.");
    _vf_id = coupled("fluid_fraction");
    _vf_phi = &getVar("fluid_fraction", 0)->phi();
    _dSdvf = &getMaterialProperty<RankTwoTensor>("material_fluid_fraction_derivative");
  }
}

Real
MomentumBalanceCoupledJacobian::computeQpResidual()
{
  return 0.0;
}

Real
MomentumBalanceCoupledJacobian::computeQpJacobian()
{
  return 0.0;
}

Real
MomentumBalanceCoupledJacobian::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (isCoupled("temperature"))
    if (jvar == _T_id)
      // return _grad_test[_i][_qp] * (*_dSdT)[_qp].row(_component) * (*_T_phi)[_j][_qp];
      return gradTest(_component).row(_component) * (*_dSdT)[_qp].row(_component) *
             (*_T_phi)[_j][_qp];

  if (isCoupled("pressure"))
    if (jvar == _P_id)
      // return _grad_test[_i][_qp] * (*_dSdP)[_qp].row(_component) * (*_P_phi)[_j][_qp];
      return gradTest(_component).row(_component) * (*_dSdP)[_qp].row(_component) *
             (*_P_phi)[_j][_qp];

  if (isCoupled("fluid_fraction"))
    if (jvar == _vf_id)
      // return _grad_test[_i][_qp] * (*_dSdvf)[_qp].row(_component) * (*_vf_phi)[_j][_qp];
      return gradTest(_component).row(_component) * (*_dSdvf)[_qp].row(_component) *
             (*_vf_phi)[_j][_qp];

  return 0.0;
}

RankTwoTensor
MomentumBalanceCoupledJacobian::gradTest(unsigned int component)
{
  return GradientOperatorCartesian::gradOp(
      component, _grad_test[_i][_qp], _test[_i][_qp], _q_point[_qp]);
}