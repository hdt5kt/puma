// Input ----------------------------------------------------------------

n_core = 51;
x_core = 10; //cm
core_elsize = x_core/n_core;

n_pool = 10;
dx_pool = 3; //cm
pool_elsize = dx_pool/n_pool;

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

//  melt pool part -----------------------------------------------------------
Point(5) = {-dx_pool, -dx_pool, 0};
Point(6) = {x_core+dx_pool, -dx_pool, 0};
Point(7) = {x_core+dx_pool, x_core+dx_pool, 0};
Point(8) = {-dx_pool, x_core+dx_pool, 0};

Point(156) = {0, -dx_pool, 0};
Point(256) = {x_core,-dx_pool, 0};
Point(267) = {x_core+dx_pool, 0, 0};
Point(158) = {-dx_pool, 0, 0};

Point(367) = {x_core+dx_pool, x_core, 0};
Point(378) = {x_core,x_core+dx_pool, 0};
Point(478) = {0, x_core+dx_pool, 0};
Point(458) = {-dx_pool, x_core, 0};

Line(50156) = {5,156}; Transfinite Curve{50156} = n_pool;
Line(15601) = {156,1}; Transfinite Curve{15601} = n_pool;
Line(10158) = {1,158}; Transfinite Curve{10158} = n_pool;
Line(15805) = {158,5}; Transfinite Curve{15805} = n_pool;

Line(25606) = {256,6}; Transfinite Curve{25606} = n_pool;
Line(60267) = {6,267}; Transfinite Curve{60267} = n_pool;
Line(26702) = {267,2}; Transfinite Curve{26702} = n_pool;
Line(20256) = {2,256}; Transfinite Curve{20256} = n_pool;

Line(30367) = {3,367}; Transfinite Curve{30367} = n_pool;
Line(36707) = {367,7}; Transfinite Curve{36707} = n_pool;
Line(70378) = {7,378}; Transfinite Curve{70378} = n_pool;
Line(37803) = {378,3}; Transfinite Curve{37803} = n_pool;

Line(45804) = {458,4}; Transfinite Curve{45804} = n_pool;
Line(40478) = {4,478}; Transfinite Curve{40478} = n_pool;
Line(47808) = {478,8}; Transfinite Curve{47808} = n_pool;
Line(80458) = {8,458}; Transfinite Curve{80458} = n_pool;

Line(1560256) = {156,256}; Transfinite Curve{1560256} = n_core;
Line(4580158) = {458,158}; Transfinite Curve{4580158} = n_core;
Line(2670367) = {267,367}; Transfinite Curve{2670367} = n_core;
Line(3780478) = {378,478}; Transfinite Curve{3780478} = n_core;

Line Loop(2) = {50156, 15601, 10158, 15805};
Plane Surface(2) = {2};
Transfinite Surface{2} = {2};
Recombine Surface{2};

Line Loop(3) = {25606, 60267, 26702, 20256};
Plane Surface(3) = {3};
Transfinite Surface{3} = {3};
Recombine Surface{3};

Line Loop(4) = {30367, 36707, 70378, 37803};
Plane Surface(4) = {4};
Transfinite Surface{4} = {4};
Recombine Surface{4};

Line Loop(5) = {40478, 47808, 80458, 45804};
Plane Surface(5) = {5};
Transfinite Surface{5} = {5};
Recombine Surface{5};

Line Loop(6) = {-26702,2670367,-30367,-2};
Plane Surface(6) = {6};
Transfinite Surface{6} = {6};
Recombine Surface{6};

Line Loop(7) = {-37803,3780478,-40478,-3};
Plane Surface(7) = {7};
Transfinite Surface{7} = {7};
Recombine Surface{7};

Line Loop(8) = {-10158,-4,-45804, 4580158};
Plane Surface(8) = {8};
Transfinite Surface{8} = {8};
Recombine Surface{8};

Line Loop(9) = {-15601,1560256,-20256,-1};
Plane Surface(9) = {9};
Transfinite Surface{9} = {9};
Recombine Surface{9};

// Assign physical groups ------------------------------------------------
Physical Surface("cores") = 1;
Physical Surface("melt_pool") = {2, 3, 4, 5, 6, 7, 8, 9};

Physical Curve("core_sides") = {1, 2, 3, 4};
Physical Curve("core_bottom") = {1};

Mesh 2;
Save "core_in_meltpool.msh";
