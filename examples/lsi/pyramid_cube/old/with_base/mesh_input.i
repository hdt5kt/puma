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
[]

# convection and Solid mechanics BCs
[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'interface'
        variable = T
        value = -1
    []
    [bottom]
        type = DirichletBC
        boundary = 'base_bottom'
        value = 0.0
        variable = disp_z
    []
    [left]
        type = DirichletBC
        boundary = 'base_left'
        value = 0.0
        variable = disp_x
    []
    [back]
        type = DirichletBC
        boundary = 'base_back'
        value = 0.0
        variable = disp_y
    []
[]