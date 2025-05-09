//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PumaCoupledTimeDerivative.h"

registerMooseObject("MooseApp", PumaCoupledTimeDerivative);

InputParameters
PumaCoupledTimeDerivative::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<TimeKernel>::validParams();
  params.addClassDescription(
      "Time derivative with a material constant for different coupled variables.");

  return params;
}

PumaCoupledTimeDerivative::PumaCoupledTimeDerivative(const InputParameters & parameters)
  : PumaCoupledKernelInterface<TimeKernel>(parameters)
{
}

Real
PumaCoupledTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * _M[_qp] * _u_dot[_qp];
}

Real
PumaCoupledTimeDerivative::computeQpJacobian()
{
  auto R = _test[_i][_qp] * _phi[_j][_qp] * _du_dot_du[_qp] * _M[_qp];

  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      R += _test[_i][_qp] * (*_T_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdT)[_qp];

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      R += _test[_i][_qp] * (*_P_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdP)[_qp];

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      R += _test[_i][_qp] * (*_vf_phi)[_j][_qp] * _u_dot[_qp] * (*_dMdvf)[_qp];

  return R;
}

Real
PumaCoupledTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _T_id)
    return _test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp] * _u_dot[_qp];

  if (jvar == _P_id)
    return _test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp] * _u_dot[_qp];

  if (jvar == _vf_id)
    return _test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp] * _u_dot[_qp];

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return _test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k)) * _u_dot[_qp];

  return 0.0;
}