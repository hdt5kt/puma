//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#pragma once

#include "PumaApp.h"

class PumaTestApp : public PumaApp
{
public:
  static InputParameters validParams();

  PumaTestApp(InputParameters parameters);
  virtual ~PumaTestApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs = false);
};
