//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "CoupledAdditiveFluxBase.h"
#include "CoordSysInstantiation.h"

template <class G>
InputParameters
CoupledAdditiveFluxBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel, G>::validParams();
  params.addClassDescription("The additive term for the flux in the diffusion equation");
  params.addRequiredParam<RealVectorValue>("value", "Vector value added to the flux");
  return params;
}

template <class G>
CoupledAdditiveFluxBase<G>::CoupledAdditiveFluxBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel, G>(parameters),
    _g(this->template getParam<RealVectorValue>("value"))
{
}

template <class G>
Real
CoupledAdditiveFluxBase<G>::computeQpResidual()
{
  return this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] * _g;
}

template <class G>
Real
CoupledAdditiveFluxBase<G>::computeQpJacobian()
{
  auto R = this->_grad_test[this->_i][this->_qp] * _g * this->_phi[this->_j][this->_qp];

  if (this->isCoupled("temperature") && this->_T_id == this->variable().number())
    R *= (*this->_dMdT)[this->_qp];

  if (this->isCoupled("pressure") && this->_P_id == this->variable().number())
    R *= (*this->_dMdP)[this->_qp];

  if (this->isCoupled("fluid_fraction") && this->_vf_id == this->variable().number())
    R *= (*this->_dMdvf)[this->_qp];

  return R;
}

template <class G>
Real
CoupledAdditiveFluxBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (this->isCoupled("temperature") && jvar == this->_T_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
           (*this->_T_phi)[this->_j][this->_qp] * _g;

  if (this->isCoupled("pressure") && jvar == this->_P_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
           (*this->_P_phi)[this->_j][this->_qp] * _g;

  if (this->isCoupled("fluid_fraction") && jvar == this->_vf_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
           (*this->_vf_phi)[this->_j][this->_qp] * _g;

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return this->_grad_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k)) * _g;

  return 0.0;
}

INSTANTIATE_PUMA_KERNEL(CoupledAdditiveFlux,
                        CoupledAdditiveFluxBase,
                        GradientOperatorCartesian,
                        Moose::COORD_XYZ,
                        "Cartesian");

INSTANTIATE_PUMA_KERNEL(CoupledAdditiveFluxAxisymmetricCylindrical,
                        CoupledAdditiveFluxBase,
                        GradientOperatorAxisymmetricCylindrical,
                        Moose::COORD_RZ,
                        "Cylindrical");

INSTANTIATE_PUMA_KERNEL(CoupledAdditiveFluxCentrosymmetricSpherical,
                        CoupledAdditiveFluxBase,
                        GradientOperatorCentrosymmetricSpherical,
                        Moose::COORD_RSPHERICAL,
                        "Spherical");
