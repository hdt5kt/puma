Point(1) = {0,0,0,1};
Point(2) = {1,0,0,1};
Point(3) = {1,1,0,1};
Point(4) = {0,1,0,1};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};

Line Loop(1) = {1,2,3,4};
Plane Surface(1) = {1};
Transfinite Surface{1} = {1,2,3,4}; // points not line
Recombine Surface{1};


Physical Surface("a") = 1;

Mesh 2;
// Mesh.SaveAll;
Mesh.SaveWithoutOrphans = 1;

Save "simple_test.msh4";
