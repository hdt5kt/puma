//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "PumaTestApp.h"
#include "PumaApp.h"
#include "Moose.h"
#include "AppFactory.h"

InputParameters
PumaTestApp::validParams()
{
  InputParameters params = PumaApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

PumaTestApp::PumaTestApp(InputParameters parameters) : PumaApp(parameters)
{
  PumaTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

PumaTestApp::~PumaTestApp() {}

void
PumaTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  PumaApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"PumaTestApp"});
    Registry::registerActionsTo(af, {"PumaTestApp"});
  }
}

void
PumaTestApp::registerApps()
{
  registerApp(PumaApp);
  registerApp(PumaTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
PumaTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  PumaTestApp::registerAll(f, af, s);
}
extern "C" void
PumaTestApp__registerApps()
{
  PumaTestApp::registerApps();
}
