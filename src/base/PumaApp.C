#include "PumaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
PumaApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

PumaApp::PumaApp(InputParameters parameters) : MooseApp(parameters)
{
  PumaApp::registerAll(_factory, _action_factory, _syntax);
}

PumaApp::~PumaApp() {}

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
