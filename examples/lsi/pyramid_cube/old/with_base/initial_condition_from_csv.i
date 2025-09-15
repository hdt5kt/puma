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

[Materials]
    [init_phiC0]
        type = StationaryGenericFunctionMaterial
        prop_names = 'phi0_C'
        prop_values = phi0_C
    []
    [init_phiSiC0_noreact]
        type = StationaryGenericFunctionMaterial
        prop_names = 'phi0SiC_noreact'
        prop_values = phi0SiC_noreact
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
        value = 0.00001
        variable = phif
    []
[]