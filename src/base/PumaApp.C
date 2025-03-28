#include "PumaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

#include "NEML2Action.h"
#include "NEML2ActionCommon.h"
#include "NEML2Utils.h"
#include "InputParameterWarehouse.h"

InputParameters
PumaApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  params.addCommandLineParam<bool>("parse_neml2_only",
                                   "--parse-neml2-only",
                                   "Executes the [NEML2] block in the input file and terminate.");
  return params;
}

PumaApp::PumaApp(InputParameters parameters) : MooseApp(parameters)
{
  PumaApp::registerAll(_factory, _action_factory, _syntax);
}

PumaApp::~PumaApp() {}

static void
associateSyntaxInner(Syntax & syntax, ActionFactory & /*action_factory*/)
{
  registerTask("parse_neml2", /*required=*/false);
  syntax.addDependency("add_material", "parse_neml2");
  syntax.addDependency("add_user_object", "parse_neml2");
  registerSyntax("NEML2ActionCommon", "NEML2");
  registerSyntax("NEML2Action", "NEML2/*");

  registerMooseAction("PumaApp", NEML2Action, "parse_neml2");
}

void
PumaApp::setupOptions()
{
  MooseApp::setupOptions();

  if (getInputFileNames().size())
  {
    if (getParam<bool>("parse_neml2_only"))
    {
      // Let parse_neml2 run before anything else, and stop after that.
      syntax().registerTaskName("parse_neml2");
      syntax().addDependency("determine_system_type", "parse_neml2");
      actionWarehouse().setFinalTask("parse_neml2");
    }
  }
}

void
PumaApp::runInputFile()
{
  MooseApp::runInputFile();

  if (getParam<bool>("parse_neml2_only"))
  {
    _early_exit_param = "--parse-neml2-only";
    _ready_to_exit = true;
  }
}

void
PumaApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<PumaApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"PumaApp"});
  Registry::registerActionsTo(af, {"PumaApp"});
  associateSyntaxInner(syntax, af);

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
