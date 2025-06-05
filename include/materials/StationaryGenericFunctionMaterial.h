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