//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "pumaTestApp.h"
#include "pumaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
pumaTestApp::validParams()
{
  InputParameters params = pumaApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

pumaTestApp::pumaTestApp(InputParameters parameters) : MooseApp(parameters)
{
  pumaTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

pumaTestApp::~pumaTestApp() {}

void
pumaTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  pumaApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"pumaTestApp"});
    Registry::registerActionsTo(af, {"pumaTestApp"});
  }
}

void
pumaTestApp::registerApps()
{
  registerApp(pumaApp);
  registerApp(pumaTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
pumaTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  pumaTestApp::registerAll(f, af, s);
}
extern "C" void
pumaTestApp__registerApps()
{
  pumaTestApp::registerApps();
}
