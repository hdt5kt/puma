//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

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
