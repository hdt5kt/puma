[Mesh]
    type = FileMesh
    file = 'gold/try_exo.e'
    #allow_renumbering = false
    #dim = 3
[]

[Variables]
    [u]
    []
[]

[AuxVariables]
    [Daux]
        order = FIRST
        family = LAGRANGE
        [AuxKernel]
            type = SolutionAux
            solution = reader_object
        []
    []
[]

# [AuxKernels]
#     [Daux]
#         type = SolutionAux
#         solution = reader_object
#         variable = Daux
#     []
# []

[UserObjects]
    [reader_object]
        type = SolutionUserObject
        mesh = 'gold/try_exo.e'
        system_variables = 'porosity'
    []
[]

[Kernels]
    [diff]
        type = MatDiffusion
        variable = u
        diffusivity = Du
    []
    [td]
        type = TimeDerivative
        variable = u
    []
[]

[BCs]
    #[left]
    #    type = DirichletBC
    #    variable = u
    #    boundary = open
    #    value = 1
    #[]
[]

[Materials]
    [Du]
        type = CoupledValueFunctionMaterial
        function = x
        v = Daux
        prop_name = Du
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