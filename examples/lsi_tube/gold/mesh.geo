// Input - units are in cm
// do not use it to create more than 50 or so circles .......

// SetFactory("OpenCASCADE");

length = 0.01; //m
num_circle = 5;
circle_size = 0.5; //radius percentage
el_x = 10; //estimate number of element along the side per mini-block
lc = length/el_x/num_circle;

base_thickness = 0.002;
base_n_elements = 4;

tube_length = 0.005;
tube_n_elements = 6;

// MESH CONTROL -----------------------------------------------------------------------------
Mesh.Algorithm = 8;
Mesh.FlexibleTransfinite = 1.0;
Mesh.QuasiTransfinite = 1.0;

// PHYSICAL POINTS -----------------------------------------------------------------------------
nx = num_circle+1;
dx = length/(nx-1);
PointIndex = 1;
For i In {0:nx-1}
  For j In {0:nx-1}
    x = i * dx;
    y = j * dx;
    z = 0.0;
    Point(PointIndex) = {x, y, z, lc};
    PointIndex += 1;
  EndFor
EndFor

CircleCenterIndex = 1000;
circle_base = CircleCenterIndex;
sub_square_length = length/num_circle;
radius = circle_size * (sub_square_length/2);

// Diagonal center point
For i In {0:num_circle-1}
    center = dx/2+dx*i;
    // center
    Point(CircleCenterIndex) = {center, center, 0, lc/2};
    // four points use to create the circle corners
    Point(CircleCenterIndex+1) = {center-Sqrt(2)/2*radius,center-Sqrt(2)/2*radius,0,lc};
    Point(CircleCenterIndex+2) = {center+Sqrt(2)/2*radius,center-Sqrt(2)/2*radius,0,lc};
    Point(CircleCenterIndex+3) = {center+Sqrt(2)/2*radius,center+Sqrt(2)/2*radius,0,lc};
    Point(CircleCenterIndex+4) = {center-Sqrt(2)/2*radius,center+Sqrt(2)/2*radius,0,lc};
    CircleCenterIndex += 1000;
EndFor

// PHYSICAL LINES -----------------------------------------------------------------------------
// horizontal
LineIndex = 2001;
hori_base = LineIndex-1;
For j In {0:nx-2}
  For i In {0:nx-1}
    p1 = i + j*nx + 1;
    p2 = p1 + nx;
    Line(LineIndex) = {p1, p2};
    LineIndex += 1;
  EndFor
EndFor

// vertical
LineIndex = 1001;
verti_base = 1001-1;
For j In {0:nx-1}
  For i In {0:nx-2}
    p1 = i+ j*nx + 1;
    p2 = p1 + 1;
    Line(LineIndex) = {p1, p2};
    LineIndex += 1;
  EndFor
EndFor

// SURFACES ------------------------------------------------------------------------
id_square = 1;
square_base = id_square;
id_circle_loop = 100;
circle_loop_base = id_circle_loop;
id_circle_surf = 1000;
surf_circle_base = id_circle_surf;
id_circle = 3000;
id_newline = 4000;
For j In {0:nx-2}
    For i In {0:nx-2}
        p1 = i + j*nx + 1;
        p2 = p1+nx;
        p3 = p1+nx+1;
        p4 = p1+1;
        v1 = hori_base+p1;
        v2 = verti_base+p1+num_circle-j;
        v3 = (hori_base+p1+1);
        v4 = (verti_base+p1-j);
        
        If ((p1%(nx+1)) != 1)
            Line Loop(id_square) = {v1, v2, -v3, -v4};
            Plane Surface(id_square) = {id_square};
            Recombine Surface{id_square};
            id_square += 1;
        Else
            pc1 = circle_base+1;
            pc2 = circle_base+2;
            pc3 = circle_base+3;
            pc4 = circle_base+4;
            vc1 = id_circle;
            vc2 = id_circle+1;
            vc3 = id_circle+2;
            vc4 = id_circle+3;

            Circle(vc1) = {pc1,circle_base,pc2}; Transfinite Line(vc1) = el_x;
            Circle(vc2) = {pc2,circle_base,pc3}; Transfinite Line(vc2) = el_x;
            Circle(vc3) = {pc3,circle_base,pc4}; Transfinite Line(vc3) = el_x;
            Circle(vc4) = {pc4,circle_base,pc1}; Transfinite Line(vc4) = el_x;

            // connect the corners
            p1pc1 = id_newline;
            p2pc2 = id_newline+1;
            p3pc3 = id_newline+2;
            p4pc4 = id_newline+3;

            Line(p1pc1) = {p1, pc1};
            Line(p2pc2) = {p2, pc2};
            Line(p3pc3) = {p3, pc3};
            Line(p4pc4) = {p4, pc4};

            Line Loop(id_circle_loop+3) = {vc1,vc2,vc3,vc4};
            Plane Surface(id_circle_surf) = {id_circle_loop+3};
            MeshAlgorithm Surface{id_circle_surf} = 11;
            Recombine Surface{id_circle_surf};

            Line Loop(id_circle_loop) = {v1, p2pc2, -vc1, -p1pc1};
            Plane Surface(id_circle_loop) = {id_circle_loop};
            Transfinite Surface{id_circle_loop} = {p1, p2, pc2, pc1}; // points not line
            Recombine Surface{id_circle_loop};
            
            Line Loop(id_circle_loop+1) = {v2, p3pc3, -vc2, -p2pc2};
            Plane Surface(id_circle_loop+1) = {id_circle_loop+1};
            Transfinite Surface{id_circle_loop+1} = {p2, p3, pc2, pc3}; // points not line
            Recombine Surface{id_circle_loop+1};

            Line Loop(id_circle_loop+2) = {-v3, p4pc4, -vc3, -p3pc3};
            Plane Surface(id_circle_loop+2) = {id_circle_loop+2};
            Transfinite Surface{id_circle_loop+2} = {p3, p4, pc3, pc4}; // points not line
            Recombine Surface{id_circle_loop+2};

            Line Loop(id_circle_loop+4) = {-v4, p1pc1, -vc4, -p4pc4};
            Plane Surface(id_circle_loop+4) = {id_circle_loop+4};
            Transfinite Surface{id_circle_loop+4} = {p1, pc1, p4, pc4}; // points not line
            Recombine Surface{id_circle_loop+4};

            circle_base += 1000;
            id_circle += 4;
            id_newline += 4;
            id_circle_loop += 5;
            id_circle_surf += 1;

        EndIf
    EndFor
EndFor

// EXTRUDED OUT TO DESIRABLE THICKNESS
circle1[] = Extrude {0, 0, tube_length} {Surface{surf_circle_base:id_circle_surf-1}; Layers{ {tube_n_elements}, {1}}; Recombine;};

bark_base[] = Extrude {0, 0, -base_thickness} {Surface{surf_circle_base:id_circle_surf-1:1,square_base:id_square-1,circle_loop_base:id_circle_loop-1}; Layers{ {base_n_elements}, {1}}; Recombine;};


Mesh 3;
// Mesh.ElementOrder = 1;
Coherence Mesh;  // Remove duplicate entities
Mesh.SaveAll = 1;
Save "tube_all.msh";
