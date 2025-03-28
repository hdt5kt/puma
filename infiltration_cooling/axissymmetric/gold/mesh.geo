// ------------------------------------------------------------------------------------------
//
//  Axis-symmetric Gmsh GEO file for liquid infiltration
//
// ------------------------------------------------------------------------------------------

// units is in cm

// INPUT ------------------------------------------------------------------------------------

// reference point is the lowest tip of the melt pool
yc = 0.0001;
r_pool = 0.96/2;
c_pool = 0.78-0.56; //chamfer geometry
h_pool = 0.9;

// core block
h_core = 1.32;
r_core = 2.54/2;
ref_top = 0.78;

// MESH CONTROL -----------------------------------------------------------------------------
Mesh.Algorithm = 8;
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

nx_pool = 40;
el_size = r_pool/nx_pool;

pool_dy_up = 0.1;
core_dy_down = 0.2;

nx_core1 = nx_pool;
nx_core2 = 20;
ny_core = 80;

// PHYSICAL POINT -----------------------------------------------------------------------------
// Main pool
Point(1) = {0,yc,0,el_size};
Point(2) = {r_pool,c_pool,0,el_size};
Point(3) = {r_pool,h_pool,0,el_size};
Point(4) = {0,h_pool,0,el_size};

// Main core
Point(5) = {0, ref_top-h_core, 0,el_size};
Point(6) = {r_core, ref_top-h_core, 0,el_size};
Point(7) = {r_core, ref_top, 0,el_size};
Point(8) = {r_pool, ref_top, 0,el_size};

// PARTITION POINTS -----------------------------------------------------------------------------
Point(9) = {r_pool,c_pool+pool_dy_up,0,el_size};
Point(10) = {r_pool, -core_dy_down, 0,el_size};

Point(814) = {0,ref_top,0,el_size};
Point(914) = {0,c_pool+pool_dy_up,0,el_size};
Point(1015) = {0,-core_dy_down,0,el_size};
Point(256) = {r_pool,ref_top-h_core,0,el_size};
Point(1067) = {r_core, -core_dy_down,0,el_size};
Point(267) = {r_core,c_pool,0,el_size};
Point(967) = {r_core,c_pool+pool_dy_up,0,el_size};

// CONNECT POINTS TO LINE -----------------------------------------------------------------------
// Pool
Line(102) = {1, 2};
Line(209) = {2, 9};
Line(908) = {9, 8};
Line(803) = {8, 3};
Line(304) = {3, 4};
Line(40814) = {4, 814};
Line(8140914) = {814, 914};
Line(91401) = {914, 1};
Line(90914) = {9, 914};
Line(80814) = {8, 814}; 

// Core Under
Line(101015) = {1, 1015};
Line(101505) = {1015, 5};
Line(50256) = {5, 256};
Line(256010) = {256, 10};
Line(1002) = {10, 2};
Line(1001015) = {10, 1015};

// Core right
Line(25606) = {256, 6};
Line(601067) = {6, 1067};
Line(10670267) = {1067, 267};
Line(2670967) = {267, 967};
Line(96707) = {967, 7};
Line(708) = {7, 8};
Line(1067010) = {1067, 10};
Line(26702) = {267, 2};
Line(96709) = {967, 9};

// POOL --------------------------------------------------------------------------------------
id = 1;
Line Loop(id) = {102, 209, 90914, 91401};
Plane Surface(id) = {id};
Recombine Surface{id};

id = 2;
Line Loop(id) = {-90914,908,80814,8140914};
Plane Surface(id) = {id};
Transfinite Surface{id} = {914,9,8,814}; // points not line
Recombine Surface{id};

id = 3;
Line Loop(id) = {-80814,803,304,40814};
Plane Surface(id) = {id};
Transfinite Surface{id} = {3,4,814,8}; // points not line
Recombine Surface{id};

// CORE --------------------------------------------------------------------------------------
id = 4;
Line Loop(id) = {-1001015,1002,-102,101015};
Plane Surface(id) = {id};
Recombine Surface{id};
// MeshAlgorithm Surface {id} = 6;

id = 5;
Line Loop(id) = {101505,50256,256010,1001015};
Plane Surface(id) = {id};
Transfinite Surface{id} = {5,256,10,1015}; // points not line
Recombine Surface{id};

id = 6;
Line Loop(id) = {25606,601067,1067010,-256010};
Plane Surface(id) = {id};
Transfinite Surface{id} = {256, 6, 1067, 10}; // points not line
Recombine Surface{id};

id = 7;
Line Loop(id) = {-1067010,10670267,26702,-1002};
Plane Surface(id) = {id};
Transfinite Surface{id} = {10,1067,267,2}; // points not line
Recombine Surface{id};

id = 8;
Line Loop(id) = {-26702, 2670967,96709,-209};
Plane Surface(id) = {id};
Transfinite Surface{id} = {2,267,967,9}; // points not line
Recombine Surface{id};

id = 9;
Line Loop(id) = {-96709,96707,708,-908};
Plane Surface(id) = {id};
Transfinite Surface{id} = {9,967,7,8}; // points not line
Recombine Surface{id};

// ASSIGN BOUNDARIES AND GROUPS, THEN MESH---------------------------------------------------
Physical Surface("cores") = {4,5,6,7,8,9};
Physical Surface("melt_pool") = {1,2,3};

Physical Curve("interface") = {102, 209, 908};
Physical Curve("core_outer_boundary") = {101015,101505,50256,25606,601067,10670267,2670967,96707,708};

Physical Point("fix") = {5};
Physical Point("rolling") = {6};

Mesh 2;
Save "core_in_meltpool_noentities.msh4";


