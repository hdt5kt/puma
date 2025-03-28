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
y_core = 1.48;
h_core = 6.36;
core_shift = 0.1;

// pool
r_pool_up = 3;
taper_depth = 1;
furnace_depth = 2;
r_pool_down = ((core_shift+(furnace_depth-taper_depth))/furnace_depth)*r_pool_up;
h_bottom = 1;
h_depth = h_core;


// MESH CONTROL -----------------------------------------------------------------------------
Mesh.Algorithm = 8;
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

nx_core = 20;
n_lower = 2;
el_size = x_core/nx_core;

shift_el = 2;
taper_depth = taper_depth + shift_el*el_size;
expand0 = 1;
expand = 4;

n_taper = Floor((taper_depth-core_shift)/(el_size));
el_core_sizez = el_size;
n_core_rest = Floor((h_core-(taper_depth-core_shift))/el_core_sizez); 


// PHYSICAL POINT -----------------------------------------------------------------------------
// Main core upper
Point(1) = {-x_core/2, -y_core/2, core_shift, el_size};
Point(2) = {x_core/2, -y_core/2, core_shift, el_size};
Point(3) = {x_core/2, y_core/2, core_shift, el_size};
Point(4) = {-x_core/2, y_core/2, core_shift, el_size};

// Main core lower
// Point(15) = {-x_core/2, -y_core/2, taper_depth, el_size};
// Point(16) = {x_core/2, -y_core/2, taper_depth, el_size};
// Point(17) = {x_core/2, y_core/2, taper_depth, el_size};
// Point(18) = {-x_core/2, y_core/2, taper_depth, el_size};

// Pool mesh lower
Point(5) = {0, 0, core_shift};
Point(6) =  {-r_pool_down/(2^(1/2)), -r_pool_down/(2^(1/2)), core_shift, el_size*expand0};
Point(7) =  {r_pool_down/(2^(1/2)), -r_pool_down/(2^(1/2)), core_shift, el_size*expand0};
Point(8) =  {r_pool_down/(2^(1/2)), r_pool_down/(2^(1/2)), core_shift, el_size*expand0};
Point(9) =  {-r_pool_down/(2^(1/2)), r_pool_down/(2^(1/2)), core_shift, el_size*expand0};

// Pool mesh upper
Point(10) = {0, 0, taper_depth};
Point(11) =  {-r_pool_up/(2^(1/2)), -r_pool_up/(2^(1/2)), taper_depth, el_size*expand};
Point(12) =  {r_pool_up/(2^(1/2)), -r_pool_up/(2^(1/2)), taper_depth, el_size*expand};
Point(13) =  {r_pool_up/(2^(1/2)), r_pool_up/(2^(1/2)), taper_depth, el_size*expand};
Point(14) =  {-r_pool_up/(2^(1/2)), r_pool_up/(2^(1/2)), taper_depth, el_size*expand};

// CONNECT POINTS TO LINE -----------------------------------------------------------------------
// core upper
Line(102) = {1, 2};
Line(203) = {2, 3};
Line(304) = {3, 4};
Line(401) = {4, 1};

// core lower
// Line(15016) = {15, 16};
// Line(16017) = {16, 17};
// Line(17018) = {17, 18};
// Line(18015) = {18, 15};

// pool lower
Circle(657) = {6,5,7}; Transfinite Line(657) = nx_core;
Circle(758) = {7,5,8}; Transfinite Line(758) = nx_core;
Circle(859) = {8,5,9}; Transfinite Line(859) = nx_core;
Circle(956) = {9,5,6}; Transfinite Line(956) = nx_core;

Line(106) = {1, 6};
Line(207) = {2, 7};
Line(308) = {3, 8};
Line(409) = {4, 9};

// pool upper
// Circle(111012) = {11,10,12}; Transfinite Line(111012) = nx_core;
// Circle(121013) = {12,10,13}; Transfinite Line(121013) = nx_core;
// Circle(131014) = {13,10,14}; Transfinite Line(131014) = nx_core;
// Circle(141011) = {14,10,11}; Transfinite Line(141011) = nx_core;

// Line(15011) = {15, 11};
// Line(16012) = {16, 12};
// Line(17013) = {17, 13};
// Line(18014) = {18, 14};

