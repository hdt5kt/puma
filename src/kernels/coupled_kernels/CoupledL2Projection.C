// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "CoupledL2Projection.h"

registerMooseObject("PumaApp", CoupledL2Projection);

InputParameters
CoupledL2Projection::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel>::validParams();
  params.addClassDescription("L2 projection of material properties with coupled variables");

  return params;
}

CoupledL2Projection::CoupledL2Projection(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel>(parameters)
{
}

Real
CoupledL2Projection::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _M[_qp]);
}

Real
CoupledL2Projection::computeQpJacobian()
{
  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      return _test[_i][_qp] * _phi[_j][_qp] * (1.0 - (*_dMdT)[_qp]);

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      return _test[_i][_qp] * _phi[_j][_qp] * (1.0 - (*_dMdP)[_qp]);

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      return _test[_i][_qp] * _phi[_j][_qp] * (1.0 - (*_dMdvf)[_qp]);

  return 0.0;
}

Real
CoupledL2Projection::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _T_id)
    return -_test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp];

  if (jvar == _P_id)
    return -_test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp];

  if (jvar == _vf_id)
    return -_test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp];

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return -_test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k));

  return 0.0;
}
