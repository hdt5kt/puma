#include "StationaryGenericFunctionMaterial.h"

registerMooseObject("PumaApp", StationaryGenericFunctionMaterial);

InputParameters
StationaryGenericFunctionMaterial::validParams()
{
  InputParameters params = GenericFunctionMaterial::validParams();
  return params;
}

StationaryGenericFunctionMaterial::StationaryGenericFunctionMaterial(
    const InputParameters & parameters)
  : GenericFunctionMaterial(parameters)
{
  _properties_old.resize(_num_props);
  for (auto i : make_range(_num_props))
    _properties_old[i] = &getMaterialPropertyOldByName<Real>(_prop_names[i]);
}

void
StationaryGenericFunctionMaterial::computeQpProperties()
{
  for (unsigned int i = 0; i < _num_props; i++)
    (*_properties[i])[_qp] = (*_properties_old[i])[_qp];
}
