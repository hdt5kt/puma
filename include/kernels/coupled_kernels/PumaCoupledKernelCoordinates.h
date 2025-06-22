#pragma once

#define DEFINE_PUMA_KERNEL_WRAPPER(WrapperName, BaseTemplate, OperatorType, CoordEnum, CoordName)  \
  class WrapperName : public BaseTemplate<OperatorType>                                            \
  {                                                                                                \
  public:                                                                                          \
    static InputParameters validParams();                                                          \
    WrapperName(const InputParameters & parameters);                                               \
    virtual void initialSetup() override;                                                          \
  };                                                                                               \
                                                                                                   \
  inline InputParameters WrapperName::validParams()                                                \
  {                                                                                                \
    InputParameters params = BaseTemplate<OperatorType>::validParams();                            \
    params.addClassDescription(#WrapperName " specialized for " CoordName " coordinates.");        \
    return params;                                                                                 \
  }                                                                                                \
                                                                                                   \
  inline WrapperName::WrapperName(const InputParameters & parameters)                              \
    : BaseTemplate<OperatorType>(parameters)                                                       \
  {                                                                                                \
  }                                                                                                \
                                                                                                   \
  inline void WrapperName::initialSetup()                                                          \
  {                                                                                                \
    if (getBlockCoordSystem() != CoordEnum)                                                        \
      mooseError(#WrapperName " should only act in " CoordName " coordinates.");                   \
  }
