[UserObjects]
    [reader_object1]
        type = PropertyReadFile
        prop_file_name = 'initial_condition.csv'
        read_type = 'voronoi'
        nprop = 5 # number of columns in CSV
        nvoronoi = '${num_file_data}' # number of rows that are considered\
    []
[]

[Functions]
    [phi0_C]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object1
        read_type = 'voronoi'
        column_number = 3
    []
    [phi0SiC_noreact]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object1
        read_type = 'voronoi'
        column_number = 4
    []
[]

[AuxVariables]
    [phi0_C]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phi0_C
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phi0SiC_noreact]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phi0SiC_noreact
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[ICs]
    [phi0_C]
        type = FunctionIC
        function = phi0_C
        variable = phi0_C
    []
    [phi0SiC_noreact]
        type = FunctionIC
        function = phi0SiC_noreact
        variable = phi0SiC_noreact
    []
[]

[Materials]
    [init_phiC0]
        type = ParsedMaterial
        property_name = phi0_C
        expression = 'phi0_C'
        coupled_variables = phi0_C
    []
    [init_phiSiC0_noreact]
        type = ParsedMaterial
        property_name = phi0SiC_noreact
        expression = 'phi0SiC_noreact'
        coupled_variables = phi0SiC_noreact
    []
[]

[ICs]
    [temp]
        type = ConstantIC
        value = ${T0}
        variable = T
    []
    [phif]
        type = ConstantIC
        value = 0.0005
        variable = phif
    []
[]