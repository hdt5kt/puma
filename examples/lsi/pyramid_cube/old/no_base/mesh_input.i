[Mesh]
    type = GeneratedMesh
    dim = 3
    nx = ${num_el}
    ny = ${num_el}
    nz = ${num_el}
    xmax = ${L}
    ymax = ${L}
    zmax = ${L}
[]

# convection and Solid mechanics BCs
[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'back front bottom top left right'
        variable = T
        value = -1
    []
    [bottom]
        type = DirichletBC
        boundary = bottom
        value = 0.0
        variable = disp_y
    []
    [left]
        type = DirichletBC
        boundary = left
        value = 0.0
        variable = disp_x
    []
    [back]
        type = DirichletBC
        boundary = back
        value = 0.0
        variable = disp_z
    []
[]