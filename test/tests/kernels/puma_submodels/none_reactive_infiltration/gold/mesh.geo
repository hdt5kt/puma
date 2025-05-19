// Input ----------------------------------------------------------------

n_core = 100;
x_core = 10; //cm
core_elsize = x_core/n_core;

//  core part -----------------------------------------------------------

Point(1) = {0.0, 0.0, 0.0, core_elsize};
Point(2) = {x_core, 0, 0, core_elsize};
Point(3) = {x_core, x_core, 0, core_elsize};
Point(4) = {0, x_core, 0, core_elsize};

Line(1) = {1, 2}; Transfinite Curve{1} = n_core;
Line(2) = {2, 3}; Transfinite Curve{2} = n_core;
Line(3) = {3, 4}; Transfinite Curve{3} = n_core;
Line(4) = {4, 1}; Transfinite Curve{4} = n_core;
Line Loop(1) = {1, 2, 3, 4};

Plane Surface(1) = {1};
Transfinite Surface{1} = {1,2,3,4};
Recombine Surface{1};

// Assign physical groups ------------------------------------------------
Physical Surface("cores") = 1;

Physical Curve("core_bottom") = {1};

Mesh 2;
Save "core.msh";
