// Input, make sure this is similar to the pyrolysis.i file

// denisty kgm-3
rho_s = 2260;
rho_b = 1250; // 1.2 and 1.4
rho_g = 1;
rho_p = 3210;

// mass kg
ms0 = 3;
mb0 = 24;
mp0 = 30;
mg0 = 1e-4;
vv0 = 0.0001; //void fraction
Vv0 = vv0/(1-vv0)*(ms0/rho_s + mb0/rho_b + mp0/rho_p);

V0 = ms0/rho_s + mb0/rho_b + mp0/rho_p + Vv0;

xmax = V0^(1/3);

nx = 51;

Point(1) = {0, 0, 0};
Point(2) = {xmax/2, 0, 0};
Point(3) = {xmax/2, xmax/2, 0};
Point(4) = {0, xmax/2, 0};

Line(1) = {1, 2}; Transfinite Curve{1} = nx;
Line(2) = {2, 3}; Transfinite Curve{2} = nx;
Line(3) = {3, 4}; Transfinite Curve{3} = nx;
Line(4) = {4, 1}; Transfinite Curve{4} = nx;
Line Loop(1) = {1, 2, 3, 4};

Plane Surface(1) = {1};
Transfinite Surface{1} = {1,2,3,4};
Recombine Surface{1};

Physical Curve("open") = {2, 3};
Physical Curve("left") = {4};
Physical Curve("bottom") = {1};

Physical Surface("all") = 1;

Mesh 2;
Save "mesh_part.msh";
