//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "GenericFunctionMaterial.h"

class StationaryGenericFunctionMaterial : public GenericFunctionMaterial
{
public:
  static InputParameters validParams();

  StationaryGenericFunctionMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  std::vector<const MaterialProperty<Real> *> _properties_old;
};
