// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "CoupledMaterialSource.h"

registerMooseObject("PumaApp", CoupledMaterialSource);

InputParameters
CoupledMaterialSource::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel>::validParams();
  params.addClassDescription(
      "Source term defined by the material property for different coupled variables");
  params.addParam<Real>("coefficient", -1, "Coefficient to be multiplied to the source");
  return params;
}

CoupledMaterialSource::CoupledMaterialSource(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel>(parameters), _coeff(getParam<Real>("coefficient"))
{
}

Real
CoupledMaterialSource::computeQpResidual()
{
  return _coeff * _test[_i][_qp] * _M[_qp];
}

Real
CoupledMaterialSource::computeQpJacobian()
{
  auto R = _coeff * _test[_i][_qp] * _phi[_j][_qp];

  if (isCoupled("temperature")) // without checking for isCoupled, segmentation fault will happened
                                // if the coupled variables are not definied in the input file. This
                                // is to avoid using unnecessary auxiliary variables.
    if (_T_id == variable().number())
      R *= (*_dMdT)[_qp];

  if (isCoupled("pressure"))
    if (_P_id == variable().number())
      R *= (*_dMdP)[_qp];

  if (isCoupled("fluid_fraction"))
    if (_vf_id == variable().number())
      R *= (*_dMdvf)[_qp];

  return R;
}

Real
CoupledMaterialSource::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _T_id)
    return _coeff * _test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp];

  if (jvar == _P_id)
    return _coeff * _test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp];

  if (jvar == _vf_id)
    return _coeff * _test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp];

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return -_test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k));

  return 0.0;
}