#
B1x = 0.0
B1y = 0.0
B1z = 0.0
#
B2x = ${L}
B2y = 0.0
B2z = 0.0
#
B3x = ${L}
B3y = ${L}
B3z = 0.0
#
B4x = 0.0
B4y = ${L}
B4z = 0.0

[Mesh]
    [mesh0]
        type = GeneratedMeshGenerator
        dim = 3
        nx = ${num_el_x}
        ny = ${num_el_y}
        nz = ${num_el_z}
        xmax = ${L}
        ymax = ${L}
        zmax = ${L}
    []
    [B1]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
        input = mesh0
        new_boundary ='B1'
        top_right = '${fparse B1x+0.00001} ${fparse B1y+0.00001} ${fparse B1z+0.00001}'
    []
    [B2]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B2x-0.00001} ${fparse B2y-0.00001} ${fparse B2z-0.00001}'
        input = B1
        new_boundary ='B2'
        top_right = '${fparse B2x+0.00001} ${fparse B2y+0.00001} ${fparse B2z+0.00001}'
    []
    [B3]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B3x-0.00001} ${fparse B3y-0.00001} ${fparse B3z-0.00001}'
        input = B2
        new_boundary ='B3'
        top_right = '${fparse B3x+0.00001} ${fparse B3y+0.00001} ${fparse B3z+0.00001}'
    []
    [B4]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B4x-0.00001} ${fparse B4y-0.00001} ${fparse B4z-0.00001}'
        input = B3
        new_boundary ='B4'
        top_right = '${fparse B4x+0.00001} ${fparse B4y+0.00001} ${fparse B4z+0.00001}'
    []
    [sidesets]
        type = SideSetsFromNodeSetsGenerator
        input = 'B4'
    []
[]

# convection and Solid mechanics BCs
[BCs]
    [fix_xyz_x]
        type = DirichletBC
        boundary = 'B1'
        value = 0.0
        variable = disp_x
    []
    [fix_xyz_y]
        type = DirichletBC
        boundary = 'B1'
        value = 0.0
        variable = disp_y
    []
    [fix_xyz_z]
        type = DirichletBC
        boundary = 'B1'
        value = 0.0
        variable = disp_z
    []
    [fix_yz_y]
        type = DirichletBC
        boundary = 'B2'
        value = 0.0
        variable = disp_y
    []
    [fix_yz_z]
        type = DirichletBC
        boundary = 'B2'
        value = 0.0
        variable = disp_z
    []
    [fix_z]
        type = DirichletBC
        boundary = 'B4'
        value = 0.0
        variable = disp_z
    []
    # [bottom]
    #     type = DirichletBC
    #     boundary = 'base_bottom'
    #     value = 0.0
    #     variable = disp_z
    # []
    # [left]
    #     type = DirichletBC
    #     boundary = 'base_left'
    #     value = 0.0
    #     variable = disp_x
    # []
    # [back]
    #     type = DirichletBC
    #     boundary = 'base_back'
    #     value = 0.0
    #     variable = disp_y
    # []
[]

[Physics]
    [SolidMechanics]
        [QuasiStatic]
            [sample]
                new_system = true
                add_variables = true
                strain = FINITE
                formulation = TOTAL
                volumetric_locking_correction = true
                generate_output = "vonmises_pk2_stress"
            []
        []
    []
[]

[AuxVariables]
    [max_principal_pk2_stress]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = RankTwoScalarAux
            rank_two_tensor = pk2_stress
            scalar_type = MaxPrincipal
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]