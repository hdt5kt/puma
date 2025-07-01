[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = '${meshfile}'
    []
    [mesh_scale]
        type = TransformGenerator
        input = mesh0
        transform = SCALE
        vector_value = '${scale} ${scale} 1.0'
    []
    [rollingnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse xroll-0.00000001} ${fparse yroll-0.00000001} ${fparse zroll-0.00000001}'
        input = mesh_scale
        new_boundary = 'roll'
        top_right = '${fparse xroll+0.00000001} ${fparse yroll+0.00000001} ${fparse zroll+0.00000001}'
    []
    [fixnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse xfix-0.00000001} ${fparse yfix-0.00000001} ${fparse zfix-0.00000001}'
        input = rollingnode
        new_boundary = 'fix'
        top_right = '${fparse xfix+0.00000001} ${fparse yfix+0.00000001} ${fparse zfix+0.00000001}'
    []
    [get_outerinterface]
        type = SideSetsAroundSubdomainGenerator
        input = fixnode
        new_boundary = 'interface'
        block = 0
    []
[]