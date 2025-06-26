// Units are in cm
// Only mesh one forth of the cube

SetFactory("OpenCASCADE");

// core 
width = 2.01; //cm
length = 2.54; //cm
height = 1.32; //cm
bottom_thickness = 0.56; //cm

// pool
r_pool = 0.96/2;
c_pool = 0.78-0.56; //chamfer geometry
h_extra = 0.2;

mesh_cond = 0;  // 0: core, 1: melt_pool

// MESH CONTROL -----------------------------------------------------------------------------
nx_inneredge = 40; // estimate number of element on the outer edge
nx_outeredge = 40; // estimate number of element on the outer edge
// Mesh.Algorithm3D = 1;

minlc = bottom_thickness / nx_inneredge;
maxlc = height / nx_outeredge;

// GEOMETRY -----------------------------------------------------------------------------

If (mesh_cond == 0)
    Box(1) ={0, 0, -bottom_thickness, width/2, length/2, height}; // origin=(x,y,z), dx, dy, dz
EndIf

side_height = height - c_pool - bottom_thickness + h_extra;
Cylinder(2) = {0, 0, c_pool, 0, 0, side_height, r_pool};
Cone(3) = {0, 0, c_pool, 0, 0, -c_pool, r_pool, minlc};

BooleanUnion(4) = {Volume{2}; Delete;}{Volume{3}; Delete;};

Box(5) = {0, 0, -bottom_thickness, width/2, length/2, height+h_extra+1};
BooleanIntersection(6) = {Volume{4};Delete;} {Volume{5};Delete;}; // meltpool


// ASSIGN PHYSICAL SURFACE -----------------------------------------------------------------------------

// Mesh.CharacteristicLengthMin = minlc;
Mesh.CharacteristicLengthMax = maxlc;
Mesh.Recombine3DAll = 1;
Mesh.Recombine3DLevel = 2;

If (mesh_cond == 0)
    BooleanDifference(7) = {Volume{1}; Delete;} {Volume{6}; Delete;} ;
    Physical Surface("interface") = {3,4,5};
    Physical Volume("core") = {7};
    Mesh 3;
    Coherence Mesh;  // Remove duplicate entities
    Save "core.msh";
Else
    Physical Surface("interface") = {1,4,6};
    Physical Volume("melt_pool") = {6};
    Mesh 3;
    Coherence Mesh;  // Remove duplicate entities
    Save "meltpool.msh";
EndIf