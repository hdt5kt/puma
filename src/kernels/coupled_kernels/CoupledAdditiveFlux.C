// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "CoupledAdditiveFlux.h"

registerMooseObject("PumaApp", CoupledAdditiveFlux);

InputParameters
CoupledAdditiveFlux::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel>::validParams();
  params.addClassDescription("The additive term for the flux in the diffusion equation");

  params.addRequiredParam<RealVectorValue>("value", "Vector value added to the flux");

  return params;
}

CoupledAdditiveFlux::CoupledAdditiveFlux(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel>(parameters), _g(getParam<RealVectorValue>("value"))
{
}

Real
CoupledAdditiveFlux::computeQpResidual()
{
  return _grad_test[_i][_qp] * _M[_qp] * _g;
}

Real
CoupledAdditiveFlux::computeQpJacobian()
{
  auto R = _grad_test[_i][_qp] * _g * _phi[_j][_qp];

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
CoupledAdditiveFlux::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (isCoupled("temperature"))
    if (jvar == _T_id)
      return _grad_test[_i][_qp] * (*_dMdT)[_qp] * (*_T_phi)[_j][_qp] * _g;

  if (isCoupled("pressure"))
    if (jvar == _P_id)
      return _grad_test[_i][_qp] * (*_dMdP)[_qp] * (*_P_phi)[_j][_qp] * _g;

  if (isCoupled("fluid_fraction"))
    if (jvar == _vf_id)
      return _grad_test[_i][_qp] * (*_dMdvf)[_qp] * (*_vf_phi)[_j][_qp] * _g;

  if (_ndisp > 0)
    for (decltype(_ndisp) k = 0; k < _ndisp; ++k)
      if (jvar == _disp_id[k])
        return _grad_test[_i][_qp] * (*_dMdF)[_qp].doubleContraction(gradTrial(k)) * _g;

  return 0.0;
}