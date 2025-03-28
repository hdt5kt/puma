[Mesh]
    type = FileMesh
    file = 'gold/try_mesh.msh'
    allow_renumbering = false
    dim = 3
[]

[Variables]
    [u]
    []
[]

[AuxVariables]
    [D]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = D
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[Functions]
    [diff_func]
        type = PiecewiseConstantFromCSV

        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 3
    []
[]

[UserObjects]
    [reader_object]
        type = PropertyReadFile
        prop_file_name = 'gold/porosity.csv'
        read_type = 'voronoi'
        nprop = 4 # number of columns in CSV
        nvoronoi = 2601 # number of rows that are considered
    []
[]

[Kernels]
    [diff]
        type = MatDiffusion
        variable = u
        diffusivity = D
    []
    [td]
        type = TimeDerivative
        variable = u
    []
[]

[BCs]
    [left]
        type = DirichletBC
        variable = u
        boundary = open
        value = 1
    []
[]

[Materials]
    [gfm]
        type = GenericFunctionMaterial
        prop_names = D
        prop_values = diff_func
    []
[]

[Executioner]
    type = Transient
    num_steps = 1
    dt = 0.1

    solve_type = 'PJFNK'

    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true
[]