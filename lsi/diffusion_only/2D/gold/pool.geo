// block
H = 13.2; // height (mm)
L = 25.4; // length (mm)

// hole
D = 7; // depth (mm)
A = 150*Pi/180; // tool angle (rad)
OD = 3/8*25.4; // outer diameter (mm)

e = 0.5; // mesh size (mm)
ee = 0.1;

Point(1) = {0, H-D, 0, ee};
Point(2) = {0, H, 0, e};
Point(3) = {OD/2, H, 0, ee};
Point(4) = {OD/2, H-D+OD/2/Tan(A/2), 0, ee};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Line Loop(1) = {1, 2, 3, 4};

Plane Surface(1) = {1};

Physical Surface("all") = {1};
Physical Line("inlet") = {3, 4};
