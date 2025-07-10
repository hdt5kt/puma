#pragma once

#include "PumaCoupledKernelInterface.h"
#include "Kernel.h"

template <class G>
class PumaCoupledDiffusionBase : public PumaCoupledKernelInterface<Kernel, G>
{
public:
  static InputParameters validParams();

  PumaCoupledDiffusionBase(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;
};
