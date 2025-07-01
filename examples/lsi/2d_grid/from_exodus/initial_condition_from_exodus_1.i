[UserObjects]
    [reader_object1]
        type = SolutionUserObject
        mesh = '${meshfile}'
        system_variables = 'X'
        execute_on = 'INITIAL'
        scale = '${scale} ${scale} 1.0'
    []
[]

[AuxVariables]
    [phi0_init]
        order = FIRST
        family = LAGRANGE
    []
[]

[ICs]
    [phi0_init]
        type = SolutionIC
        from_variable = X
        solution_uo = reader_object1
        variable = phi0_init
    []
    [temp]
        type = ConstantIC
        value = ${T0}
        variable = T
    []
    [phif]
        type = ConstantIC
        value = 0.00001
        variable = phif
    []
[]

[Materials]
    [init_phiC0]
        type = ParsedMaterial
        property_name = phi0_C
        coupled_variables = 'phi0_init'
        expression = '${C_percentage} * (1-phi0_init)'
    []
    [init_phiSiC0_noreact]
        type = ParsedMaterial
        property_name = phi0SiC_noreact
        coupled_variables = 'phi0_init'
        expression = '(1-${C_percentage}) * (1-phi0_init)'
    []
[]