#pragma once

#include "MooseApp.h"

class PumaApp : public MooseApp
{
public:
  static InputParameters validParams();

  PumaApp(InputParameters parameters);

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & syntax);
};
