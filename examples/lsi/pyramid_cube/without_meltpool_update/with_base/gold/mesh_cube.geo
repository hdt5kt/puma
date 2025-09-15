// Units are in cm

SetFactory("OpenCASCADE");

cube_length = 4;
partition = 3;

pyr_height = 0.635;
base = 0.3175;

contact = 0.2; // have to be between 0 and 1

// Exterior furnace information
r = 3.0;           // Radius in cm
h = 10;           // Height in cm
bottom_gap = 0.2;

mesh_cond = 0;  // 0: core, 1: melt_pool

// MESH CONTROL -----------------------------------------------------------------------------
If (mesh_cond == 0)
    Mesh.Algorithm = 8;
EndIf
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

el_x = 4; //estimate number of element along the side per sub-mini-block
el_x_edge = 4;

el_y = 6; //estimate number of element along the side per sub-mini-block
el_y_edge = 12;

cube_el_z = 24;
pyr_el_z = 6;
base_el_z = 3;

// GLOBAL VARIABLES -------------------------------------------------------------------------
dx = cube_length/partition;
dxs = dx * contact;
gap = (dx - dxs)/2;
lc = cube_length/el_x/partition;
lc_contact = lc * contact;

// PHYSICAL POINTS -----------------------------------------------------------------------------

// main base grid
z = pyr_height + base + bottom_gap;

PointIndex = 1;
For i In {0:partition}
  For j In {0:partition}
    x = i * dx;
    y = j * dx;
    Point(PointIndex) = {x, y, z};
    PointIndex += 1;
  EndFor
EndFor

N = (partition+1)^2; // total points
n = partition;

// Inner points
For i In {0:partition-1}
  For j In {0:partition-1}

    p1 = 1 + i*(n+1) + j; xp1 = i * dx; yp1 = j * dx;
    

    If (i != partition)
        If (j!= partition)
            k = 1; // point k1
            p = N + 8*(p1-1) + k;
            x = xp1 + gap; y = yp1 + gap;
            Point(p) = {x, y, z};

            k = 2; // point k2
            p = N + 8*(p1-1) + k;
            x = xp1 + gap + dxs; y = yp1 + gap;
            Point(p) = {x, y, z};

            k = 3; // point k3
            p = N + 8*(p1-1) + k;
            x = xp1 + gap; y = yp1 + gap + dxs;
            Point(p) = {x, y, z};

            k = 4; // point k4
            p = N + 8*(p1-1) + k;
            x = xp1 + gap + dxs; y = yp1 + gap + dxs;
            Point(p) = {x, y, z};

            k = 5; // point k5
            p = N + 8*(p1-1) + k;
            x = xp1 + gap; y = yp1;
            Point(p) = {x, y, z};

            k = 6; // point k6
            p = N + 8*(p1-1) + k;
            x = xp1 + gap + dxs; y = yp1;
            Point(p) = {x, y, z};

            k = 7; // point k7
            p = N + 8*(p1-1) + k;
            x = xp1; y = yp1 + gap;
            Point(p) = {x, y, z};

            k = 8; // point k8
            p = N + 8*(p1-1) + k;
            x = xp1; y = yp1 + gap + dxs;
            Point(p) = {x, y, z};
        EndIf
    EndIf

    If (j == partition-1)
        p3 = p1 + 1; xp3 = xp1; yp3 = yp1 + dx;

        // Printf("%g", p1);

        k = 5; // point k5
        p = N + 8*(p3-1) + k;
        x = xp3 + gap; y = yp3;
        Point(p) = {x, y, z};

        k = 6; // point k6
        p = N + 8*(p3-1) + k;
        x = xp3 + gap + dxs; y = yp3;
        Point(p) = {x, y, z};
    EndIf

    If (i == partition-1)
        p2 = p1 + n + 1; xp2 = xp1 + dx; yp2 = yp1;

        k = 7; // point k7
        p = N + 8*(p2-1) + k;
        x = xp2; y = yp2 + gap;
        Point(p) = {x, y, z};

        k = 8; // point k8
        p = N + 8*(p2-1) + k;
        x = xp2; y = yp2 + gap + dxs;
        Point(p) = {x, y, z};
    EndIf

  EndFor
EndFor

pnew = p+1;

