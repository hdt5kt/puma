[UserObjects]
    [reader_object2]
        type = SolutionUserObject
        mesh = '${save_folder}/out_cycle${fparse cycle-1}.e'
        system_variables = 'T disp_x disp_y wb ws wp wgcp Vol phiop phis'
        execute_on = 'INITIAL'
        timestep = 'LATEST'
    []
    [reader_object1]
        type = PropertyReadFile
        prop_file_name = 'initial_condition.csv'
        read_type = 'voronoi'
        nprop = 6 # number of columns in CSV
        nvoronoi = '${num_file_data}' # number of rows that are considered
    []
[]

[Functions]
    [Vref0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object1
        read_type = 'voronoi'
        column_number = 5
    []
[]

[AuxVariables]
    [phiop0]
        order = CONSTANT
        family = MONOMIAL
    []
    [phis0]
        order = CONSTANT
        family = MONOMIAL
    []
    [wp0]
        order = CONSTANT
        family = MONOMIAL
    []
    [ws0]
        order = CONSTANT
        family = MONOMIAL
    []
    [wgcp0]
        order = CONSTANT
        family = MONOMIAL
    []
    [Vol0]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[ICs]
    [wp]
        type = SolutionIC
        from_variable = wp
        solution_uo = reader_object2
        variable = wp0
    []
    [phiop]
        type = SolutionIC
        from_variable = phiop
        solution_uo = reader_object2
        variable = phiop0
    []
    [phis0]
        type = SolutionIC
        from_variable = phis
        solution_uo = reader_object2
        variable = phis0
    []
    [ws]
        type = SolutionIC
        from_variable = ws
        solution_uo = reader_object2
        variable = ws0
    []
    [wgcp]
        type = SolutionIC
        from_variable = wgcp
        solution_uo = reader_object2
        variable = wgcp0
    []
    [V_RVE]
        type = SolutionIC
        from_variable = Vol
        solution_uo = reader_object2
        variable = Vol0
    []
[]

[Materials]
    [init_wb]
        type = ParsedMaterial
        property_name = wb0
        coupled_variables = 'phiop0 Vol0'
        expression = 'phiop0*${rho_b}*Vol0/${Mref}'
    []
    [init_wp]
        type = ParsedMaterial
        property_name = wp0
        coupled_variables = 'wp0'
        expression = 'wp0/1.0'
    []
    [init_ws]
        type = ParsedMaterial
        property_name = ws0
        coupled_variables = 'ws0'
        expression = 'ws0/1.0'
    []
    [init_phis]
        type = ParsedMaterial
        property_name = phis0
        coupled_variables = 'phis0'
        expression = 'phis0/1.0'
    []
    [init_wgcp]
        type = ParsedMaterial
        property_name = wgcp0
        coupled_variables = 'wgcp0'
        expression = 'wgcp0/1.0'
    []
    [init_Vref]
        type = ParsedMaterial
        property_name = Vol0
        coupled_variables = 'Vol0'
        expression = 'Vol0/1.0'
    []
    [init_V0]
        type = GenericFunctionMaterial
        prop_names = 'Vref0'
        prop_values = Vref0
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