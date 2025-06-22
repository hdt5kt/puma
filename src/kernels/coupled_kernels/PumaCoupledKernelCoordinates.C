#include "PumaCoupledKernelCoordinates.h"

#include "PumaCoupledDarcyFlowBase.h"
#include "CoupledAdditiveFluxBase.h"
#include "CoupledL2ProjectionBase.h"
#include "CoupledMaterialSourceBase.h"
#include "PumaCoupledDiffusionBase.h"
#include "PumaCoupledTimeDerivativeBase.h"

// -------- Darcy Flow Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDarcyFlow,
                           PumaCoupledDarcyFlowBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDarcyFlowAxisymmetricCylindrical,
                           PumaCoupledDarcyFlowBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDarcyFlowCentrosymmetricSpherical,
                           PumaCoupledDarcyFlowBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- Additive Flux Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(CoupledAdditiveFlux,
                           CoupledAdditiveFluxBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledAdditiveFluxAxisymmetricCylindrical,
                           CoupledAdditiveFluxBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledAdditiveFluxCentrosymmetricSpherical,
                           CoupledAdditiveFluxBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- L2 Projection Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(CoupledL2Projection,
                           CoupledL2ProjectionBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledL2ProjectionAxisymmetricCylindrical,
                           CoupledL2ProjectionBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledL2ProjectionCentrosymmetricSpherical,
                           CoupledL2ProjectionBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- Material Source Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(CoupledMaterialSource,
                           CoupledMaterialSourceBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledMaterialSourceAxisymmetricCylindrical,
                           CoupledMaterialSourceBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(CoupledMaterialSourceCentrosymmetricSpherical,
                           CoupledMaterialSourceBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- Diffusion Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDiffusion,
                           PumaCoupledDiffusionBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDiffusionAxisymmetricCylindrical,
                           PumaCoupledDiffusionBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledDiffusionCentrosymmetricSpherical,
                           PumaCoupledDiffusionBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- Time derivative Wrappers --------
DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledTimeDerivative,
                           PumaCoupledTimeDerivativeBase,
                           GradientOperatorCartesian,
                           Moose::COORD_XYZ,
                           "Cartesian");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledTimeDerivativeAxisymmetricCylindrical,
                           PumaCoupledTimeDerivativeBase,
                           GradientOperatorAxisymmetricCylindrical,
                           Moose::COORD_RZ,
                           "Cylindrical");

DEFINE_PUMA_KERNEL_WRAPPER(PumaCoupledTimeDerivativeCentrosymmetricSpherical,
                           PumaCoupledTimeDerivativeBase,
                           GradientOperatorCentrosymmetricSpherical,
                           Moose::COORD_RSPHERICAL,
                           "Spherical");

// -------- Registration --------
registerMooseObject("PumaApp", PumaCoupledDarcyFlow);
registerMooseObject("PumaApp", PumaCoupledDarcyFlowAxisymmetricCylindrical);
registerMooseObject("PumaApp", PumaCoupledDarcyFlowCentrosymmetricSpherical);

registerMooseObject("PumaApp", CoupledAdditiveFlux);
registerMooseObject("PumaApp", CoupledAdditiveFluxAxisymmetricCylindrical);
registerMooseObject("PumaApp", CoupledAdditiveFluxCentrosymmetricSpherical);

registerMooseObject("PumaApp", CoupledL2Projection);
registerMooseObject("PumaApp", CoupledL2ProjectionAxisymmetricCylindrical);
registerMooseObject("PumaApp", CoupledL2ProjectionCentrosymmetricSpherical);

registerMooseObject("PumaApp", CoupledMaterialSource);
registerMooseObject("PumaApp", CoupledMaterialSourceAxisymmetricCylindrical);
registerMooseObject("PumaApp", CoupledMaterialSourceCentrosymmetricSpherical);

registerMooseObject("PumaApp", PumaCoupledDiffusion);
registerMooseObject("PumaApp", PumaCoupledDiffusionAxisymmetricCylindrical);
registerMooseObject("PumaApp", PumaCoupledDiffusionCentrosymmetricSpherical);

registerMooseObject("PumaApp", PumaCoupledTimeDerivative);
registerMooseObject("PumaApp", PumaCoupledTimeDerivativeAxisymmetricCylindrical);
registerMooseObject("PumaApp", PumaCoupledTimeDerivativeCentrosymmetricSpherical);