// PHYSICAL LINES -----------------------------------------------------------------------------

For i In {0:partition-1}
  For j In {0:partition-1}

    // get the points
    p1 = 1 + i*(n+1) + j; p3 = p1 + 1; p2 = p1 + n + 1; p4 = p2 + 1;

    k1 = N + 8*(p1-1) + 1; k2 = N + 8*(p1-1) + 2; k3 = N + 8*(p1-1) + 3;
    k4 = N + 8*(p1-1) + 4; k5 = N + 8*(p1-1) + 5; k6 = N + 8*(p1-1) + 6;
    k7 = N + 8*(p1-1) + 7; k8 = N + 8*(p1-1) + 8;

    k5p3 = N + 8*(p3-1) + 5; k6p3 = N + 8*(p3-1) + 6;
    k7p2 = N + 8*(p2-1) + 7; k8p2 = N + 8*(p2-1) + 8;
    

    If (i != partition)
        If (j!= partition)
            z = 1; lz = 18*(p1-1) + z;
            Line(lz) = {p1, k5}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 2; lz = 18*(p1-1) + z;
            Line(lz) = {k5, k6}; If (mesh_cond == 0) Transfinite Line{lz} = el_x; EndIf

            z = 3; lz = 18*(p1-1) + z;
            Line(lz) = {k6, p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 4; lz = 18*(p1-1) + z;
            Line(lz) = {k7, k1}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 5; lz = 18*(p1-1) + z;
            Line(lz) = {k1, k2}; If (mesh_cond == 0) Transfinite Line{lz} = el_x; EndIf

            z = 6; lz = 18*(p1-1) + z;
            Line(lz) = {k2, k7p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 7; lz = 18*(p1-1) + z;
            Line(lz) = {k8, k3}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 8; lz = 18*(p1-1) + z;
            Line(lz) = {k3, k4}; If (mesh_cond == 0) Transfinite Line{lz} = el_x; EndIf

            z = 9; lz = 18*(p1-1) + z;
            Line(lz) = {k4, k8p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

            z = 10; lz = 18*(p1-1) + z;
            Line(lz) = {p1, k7}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

            z = 11; lz = 18*(p1-1) + z;
            Line(lz) = {k7, k8}; If (mesh_cond == 0) Transfinite Line{lz} = el_y; EndIf
            
            z = 12; lz = 18*(p1-1) + z;
            Line(lz) = {k8, p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

            z = 13; lz = 18*(p1-1) + z;
            Line(lz) = {k5, k1}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

            z = 14; lz = 18*(p1-1) + z;
            Line(lz) = {k1, k3}; If (mesh_cond == 0) Transfinite Line{lz} = el_y; EndIf

            z = 15; lz = 18*(p1-1) + z;
            Line(lz) = {k3, k5p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

            z = 16; lz = 18*(p1-1) + z;
            Line(lz) = {k6, k2}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

            z = 17; lz = 18*(p1-1) + z;
            Line(lz) = {k2, k4}; If (mesh_cond == 0) Transfinite Line{lz} = el_y; EndIf

            z = 18; lz = 18*(p1-1) + z;
            Line(lz) = {k4, k6p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf


        EndIf
    EndIf

    If (j == partition-1)
        z = 1; lz = 18*(p3-1) + z;
        Line(lz) = {p3, k5p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

        z = 2; lz = 18*(p3-1) + z;
        Line(lz) = {k5p3, k6p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_x; EndIf

        z = 3; lz = 18*(p3-1) + z;
        Line(lz) = {k6p3, p4}; If (mesh_cond == 0) Transfinite Line{lz} = el_x_edge; EndIf

    EndIf

    If (i == partition-1)
        z = 10; lz = 18*(p2-1) + z;
        Line(lz) = {p2, k7p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_y_edge; EndIf

        z = 11; lz = 18*(p2-1) + z;
        Line(lz) = {k7p2, k8p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_y; EndIf
        
        z = 12; lz = 18*(p2-1) + z;
        Line(lz) = {k8p2, p4}; If (mesh_cond == 0)  Transfinite Line{lz} = el_y_edge; EndIf
    EndIf

  EndFor
EndFor

lnew = lz+1;

// PHYSICAL SURFACES -----------------------------------------------------------------------------
For i In {0:partition-1}
  For j In {0:partition-1}

    // get the points
    p1 = 1 + i*(n+1) + j; p3 = p1 + 1; p2 = p1 + n + 1; p4 = p2 + 1;

    k1 = N + 8*(p1-1) + 1; k2 = N + 8*(p1-1) + 2; k3 = N + 8*(p1-1) + 3;
    k4 = N + 8*(p1-1) + 4; k5 = N + 8*(p1-1) + 5; k6 = N + 8*(p1-1) + 6;
    k7 = N + 8*(p1-1) + 7; k8 = N + 8*(p1-1) + 8;

    k5p3 = N + 8*(p3-1) + 5; k6p3 = N + 8*(p3-1) + 6;
    k7p2 = N + 8*(p2-1) + 7; k8p2 = N + 8*(p2-1) + 8;

    // get the lines
    l1 = 18*(p1-1) + 1;
    l2 = 18*(p1-1) + 2;
    l3 = 18*(p1-1) + 3;
    l4 = 18*(p1-1) + 4;
    l5 = 18*(p1-1) + 5;
    l6 = 18*(p1-1) + 6;
    l7 = 18*(p1-1) + 7;
    l8 = 18*(p1-1) + 8;
    l9 = 18*(p1-1) + 9;
    l10 = 18*(p1-1) + 10;
    l11 = 18*(p1-1) + 11;
    l12 = 18*(p1-1) + 12;
    l13 = 18*(p1-1) + 13;
    l14 = 18*(p1-1) + 14;
    l15 = 18*(p1-1) + 15;
    l16 = 18*(p1-1) + 16;
    l17 = 18*(p1-1) + 17;
    l18 = 18*(p1-1) + 18;

    l1p3 = 18*(p3-1) + 1;
    l2p3 = 18*(p3-1) + 2;
    l3p3 = 18*(p3-1) + 3;

    l10p2 = 18*(p2-1) + 10;
    l11p2 = 18*(p2-1) + 11;
    l12p2 = 18*(p2-1) + 12;

    // Line Loop - Surface - TransfinteMesh
    z = 1; llz = 9*(p1-1)+z; Line Loop(llz) = {l1, l13, -l4, -l10};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {p1, k5, k1, k7}; EndIf

    z = 2; llz = 9*(p1-1)+z; Line Loop(llz) = {l2, l16, -l5, -l13};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k5, k6, k2, k1};  EndIf

    z = 3; llz = 9*(p1-1)+z; Line Loop(llz) = {l3, l10p2, -l6, -l16};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k6, p2, k7p2, k2};  EndIf

    z = 4; llz = 9*(p1-1)+z; Line Loop(llz) = {l4, l14, -l7, -l11};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k7, k1, k3, k8}; EndIf

    z = 5; llz = 9*(p1-1)+z; Line Loop(llz) = {l5, l17, -l8, -l14};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k1, k2, k4, k3}; EndIf

    z = 6; llz = 9*(p1-1)+z; Line Loop(llz) = {l6, l11p2, -l9, -l17};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k2, k7p2, k8p2, k4};  EndIf

    z = 7; llz = 9*(p1-1)+z; Line Loop(llz) = {l7, l15, -l1p3, -l12};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k8, k3, k5p3, p3};  EndIf

    z = 8; llz = 9*(p1-1)+z; Line Loop(llz) = {l8, l18, -l2p3, -l15};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k3, k4, k6p3, k5p3};  EndIf

    z = 9; llz = 9*(p1-1)+z; Line Loop(llz) = {l9, l12p2, -l3p3, -l18};
    Plane Surface(llz) = {llz};
    If (mesh_cond == 0) Transfinite Surface{llz} = {k4, k8p2, p4, k6p3};  EndIf

  EndFor
EndFor

llnew = llz + 1;

N_Surface = 9*(n^2);

// LOWER SURFACE -----------------------------------------------------------------------------
zb = base + bottom_gap;

// Point
PointIndex = pnew;
For i In {0:partition}
  For j In {0:partition}
    x = i * dx;
    y = j * dx;
    Point(PointIndex) = {x, y, zb};
    PointIndex += 1;
  EndFor
EndFor

// Line
For i In {0:partition-1}
  For j In {0:partition-1}

    // get the points
    p1b = 1 + i*(n+1) + j; p3b = p1b + 1; p2b = p1b + n + 1; p4b = p2b + 1;
    p1 = 1 + i*(n+1) + j + (pnew-1); p3 = p1 + 1; p2 = p1 + n + 1; p4 = p2 + 1;
    

    If (i != partition)
        If (j!= partition)
            z = 1; lz = (lnew-1) + 6*(p1b-1) + z;
            Line(lz) = {p1, p2}; If (mesh_cond == 0) Transfinite Line{lz} = el_x; EndIf

            z = 2; lz = (lnew-1) + 6*(p1b-1) + z;
            Line(lz) = {p1, p3}; If (mesh_cond == 0) Transfinite Line{lz} = el_y;  EndIf
        EndIf
    EndIf

    If (j == partition-1)
        z = 1; lz = (lnew-1) + 6*(p3b-1) + z;
        Line(lz) = {p3, p4}; If (mesh_cond == 0) Transfinite Line{lz} = el_x;  EndIf

    EndIf

    If (i == partition-1)
        z = 2; lz = (lnew-1) + 6*(p2b-1) + z;
        Line(lz) = {p2, p4}; If (mesh_cond == 0) Transfinite Line{lz} = el_y;  EndIf
    EndIf

  EndFor
EndFor

// Transition Line and Line Loop
For i In {0:partition-1}
  For j In {0:partition-1}

    // get the points
    p1 = 1 + i*(n+1) + j; p3 = p1 + 1; p2 = p1 + n + 1; p4 = p2 + 1;
    k1 = N + 8*(p1-1) + 1; k2 = N + 8*(p1-1) + 2; k3 = N + 8*(p1-1) + 3;
    k4 = N + 8*(p1-1) + 4; 
    
    p1p = p1 + (pnew-1); p3p = p1p + 1; p2p = p1p + n + 1; p4p = p2p + 1;

    // get the lines
    l5 = 18*(p1-1) + 5;
    l8 = 18*(p1-1) + 8;
    l14 = 18*(p1-1) + 14;
    l17 = 18*(p1-1) + 17;
    l1p = (lnew-1) + 6*(p1-1) + 1;
    l2p = (lnew-1) + 6*(p1-1) + 2;
    l1p3p = (lnew-1) + 6*(p3-1) + 1;
    l2p2p = (lnew-1) + 6*(p2-1) + 2;
    
    z = 3; l3p = (lnew-1) + 6*(p1-1) + 3;
    Line(l3p) = {p1p, k1}; If (mesh_cond == 0) Transfinite Line{l3p} = pyr_el_z;  EndIf

    z = 4; l4p = (lnew-1) + 6*(p1-1) + 4;
    Line(l4p) = {p2p, k2}; If (mesh_cond == 0) Transfinite Line{l4p} = pyr_el_z;  EndIf

    z = 5; l5p = (lnew-1) + 6*(p1-1) + 5;
    Line(l5p) = {p3p, k3}; If (mesh_cond == 0) Transfinite Line{l5p} = pyr_el_z;  EndIf

    z = 6; l6p = (lnew-1) + 6*(p1-1) + 6;
    Line(l6p) = {p4p, k4}; If (mesh_cond == 0) Transfinite Line{l6p} = pyr_el_z;  EndIf

    // make the plane
    z = 100; llz = (llnew-1) + 5*(p1-1) + z; Line Loop(llz) = {l1p, l2p2p, -l1p3p, -l2p};
    Plane Surface(llz) = {llz}; If (mesh_cond == 0) Transfinite Surface{llz} = {p1p, p2p, p3p, p4p};  EndIf

    z = 200; llz = (llnew-1) + 5*(p1-1) + z; Line Loop(llz) = {l1p, l4p, -l5, -l3p};
    Plane Surface(llz) = {llz}; If (mesh_cond == 0) Transfinite Surface{llz} = {p1p, p2p, k1, k2};  EndIf

    z = 300; llz = (llnew-1) + 5*(p1-1) + z; Line Loop(llz) = {l2p2p, l6p, -l17, -l4p};
    Plane Surface(llz) = {llz}; If (mesh_cond == 0) Transfinite Surface{llz} = {p4p, p2p, k4, k2};  EndIf

    z = 400; llz = (llnew-1) + 5*(p1-1) + z; Line Loop(llz) = {-l1p3p, l5p, l8, -l6p};
    Plane Surface(llz) = {llz}; If (mesh_cond == 0) Transfinite Surface{llz} = {p3p, p4p, k3, k4};  EndIf

    z = 500; llz = (llnew-1) + 5*(p1-1) + z; Line Loop(llz) = {-l2p, l3p, l14, -l5p};
    Plane Surface(llz) = {llz}; If (mesh_cond == 0) Transfinite Surface{llz} = {p1p, p3p, k1, k3};  EndIf

  EndFor
EndFor

// EXTRUDE FOR BLOCK -----------------------------------------------------------------------------

volume_id = 1;
For i In {0:partition-1}
  For j In {0:partition-1}

    // get the points
    p1 = 1 + i*(n+1) + j; p3 = p1 + 1; p2 = p1 + n + 1; p4 = p2 + 1;
    k1 = N + 8*(p1-1) + 1; k2 = N + 8*(p1-1) + 2; k3 = N + 8*(p1-1) + 3;
    k4 = N + 8*(p1-1) + 4; 
    
    p1p = p1 + (pnew-1); p3p = p1p + 1; p2p = p1p + n + 1; p4p = p2p + 1;

    // get the plane

    ll5 = 9*(p1-1)+5;
    ll1p = (llnew-1) + 5*(p1-1) + 100; 
    ll2p = (llnew-1) + 5*(p1-1) + 200; 
    ll3p = (llnew-1) + 5*(p1-1) + 300; 
    ll4p = (llnew-1) + 5*(p1-1) + 400;
    ll5p = (llnew-1) + 5*(p1-1) + 500;

    Surface Loop(volume_id) = {ll5,ll1p,ll2p,ll3p,ll4p,ll5p};
    Volume(volume_id) = volume_id;

    If (mesh_cond == 0)
        Transfinite Volume(volume_id) = {volume_id}; Recombine Volume{volume_id};
    EndIf

    volume_id = volume_id + 1; 

  EndFor
EndFor


For i In {0:partition-1}
  For j In {0:partition-1}
    // get the point
    p1 = 1 + i*(n+1) + j;
    // base
    ll1p = (llnew-1) + 5*(p1-1) + 100;
    If (mesh_cond == 0)
        Extrude {0, 0, -base} {
            Surface{ll1p};
            Layers{base_el_z};
            Recombine;
        }
    Else
        Extrude {0, 0, -base} {
            Surface{ll1p};
        }
    EndIf
  EndFor
EndFor

For i In {0:partition-1}
  For j In {0:partition-1}

    // get the point
    p1 = 1 + i*(n+1) + j;
    // cube
    For z In {1:9}
        llz = 9*(p1-1)+z;
        If (mesh_cond == 0)
            Extrude {0, 0, cube_length} {
                Surface{llz};
                Layers{cube_el_z};
                Recombine;
            }
        Else
            Extrude {0, 0, cube_length} {
                Surface{llz};
            }
        EndIf
    EndFor

  EndFor
EndFor

total_volume = 9*n^2 + 2*n^2;

If (mesh_cond == 0)
    Recombine Surface "*";
    Recombine Volume "*";
    Physical Volume("core") = {1:total_volume};
    Mesh 3;
    Coherence Mesh;  // Remove duplicate entities
    Save "SiC_core_dense.msh";
Else
    // Exterior furnace volume
    idvol_cyl = total_volume+1;
    Cylinder(idvol_cyl) = {cube_length/2, cube_length/2, 0, 0, 0, h, r};

    // Difference: subtract Volumes{1:20} from the cylinder
    
    // BooleanUnion(idvol_cyl+2) = {} {};
    
    BooleanDifference(idvol_cyl+1) = 
        {Volume{idvol_cyl}; Delete;}
        {Volume{1:total_volume}; Delete;};

    Physical Volume("melt_pool") = {idvol_cyl+1};

    // Mesh.CharacteristicLengthMin = lc_contact;
    Mesh.CharacteristicLengthMax = lc_contact*100;

    Mesh 3;
    Coherence Mesh;  // Remove duplicate entities
    Save "SiC_meltpool.msh";
EndIf