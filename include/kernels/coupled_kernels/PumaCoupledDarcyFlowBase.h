#pragma once

#include "Kernel.h"
#include "PumaCoupledKernelInterface.h"

template <class G>
class PumaCoupledDarcyFlowBase : public PumaCoupledKernelInterface<Kernel, G>
{
public:
  static InputParameters validParams();

  PumaCoupledDarcyFlowBase(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  unsigned int _coupled_id;

  const VariableGradient * _grad_var;
  const VariablePhiValue * _coupled_phi;
  const VariablePhiGradient * _coupled_grad_phi;

  Real _coeff;
};
