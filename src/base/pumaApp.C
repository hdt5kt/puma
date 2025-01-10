#include "pumaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
pumaApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

pumaApp::pumaApp(InputParameters parameters) : MooseApp(parameters)
{
  pumaApp::registerAll(_factory, _action_factory, _syntax);
}

pumaApp::~pumaApp() {}

void
pumaApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<pumaApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"pumaApp"});
  Registry::registerActionsTo(af, {"pumaApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
pumaApp::registerApps()
{
  registerApp(pumaApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
pumaApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  pumaApp::registerAll(f, af, s);
}
extern "C" void
pumaApp__registerApps()
{
  pumaApp::registerApps();
}
