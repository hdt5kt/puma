base_folder = 'different_initial_phiC'
phiC0_data = 'phiC0_alphaC0.csv'
phiC0_ndata = 4761

############### Input ################

# Simulation parameters
dt = 0.1
total_time = 7200

# in case of overflown at boundary, the rate of silicon amount being remove
t_ramp = 10
flux = 1.5e-3

levelset_smooth_transistion = 0.5 #cm

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_SiC = 3.21
rho_C = 2.26

# material property
D_LP = 1e-12 # cm2 s-1
l_c = 1e-3 # cm

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# macroscopic property
D_macro = 0.01 #cm2 s-1

# initial condition
phi0_SiC = 0.05
# phi0_C = 0.45
h0_pool = 15.0 #cm

## Calculations
D_bar = '${fparse D_LP/(l_c^2)}'

omega_C = '${fparse M_C/rho_C}'
omega_Si = '${fparse M_Si/rho_Si}'
omega_SiC = '${fparse M_SiC/rho_SiC}'

oCm1 = '${fparse 1/omega_C}'
oSiCm1 = '${fparse 1/omega_SiC}'

chem_ratio = '${fparse k_SiC/k_C}'

alpha0_SiC = '${fparse phi0_SiC/omega_SiC}'
# alpha0_C = '${fparse phi0_C/omega_C}'

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = 'gold/core_in_meltpool.msh'
    []
    [shift]
        type = TransformGenerator
        input = mesh0
        transform = TRANSLATE_MIN_ORIGIN
    []
    [delete]
        type = BlockDeletionGenerator
        input = shift
        block = 'melt_pool'
    []
[]

[MultiApps]
    [melt_pool]
        type = TransientMultiApp
        input_files = 'melt_pool.i'
        cli_args = 'h0=${h0_pool};L0=${levelset_smooth_transistion};base_folder=${base_folder}'
        catch_up = true
        execute_on = 'TIMESTEP_BEGIN'
    []
[]

[Transfers]
    [volume_rate]
        type = MultiAppPostprocessorTransfer
        to_multi_app = 'melt_pool'
        from_postprocessor = 'volume_rate'
        to_postprocessor = 'volume_rate'
    []
    [M]
        type = MultiAppGeneralFieldNearestLocationTransfer
        from_multi_app = 'melt_pool'
        source_type = 'centroids'
        source_variable = 'M'
        variable = 'M'
        to_boundaries = 'core_sides'
        error_on_miss = true
    []
[]

[Variables]
    [alpha]
    []
[]

[AuxVariables]
    [M] # materialization function (from 0 to 1)
        order = CONSTANT
        family = MONOMIAL
        [InitialCondition]
            type = ConstantIC
            value = 1
        []
    []
    [phi_Si]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phi_Si
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phi_C]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phi_C
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phi_SiC]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phi_SiC
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [void_fraction]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = ParsedAux
            expression = '1-phi_SiC-phi_C-phi_Si'
            material_properties = 'phi_SiC phi_C phi_Si'
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[Kernels]
    [transient]
        type = TimeDerivative
        variable = alpha
    []
    [diffusion]
        type = MatDiffusion
        variable = alpha
        diffusivity = D
    []
    [reaction]
        type = MaterialSource
        variable = alpha
        prop = alpha_rate
        prop_derivative = neml2_daDotdalpha
        coefficient = 1
    []
[]

[NEML2]
    input = 'neml2/Si_SiC_C.i'
    cli_args = 'D=${D_bar} omega_Si=${omega_Si} oSiCm1=${oSiCm1} oCm1=${oCm1} chem_ratio=${chem_ratio} chem_P=${k_SiC}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE          POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL          MATERIAL         MATERIAL'
        moose_inputs = '     alpha             time          time          alpha_SiC
                             alpha_C           phi_SiC          phi_C'
        neml2_inputs = '     forces/alpha      forces/t      old_forces/t  old_state/alpha_P
                             old_state/alpha_S state/phi_P      state/phi_S'

        moose_output_types = 'MATERIAL        MATERIAL      MATERIAL      MATERIAL    MATERIAL    MATERIAL'
        moose_outputs = '     alpha_rate      alpha_SiC     alpha_C       phi_Si      phi_SiC    phi_C'
        neml2_outputs = '     state/alpha_dot state/alpha_P state/alpha_S state/phi_L state/phi_P state/phi_S'

        moose_derivative_types = 'MATERIAL                      MATERIAL
                                  MATERIAL                      MATERIAL'
        moose_derivatives = '     neml2_daDotdalpha             neml2_dphiCdalpha
                                  neml2_dphiSidalpha            neml2_dphiSiCdalpha'
        neml2_derivatives = '     state/alpha_dot forces/alpha; state/phi_S forces/alpha;
                                  state/phi_L forces/alpha;     state/phi_P forces/alpha'

        initialize_outputs = '      alpha_SiC alpha_C phi_SiC  phi_C'
        initialize_output_values = 'aSiC0     aC0     phi0_SiC phi0_C'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = ' aSiC0         phi0_SiC    D'
        prop_values = '${alpha0_SiC} ${phi0_SiC} ${D_macro}'
    []
    [init_phi0C]
        type = GenericFunctionMaterial
        prop_names = 'phi0_C'
        prop_values = phi0C
    []
    [init_aC0]
        type = GenericFunctionMaterial
        prop_names = 'aC0'
        prop_values = alphaC0
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [inlet_rate]
        type = SideDiffusiveFluxIntegral
        diffusivity = D
        variable = alpha
        boundary = 'core_sides'
        execute_on = 'TIMESTEP_END'
    []
    [volume_rate]
        type = ParsedPostprocessor
        expression = 'inlet_rate*${omega_Si}'
        pp_names = 'inlet_rate'
        execute_on = 'TIMESTEP_END'
    []
[]

[Functions]
    [flux]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux}'
    []
    [phi0C]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 3
    []
    [alphaC0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 4
    []
[]

[UserObjects]
    [reader_object]
        type = PropertyReadFile
        prop_file_name = 'gold/${phiC0_data}'
        read_type = 'voronoi'
        nprop = 5 # number of columns in CSV
        nvoronoi = ${phiC0_ndata} # number of rows that are considered
    []
[]

[BCs]
    [inlet]
        type = InfiltrationWake
        variable = alpha
        boundary = 'core_sides'
        inlet_flux = 'flux'
        outlet_flux = 'flux'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdalpha
        liquid_fraction = phi_Si
        liquid_fraction_derivative = neml2_dphiSidalpha
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdalpha
        multiplier = M
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type' #-snes_type'
    petsc_options_value = 'lu' # vinewtonrsls'
    automatic_scaling = true

    line_search = none

    nl_abs_tol = 1e-06
    nl_rel_tol = 1e-08
    nl_max_its = 12

    end_time = ${total_time}
    dtmax = '${fparse 10*dt}'

    [TimeStepper]
        type = IterationAdaptiveDT
        dt = ${dt} #s
        optimal_iterations = 6
        iteration_window = 2
        cutback_factor = 0.5
        cutback_factor_at_failure = 0.1
        growth_factor = 1.2
        linear_iteration_ratio = 10000
    []

    #fixed_point_max_its = 10
    #fixed_point_algorithm = picard
    #fixed_point_abs_tol = 1e-06
    #fixed_point_rel_tol = 1e-08
[]

[Outputs]
    exodus = true
    file_base = '${base_folder}/core'
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = '${base_folder}/out'
    []
    print_linear_residuals = false
[]