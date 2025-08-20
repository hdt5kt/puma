#include "PumaCoupledDiffusionBase.h"
#include "CoordSysInstantiation.h"

template <class G>
InputParameters
PumaCoupledDiffusionBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel, G>::validParams();
  params.addClassDescription("Diffusion equation with diffusion coefficients as material "
                             "properties for coupled variables");
  return params;
}

template <class G>
PumaCoupledDiffusionBase<G>::PumaCoupledDiffusionBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel, G>(parameters)
{
}

template <class G>
Real
PumaCoupledDiffusionBase<G>::computeQpResidual()
{
  return this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] * this->_grad_u[this->_qp];
}

template <class G>
Real
PumaCoupledDiffusionBase<G>::computeQpJacobian()
{
  auto R = this->_grad_test[this->_i][this->_qp] * this->_M[this->_qp] *
           this->_grad_phi[this->_j][this->_qp];

  if (this->isCoupled("temperature") && this->_T_id == this->variable().number())
    R += this->_grad_test[this->_i][this->_qp] * (*this->_T_phi)[this->_j][this->_qp] *
         this->_grad_u[this->_qp] * (*this->_dMdT)[this->_qp];

  if (this->isCoupled("pressure") && this->_P_id == this->variable().number())
    R += this->_grad_test[this->_i][this->_qp] * (*this->_P_phi)[this->_j][this->_qp] *
         this->_grad_u[this->_qp] * (*this->_dMdP)[this->_qp];

  if (this->isCoupled("fluid_fraction") && this->_vf_id == this->variable().number())
    R += this->_grad_test[this->_i][this->_qp] * (*this->_vf_phi)[this->_j][this->_qp] *
         this->_grad_u[this->_qp] * (*this->_dMdvf)[this->_qp];

  return R;
}

template <class G>
Real
PumaCoupledDiffusionBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (this->isCoupled("temperature") && jvar == this->_T_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
           (*this->_T_phi)[this->_j][this->_qp] * this->_grad_u[this->_qp];

  if (this->isCoupled("pressure") && jvar == this->_P_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
           (*this->_P_phi)[this->_j][this->_qp] * this->_grad_u[this->_qp];

  if (this->isCoupled("fluid_fraction") && jvar == this->_vf_id)
    return this->_grad_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
           (*this->_vf_phi)[this->_j][this->_qp] * this->_grad_u[this->_qp];

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return this->_grad_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k)) *
               this->_grad_u[this->_qp];

  return 0.0;
}

INSTANTIATE_PUMA_KERNEL(PumaCoupledDiffusion,
                        PumaCoupledDiffusionBase,
                        GradientOperatorCartesian,
                        Moose::COORD_XYZ,
                        "Cartesian");

INSTANTIATE_PUMA_KERNEL(PumaCoupledDiffusionAxisymmetricCylindrical,
                        PumaCoupledDiffusionBase,
                        GradientOperatorAxisymmetricCylindrical,
                        Moose::COORD_RZ,
                        "Cylindrical");

INSTANTIATE_PUMA_KERNEL(PumaCoupledDiffusionCentrosymmetricSpherical,
                        PumaCoupledDiffusionBase,
                        GradientOperatorCentrosymmetricSpherical,
                        Moose::COORD_RSPHERICAL,
                        "Spherical");
