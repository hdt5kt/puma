[UserObjects]
    [reader_object2]
        type = SolutionUserObject
        mesh = 'infiltration.e'
        system_variables = 'T phif disp_x disp_y phi_C phi_SiC phi_nonliquid porosity'
        execute_on = 'INITIAL'
        timestep = 'LATEST'
    []
[]

[AuxVariables]
    [phi_C]
        order = CONSTANT
        family = MONOMIAL
    []
    [phi_SiC]
        order = CONSTANT
        family = MONOMIAL
    []
    [phi_nonliquid]
        order = CONSTANT
        family = MONOMIAL
    []
    [phi_Si]
        order = FIRST
        family = LAGRANGE
    []
[]

[ICs]
    [phi_C]
        type = SolutionIC
        from_variable = phi_C
        solution_uo = reader_object2
        variable = phi_C
    []
    [phi_SiC]
        type = SolutionIC
        from_variable = phi_SiC
        solution_uo = reader_object2
        variable = phi_SiC
    []
    [phi_Si]
        type = SolutionIC
        from_variable = phif
        solution_uo = reader_object2
        variable = phi_Si
    []
    [phi_nonliquid]
        type = SolutionIC
        from_variable = phi_nonliquid
        solution_uo = reader_object2
        variable = phi_nonliquid
    []
[]

[Materials]
    [phip]
        type = ParsedMaterial
        property_name = phip
        coupled_variables = 'phi_SiC'
        expression = 'phi_SiC'
    []
    [phis]
        type = ParsedMaterial
        property_name = phis
        coupled_variables = 'phi_C'
        expression = 'phi_C'
    []
    [phif]
        type = ParsedMaterial
        property_name = phif
        coupled_variables = 'phi_Si'
        expression = 'phi_Si'
    []
    [phinoreact]
        type = ParsedMaterial
        property_name = phinoreact
        coupled_variables = 'phi_nonliquid phi_SiC phi_C'
        expression = 'phi_nonliquid - phi_SiC - phi_C'
    []
[]

#### Transfer of solid mechanics information ####
[ICs]
    [xinit]
        type = SolutionIC
        from_variable = disp_x
        solution_uo = reader_object2
        variable = disp_x
    []
    [yinit]
        type = SolutionIC
        from_variable = disp_y
        solution_uo = reader_object2
        variable = disp_y
    []
    [temp_IC]
        type = SolutionIC
        from_variable = T
        solution_uo = reader_object2
        variable = T
    []
[]