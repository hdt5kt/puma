//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "PumaCoupledTimeDerivativeBase.h"
#include "CoordSysInstantiation.h"

template <class G>
InputParameters
PumaCoupledTimeDerivativeBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<TimeKernel, G>::validParams();
  params.addClassDescription(
      "Time derivative with a material constant for different coupled variables.");
  return params;
}

template <class G>
PumaCoupledTimeDerivativeBase<G>::PumaCoupledTimeDerivativeBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<TimeKernel, G>(parameters)
{
}

template <class G>
Real
PumaCoupledTimeDerivativeBase<G>::computeQpResidual()
{
  return this->_test[this->_i][this->_qp] * this->_M[this->_qp] * this->_u_dot[this->_qp];
}

template <class G>
Real
PumaCoupledTimeDerivativeBase<G>::computeQpJacobian()
{
  auto R = this->_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
           this->_du_dot_du[this->_qp] * this->_M[this->_qp];

  if (this->isCoupled("temperature") && this->_T_id == this->variable().number())
    R += this->_test[this->_i][this->_qp] * (*this->_T_phi)[this->_j][this->_qp] *
         this->_u_dot[this->_qp] * (*this->_dMdT)[this->_qp];

  if (this->isCoupled("pressure") && this->_P_id == this->variable().number())
    R += this->_test[this->_i][this->_qp] * (*this->_P_phi)[this->_j][this->_qp] *
         this->_u_dot[this->_qp] * (*this->_dMdP)[this->_qp];

  if (this->isCoupled("fluid_fraction") && this->_vf_id == this->variable().number())
    R += this->_test[this->_i][this->_qp] * (*this->_vf_phi)[this->_j][this->_qp] *
         this->_u_dot[this->_qp] * (*this->_dMdvf)[this->_qp];

  return R;
}

template <class G>
Real
PumaCoupledTimeDerivativeBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (this->isCoupled("temperature") && jvar == this->_T_id)
    return this->_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
           (*this->_T_phi)[this->_j][this->_qp] * this->_u_dot[this->_qp];

  if (this->isCoupled("pressure") && jvar == this->_P_id)
    return this->_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
           (*this->_P_phi)[this->_j][this->_qp] * this->_u_dot[this->_qp];

  if (this->isCoupled("fluid_fraction") && jvar == this->_vf_id)
    return this->_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
           (*this->_vf_phi)[this->_j][this->_qp] * this->_u_dot[this->_qp];

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return this->_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k)) *
               this->_u_dot[this->_qp];

  return 0.0;
}

INSTANTIATE_PUMA_KERNEL(PumaCoupledTimeDerivative,
                        PumaCoupledTimeDerivativeBase,
                        GradientOperatorCartesian,
                        Moose::COORD_XYZ,
                        "Cartesian");

INSTANTIATE_PUMA_KERNEL(PumaCoupledTimeDerivativeAxisymmetricCylindrical,
                        PumaCoupledTimeDerivativeBase,
                        GradientOperatorAxisymmetricCylindrical,
                        Moose::COORD_RZ,
                        "Cylindrical");

INSTANTIATE_PUMA_KERNEL(PumaCoupledTimeDerivativeCentrosymmetricSpherical,
                        PumaCoupledTimeDerivativeBase,
                        GradientOperatorCentrosymmetricSpherical,
                        Moose::COORD_RSPHERICAL,
                        "Spherical");
