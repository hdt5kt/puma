//* This file is part of PUMA
//* https://github.com/applied-material-modeling/puma
//*
//* Licensed under the MIT license, please see LICENSE for details
//* https://opensource.org/license/MIT

#include "PumaTestApp.h"
#include "MooseMain.h"

// Begin the main program.
int
main(int argc, char * argv[])
{
  return Moose::main<PumaTestApp>(argc, argv);
}
