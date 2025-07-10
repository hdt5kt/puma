#include "CoupledMaterialSourceBase.h"
#include "CoordSysInstantiation.h"

template <typename G>
InputParameters
CoupledMaterialSourceBase<G>::validParams()
{
  InputParameters params = PumaCoupledKernelInterface<Kernel, G>::validParams();
  params.addClassDescription(
      "Source term defined by the material property for different coupled variables");
  params.addParam<Real>("coefficient", -1, "Coefficient to be multiplied to the source");
  return params;
}

template <typename G>
CoupledMaterialSourceBase<G>::CoupledMaterialSourceBase(const InputParameters & parameters)
  : PumaCoupledKernelInterface<Kernel, G>(parameters),
    _coeff(this->template getParam<Real>("coefficient"))
{
}

template <typename G>
Real
CoupledMaterialSourceBase<G>::computeQpResidual()
{
  return _coeff * this->_test[this->_i][this->_qp] * this->_M[this->_qp];
}

template <typename G>
Real
CoupledMaterialSourceBase<G>::computeQpJacobian()
{
  auto R = _coeff * this->_test[this->_i][this->_qp] * this->_phi[this->_j][this->_qp];

  if (this->isCoupled("temperature") && this->_T_id == this->variable().number())
    R *= (*this->_dMdT)[this->_qp];

  if (this->isCoupled("pressure") && this->_P_id == this->variable().number())
    R *= (*this->_dMdP)[this->_qp];

  if (this->isCoupled("fluid_fraction") && this->_vf_id == this->variable().number())
    R *= (*this->_dMdvf)[this->_qp];

  return R;
}

template <typename G>
Real
CoupledMaterialSourceBase<G>::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (this->isCoupled("temperature") && jvar == this->_T_id)
    return _coeff * this->_test[this->_i][this->_qp] * (*this->_dMdT)[this->_qp] *
           (*this->_T_phi)[this->_j][this->_qp];

  if (this->isCoupled("pressure") && jvar == this->_P_id)
    return _coeff * this->_test[this->_i][this->_qp] * (*this->_dMdP)[this->_qp] *
           (*this->_P_phi)[this->_j][this->_qp];

  if (this->isCoupled("fluid_fraction") && jvar == this->_vf_id)
    return _coeff * this->_test[this->_i][this->_qp] * (*this->_dMdvf)[this->_qp] *
           (*this->_vf_phi)[this->_j][this->_qp];

  if (this->_ndisp > 0)
    for (decltype(this->_ndisp) k = 0; k < this->_ndisp; ++k)
      if (jvar == this->_disp_id[k])
        return _coeff * this->_test[this->_i][this->_qp] *
               (*this->_dMdF)[this->_qp].doubleContraction(this->gradTrial(k));

  return 0.0;
}

INSTANTIATE_PUMA_KERNEL(CoupledMaterialSource,
                        CoupledMaterialSourceBase,
                        GradientOperatorCartesian,
                        Moose::COORD_XYZ,
                        "Cartesian");

INSTANTIATE_PUMA_KERNEL(CoupledMaterialSourceAxisymmetricCylindrical,
                        CoupledMaterialSourceBase,
                        GradientOperatorAxisymmetricCylindrical,
                        Moose::COORD_RZ,
                        "Cylindrical");

INSTANTIATE_PUMA_KERNEL(CoupledMaterialSourceCentrosymmetricSpherical,
                        CoupledMaterialSourceBase,
                        GradientOperatorCentrosymmetricSpherical,
                        Moose::COORD_RSPHERICAL,
                        "Spherical");
