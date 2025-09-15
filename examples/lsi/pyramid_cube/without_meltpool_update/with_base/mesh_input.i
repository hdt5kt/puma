#
B1x = 0
B1y = 0
B1z = 0.2
#
B2x = 4.0
B2y = 0.0
B2z = 0.2
#
B3x = 4.0
B3y = 4.0
B3z = 0.2
#
B4x = 0
B4y = 4.0
B4z = 0.2
#
T1x = 0
T1y = 0
T1z = 0.5175
#
T2x = 4.0
T2y = 0.0
T2z = 0.5175
#
T3x = 4.0
T3y = 4.0
T3z = 0.5175
#
T4x = 0
T4y = 4.0
T4z = 0.5175
#

# top face
#
TT1x = 0
TT1y = 0
TT1z = 5.1525
TT3x = 4.0
TT3y = 4.0
TT3z = 5.1525

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = ${meshfile}
    []
    [get_outerinterface]
        type = SideSetsAroundSubdomainGenerator
        block = core
        input = mesh0
        new_boundary = 'interface'
    []
    ### Side nodes
    [bottom]
        type = BoundingBoxNodeSetGenerator
        new_boundary = 'base_bottom'
        bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
        input = get_outerinterface
        top_right = '${fparse B3x+0.00001} ${fparse B3y+0.00001} ${fparse B3z+0.00001}'
    []
    [top]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse T1x-0.00001} ${fparse T1y-0.00001} ${fparse T1z-0.00001}'
        input = bottom
        new_boundary = 'base_top'
        top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
    []
    [front]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
        input = top
        new_boundary = 'base_front'
        top_right = '${fparse T2x+0.00001} ${fparse T2y+0.00001} ${fparse T2z+0.00001}'
    []
    [back]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B4x-0.00001} ${fparse B4y-0.00001} ${fparse B4z-0.00001}'
        input = front
        new_boundary = 'base_back'
        top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
    []
    [left]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
        input = back
        new_boundary = 'base_left'
        top_right = '${fparse T4x+0.00001} ${fparse T4y+0.00001} ${fparse T4z+0.00001}'
    []
    [right]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B2x-0.00001} ${fparse B2y-0.00001} ${fparse B2z-0.00001}'
        input = left
        new_boundary = 'base_right'
        top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
    []
    [top_top]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse TT1x-0.00001} ${fparse TT1y-0.00001} ${fparse TT1z-0.00001}'
        input = right
        new_boundary = 'top'
        top_right = '${fparse TT3x+0.00001} ${fparse TT3y+0.00001} ${fparse TT3z+0.00001}'
    []
    [B1]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
        input = top_top
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