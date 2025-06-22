// Units are in cm

SetFactory("OpenCASCADE");

l = 0.2;
tl = 0.1;
h = 0.1;

th = 0.2;

r = 0.05;
pr = 0.4;

// MESH CONTROL -----------------------------------------------------------------------------
Mesh.Algorithm = 8;
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

el_l = 40; // estimate number of element along the length
el_circ = 20;

// GLOBAL VARIABLES -------------------------------------------------------------------------
lc = l/el_l;
ri = r - pr*r;
ro = r + pr*r;

// PHYSICAL POINTS -----------------------------------------------------------------------------
Point(1)  = {0,   0,   0,     lc};
Point(2)  = {l-r,   0,   0,     lc};
Point(3)  = {l-r+ri,   0,   0,     lc};
Point(4)  = {l,   0,   0,     lc};
Point(5)  = {l-r+ro,   0,   0,     lc};
Point(6)  = {l + tl,   0,   0,     lc};

Point(7)  = {0,         h-r,   0,     lc};
Point(8)  = {l-r,       h-r,   0,     lc};
Point(9)  = {l-r+ri,    h-r,   0,     lc};
Point(10)  = {l,        h-r,   0,     lc};
Point(11)  = {l-r+ro,   h-r,   0,     lc};
Point(12)  = {l + tl,   h-r,   0,     lc};

Point(13)  = {0,         h-r+ri,   0,     lc};
Point(14)  = {l-r,       h-r+ri,   0,     lc};

Point(15)  = {0,         h,   0,     lc};
Point(16)  = {l-r,       h,   0,     lc};

Point(17)  = {0,         h-r+ro,   0,     lc};
Point(18)  = {l-r,       h-r+ro,   0,     lc};

Point(19)  = {0,         h+th,   0,     lc};
Point(20)  = {l-r,       h+th,   0,     lc};
Point(21)  = {l + tl,    h+th,   0,     lc};


// PHYSICAL LINES -----------------------------------------------------------------------------
id = 1;
For i In {1:20}
    Line(id) = {i, i+1};
    If (id == 5)
        i = i +1;
    EndIf

    If (id == 10)
        i = i +1;
    EndIf

    If (id == 11)
        i = i +1;
    EndIf

    If (id == 12)
        i = i +1;
    EndIf

    If (id == 13)
        i = i +1;
    EndIf

    id = id + 1;
EndFor

Line(16) = {1, 7}; Line(17) = {7, 13}; Line(18) = {13, 15}; Line(19) = {15, 17}; Line(20) = {17, 19};
Line(21) = {2, 8}; Line(22) = {8, 14}; Line(23) = {14, 16}; Line(24) = {16, 18}; Line(25) = {18, 20};

Line(26) = {3, 9}; Line(27) = {4, 10}; Line(28) = {5, 11}; Line(29) = {6, 12}; Line(30) = {12, 21};


Circle(31) = {9, 8, 14};  Transfinite Line(31) = el_circ;
Circle(32) = {10, 8, 16}; Transfinite Line(32) = el_circ;
Circle(33) = {11, 8, 18}; Transfinite Line(33) = el_circ;

// // PHYSICAL SURFACES -----------------------------------------------------------------------------

id = 1; Line Loop(id) = {1, 21, -6, -16}; Plane Surface(id) = {id};
Transfinite Surface{id} = {1, 2, 7, 8};
 
id = 2; Line Loop(id) = {2, 26, -7, -21}; Plane Surface(id) = {id};
Transfinite Surface{id} = {3, 2, 9, 8};
 
id = 3; Line Loop(id) = {3, 27, -8, -26}; Plane Surface(id) = {id};
Transfinite Surface{id} = {3, 4, 9, 10};
 
id = 4; Line Loop(id) = {4, 28, -9, -27}; Plane Surface(id) = {id};
Transfinite Surface{id} = {4, 5, 11, 10};
 
id = 5; Line Loop(id) = {5, 29, -10, -28}; Plane Surface(id) = {id};
Transfinite Surface{id} = {5, 6, 12, 11};
 
id = 6; Line Loop(id) = {6, 22, -11, -17}; Plane Surface(id) = {id};
Transfinite Surface{id} = {7, 8, 14, 13};
 
id = 7; Line Loop(id) = {11, 23, -12, -18}; Plane Surface(id) = {id};
Transfinite Surface{id} = {13, 14, 15, 16};
 
id = 8; Line Loop(id) = {12, 24, -13, -19}; Plane Surface(id) = {id};
Transfinite Surface{id} = {15, 16, 17, 18};
 
id = 9; Line Loop(id) = {13, 25, -14, -20}; Plane Surface(id) = {id};
Transfinite Surface{id} = {17, 18, 19, 20};

id = 11; Line Loop(id) = {8, 32, -23, -31}; Plane Surface(id) = {id};
Transfinite Surface{id} = {9, 10, 14, 16};

id = 12; Line Loop(id) = {9, 33, -24, -32}; Plane Surface(id) = {id};
Transfinite Surface{id} = {10, 11, 18, 16};

id = 10; Line Loop(id) = {7, 31, -22}; Plane Surface(id) = {id};

id = 13; Line Loop(id) = {10, 30, -15, -25, -33}; Plane Surface(id) = {id};


Recombine Surface "*";
Physical Line("bottom") = {1,2,3,4,5};
Physical Line("left") = {16,17,18,19,20};
Physical Line("top") = {14,15};
Physical Line("right") = {29,30};
Physical Surface("Si") = {1,2,3,6,7,10,11};
Physical Surface("SiC") = {4,5,8,9,12,13};
Mesh 2;

Coherence Mesh;  // Remove duplicate entities
Save "cane_original_0p2.msh";