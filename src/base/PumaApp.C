//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "PumaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"

InputParameters
PumaApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  return params;
}

PumaApp::PumaApp(InputParameters parameters) : MooseApp(parameters)
{
  PumaApp::registerAll(_factory, _action_factory, _syntax);
}

void
PumaApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<PumaApp>(f, af, syntax);

  Registry::registerObjectsTo(f, {"PumaApp"});
  Registry::registerActionsTo(af, {"PumaApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
PumaApp::registerApps()
{
  registerApp(PumaApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
PumaApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  PumaApp::registerAll(f, af, s);
}
extern "C" void
PumaApp__registerApps()
{
  PumaApp::registerApps();
}
