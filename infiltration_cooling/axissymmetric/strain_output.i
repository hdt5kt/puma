[AuxVariables]
    ########################### THERMAL CHANGE ############################
    [s11_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 0
        []
    []
    [s22_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 1
        []
    []
    [s33_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 2
        []
    []
    [s23_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 3
        []
    []
    [s13_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 4
        []
    []
    [s12_thermal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_thermal
            component = 5
        []
    []
    ########################### PHASE CHANGE ############################
    [s11_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 0
        []
    []
    [s22_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 1
        []
    []
    [s33_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 2
        []
    []
    [s23_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 3
        []
    []
    [s13_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 4
        []
    []
    [s12_phase]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialSymmetricRankTwoTensorAux
            property = s_phase
            component = 5
        []
    []
[]

[VectorPostprocessors]
    [component_stress]
        type = ElementValueSampler
        sort_by = id
        variable = 's11_thermal s22_thermal s33_thermal s23_thermal s13_thermal s12_thermal
                    s11_phase s22_phase s33_phase s23_phase s13_phase s12_phase'
    []
[]