// CORE --------------------------------------------------------------------------------------
id = 1;
Line Loop(id) = {102, 203, 304, 401};
Plane Surface(id) = {id};
Recombine Surface{id};

// id = 6;
// Line Loop(id) = {15016,16017,17018,18015};
// Plane Surface(id) = {id};
// Recombine Surface{id};

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

//

// id = 2;
// Line Loop(id) = {15011, 111012, -16012, -15016}; 
// Plane Surface(id) = {id};
// Transfinite Surface{id} = {15, 11, 12, 16}; // points not line
// Recombine Surface{id};
// MeshAlgorithm Surface {id} = 6;

// id = 8;
// Line Loop(id) = {207,758,-308,-203}; 
// Plane Surface(id) = {id};
// Transfinite Surface{id} = {2,7,8,3}; // points not line
// Recombine Surface{id};
// 
// id = 9;
// Line Loop(id) = {308,859,-409,-304}; 
// Plane Surface(id) = {id};
// Transfinite Surface{id} = {4,3,8,9}; // points not line
// Recombine Surface{id};
// 
// id = 10;
// Line Loop(id) = {409,956,-106,-401}; 
// Plane Surface(id) = {id};
// Transfinite Surface{id} = {4,1,6,9}; // points not line
// Recombine Surface{id};

// EXTRUDE MESH TO 3D ------------------------------------------------------------------------------------------------------------------------------------------------------------

core1[] = Extrude {0, 0, h_core} {Surface{1}; Layers{ {n_taper, n_core_rest}, {(taper_depth-core_shift)/(h_core),1}}; Recombine;};
pool0[] = Extrude {0, 0, -core_shift} {Surface{1}; Layers{ {n_lower}, {1}}; Recombine;};


pool1[] = Extrude {0, 0, taper_depth-core_shift} {Surface{2,3,4,5}; Layers{ {n_taper}, {1}}; Recombine;};


// EXTERIOR OF THE MELT POOL BY ROTATING THE SIDE MESH FROM THE EXTRUDED SURFACE------------------------------------------------------------------------------

// Point(70) = {(r_pool_down+shift_el*el_size)^(1/2), -(r_pool_down+shift_el*el_size)^(1/2), core_shift, el_size};
Point(120) = {r_pool_up/(2^(1/2)), -r_pool_up/(2^(1/2)), taper_depth-shift_el*el_size, el_size};

Line(25012) = {25, 12};
Line(120120) = {12,120};
Line(12007) = {120, 7};
// Line(1200070) = {120,70};
// Line(7007) = {70,7};

idl = newll; idsa = news; 
// Line Loop(idl) = {25012,120120, 1200070, 7007, 976};
Line Loop(idl) = {25012,120120,12007, 976};
Plane Surface(idsa) = {idl};
MeshAlgorithm Surface {idsa} = 11;
Recombine Surface{idsa};

pool2[] = Extrude { {0,0,1} , {0,0,taper_depth} , Pi} {
 Surface{idsa}; Layers{nx_core*2}; Recombine;
};
pool3[] = Extrude { {0,0,1} , {0,0,taper_depth} , -Pi} {
 Surface{idsa}; Layers{nx_core*2}; Recombine;
};

pool4[] = Extrude {0, 0, h_core-taper_depth+core_shift} {Surface{24,31,28,20,120122,120127}; Layers{ {n_core_rest}, {1}}; Recombine;};


// ASSIGN BOUNDARIES AND GROUPS, THEN MESH---------------------------------------------------
Physical Volume("cores") = {core1[1]};
Physical Volume("melt_pool") = {2:14};

Physical Surface("interface") = {1, core1[2], core1[3], core1[4], core1[5]};

// Physical Surface("interface") = {1, 6, 7, 8, 9};
// Physical Surface("core_top_bottom")

// Physical Curve("core_outer_boundary") = {101015,101505,50256,25606,601067,10670267,2670967,96707,708};

// Physical Point("fix") = {5};
// Physical Point("rolling") = {6};

// Geometry.Tolerance = 1e-12;


Mesh 3;
Coherence Mesh;  // Remove duplicate entities
// Mesh.SaveAll = 1;
Save "core_in_meltpool_v2.msh";