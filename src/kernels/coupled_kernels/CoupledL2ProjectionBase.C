// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "CoupledL2ProjectionBase.h"

template <typename G>
InputParameters
CoupledL2ProjectionBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel, G>::validParams();
  params.addClassDescription("L2 projection of material properties with coupled variables");
  return params;
}

template <typename G>
CoupledL2ProjectionBase<G>::CoupledL2ProjectionBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel, G>(parameters)
{
}

template <typename G>
Real
CoupledL2ProjectionBase<G>::computeQpResidual()
{
  return this->_test[this->_i][this->_qp] * (this->_u[this->_qp] - this->_M[this->_qp]);
}

template <typename G>
Real
CoupledL2ProjectionBase<G>::computeQpJacobian()
{
  if (this->isCoupled("temperature"))
    if (this->_T_id == this->variable().number())
      return this->_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (1.0 - (*this->_dMdT)[this->_qp]);

  if (this->isCoupled("pressure"))
    if (this->_P_id == this->variable().number())
      return this->_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (1.0 - (*this->_dMdP)[this->_qp]);

  if (this->isCoupled("fluid_fraction"))
    if (this->_vf_id == this->variable().number())
      return this->_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp] *
             (1.0 - (*this->_dMdvf)[this->_qp]);

  return 0.0;
}

template <typename G>
Real
CoupledL2ProjectionBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (this->isCoupled("temperature") && jvar == this->_T_id)
    return -this->_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
           (*this->_T_phi)[this->_j][this->_qp];

  if (this->isCoupled("pressure") && jvar == this->_P_id)
    return -this->_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
           (*this->_P_phi)[this->_j][this->_qp];

  if (this->isCoupled("fluid_fraction") && jvar == this->_vf_id)
    return -this->_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
           (*this->_vf_phi)[this->_j][this->_qp];

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return -this->_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k));

  return 0.0;
}

// Explicit instantiations
template class CoupledL2ProjectionBase<GradientOperatorCartesian>;
template class CoupledL2ProjectionBase<GradientOperatorAxisymmetricCylindrical>;
template class CoupledL2ProjectionBase<GradientOperatorCentrosymmetricSpherical>;