// ------------------------------------------------------------------------------------------
//
//  3D grid Gmsh GEO file for liquid infiltration
//
// ------------------------------------------------------------------------------------------

// units is in cm

// INPUT ------------------------------------------------------------------------------------

SetFactory("OpenCASCADE");

// reference point is the center of the core
x_core = 1.48; 
y_core = 1.46;
h_core = 6.36;

// pool
r_pool = 3;
h_bottom = 1;
h_depth = h_core;

// MESH CONTROL -----------------------------------------------------------------------------
Mesh.Algorithm = 8;
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

nx_core = 20;
el_size = x_core/nx_core;

expand = 2.5;
nz_bottom = 10;
nz_depth = 40;
el_core_sizez = h_depth/nz_depth;
nz_core_above = Floor((h_core-h_depth)/el_core_sizez); 


// PHYSICAL POINT -----------------------------------------------------------------------------
// Main core
Point(1) = {-x_core/2, -y_core/2, 0, el_size};
Point(2) = {x_core/2, -y_core/2, 0, el_size};
Point(3) = {x_core/2, y_core/2, 0, el_size};
Point(4) = {-x_core/2, y_core/2, 0, el_size};

// Pool mesh
Point(5) = {0, 0, 0};
Point(6) =  {-(r_pool)^(1/2), -(r_pool)^(1/2), 0, el_size*expand};
Point(7) =  {(r_pool)^(1/2), -(r_pool)^(1/2), 0, el_size*expand};
Point(8) =  {(r_pool)^(1/2), (r_pool)^(1/2), 0, el_size*expand};
Point(9) =  {-(r_pool)^(1/2), (r_pool)^(1/2), 0, el_size*expand};

// CONNECT POINTS TO LINE -----------------------------------------------------------------------
// core
Line(102) = {1, 2};
Line(203) = {2, 3};
Line(304) = {3, 4};
Line(401) = {4, 1};

// pool
Circle(657) = {6,5,7}; Transfinite Line(657) = nx_core;
Circle(758) = {7,5,8}; Transfinite Line(758) = nx_core;
Circle(859) = {8,5,9}; Transfinite Line(859) = nx_core;
Circle(956) = {9,5,6}; Transfinite Line(956) = nx_core;

Line(106) = {1, 6};
Line(207) = {2, 7};
Line(308) = {3, 8};
Line(409) = {4, 9};

// CORE --------------------------------------------------------------------------------------
id = 1;
Line Loop(id) = {102, 203, 304, 401};
Plane Surface(id) = {id};
Recombine Surface{id};

// POOL --------------------------------------------------------------------------------------
id = 2;
Line Loop(id) = {106,657,-207,-102}; 
Plane Surface(id) = {id};
Transfinite Surface{id} = {1,2,6,7}; // points not line
Recombine Surface{id};
// MeshAlgorithm Surface {id} = 6;

id = 3;
Line Loop(id) = {207,758,-308,-203}; 
Plane Surface(id) = {id};
Transfinite Surface{id} = {2,7,8,3}; // points not line
Recombine Surface{id};

id = 4;
Line Loop(id) = {308,859,-409,-304}; 
Plane Surface(id) = {id};
Transfinite Surface{id} = {4,3,8,9}; // points not line
Recombine Surface{id};

id = 5;
Line Loop(id) = {409,956,-106,-401}; 
Plane Surface(id) = {id};
Transfinite Surface{id} = {4,1,6,9}; // points not line
Recombine Surface{id};

// EXTRUDE MESH TO 3D ------------------------------------------------------------------------------
If (h_depth == h_core)
    core = Extrude {0, 0, h_core} { Surface{1}; Layers{ {nz_depth}, {1}}; Recombine;};
Else
    core = Extrude {0, 0, h_core} { Surface{1}; Layers{ {nz_depth,nz_core_above}, {h_depth/h_core, 1}}; Recombine;};
EndIf

melt_pool[] = Extrude {0, 0, -h_bottom} { Surface{1,2,3,4,5}; Layers{{nz_bottom}, {1}}; Recombine;};
melt_pool[] = Extrude {0, 0, h_depth} { Surface{2,3,4,5}; Layers{{nz_depth}, {1}}; Recombine;};

// ASSIGN BOUNDARIES AND GROUPS, THEN MESH---------------------------------------------------
Physical Volume("cores") = {1};
Physical Volume("melt_pool") = {2,3,4,5,6,7,8,9,10};

// Physical Surface("interface") = {965, 969, 977, 973};
Physical Surface("interface") = {1, 6, 7, 8, 9};
// Physical Surface("core_top_bottom")

// Physical Curve("core_outer_boundary") = {101015,101505,50256,25606,601067,10670267,2670967,96707,708};

// Physical Point("fix") = {5};
// Physical Point("rolling") = {6};

// Geometry.Tolerance = 1e-12;

Mesh 3;
// Mesh.SaveAll = 1;
Save "core_in_meltpool_test.msh";