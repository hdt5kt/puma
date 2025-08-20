#pragma once

#include "GradientOperator.h"

#define INSTANTIATE_PUMA_KERNEL(WrapperName, BaseTemplate, OperatorType, CoordEnum, CoordName)     \
  class WrapperName : public BaseTemplate<OperatorType>                                            \
  {                                                                                                \
  public:                                                                                          \
    static InputParameters validParams();                                                          \
    WrapperName(const InputParameters & parameters);                                               \
    void initialSetup() override;                                                                  \
  };                                                                                               \
                                                                                                   \
  InputParameters WrapperName::validParams()                                                       \
  {                                                                                                \
    InputParameters params = BaseTemplate<OperatorType>::validParams();                            \
    params.addClassDescription(#WrapperName " specialized for " CoordName " coordinates.");        \
    return params;                                                                                 \
  }                                                                                                \
                                                                                                   \
  WrapperName::WrapperName(const InputParameters & parameters)                                     \
    : BaseTemplate<OperatorType>(parameters)                                                       \
  {                                                                                                \
  }                                                                                                \
                                                                                                   \
  void WrapperName::initialSetup()                                                                 \
  {                                                                                                \
    BaseTemplate<OperatorType>::initialSetup();                                                    \
                                                                                                   \
    if (getBlockCoordSystem() != CoordEnum)                                                        \
      mooseError(#WrapperName " should only act in " CoordName " coordinates.");                   \
  }                                                                                                \
                                                                                                   \
  registerMooseObject("PumaApp", WrapperName)
