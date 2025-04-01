base_fold = 'less_Si_high_Dbar_newmesh'

############### Input ################

# Simulation parameters
dt = 1 #s
total_time = 1800 #s

# in case of overflown at boundary, the rate of silicon amount being remove
t_ramp = 10
flux = 2.5e-3 #5e-2
#flux_out = 1e-5
zshift = 0

levelset_smooth_transistion = 0.1 #cm - mesh dependence

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_SiC = 3.21
rho_C = 2.26

# material property
D_LP = 2.5e-5 # cm2 s-1
l_c = 1.0 # cm

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# macroscopic property
D_macro = 0.01 #cm2 s-1

# initial condition
phi0_SiC = 0.4
phi0_C = 0.1

m_Si = 13.94 #g

## pool geometry (needs to matched the mesh file) - cm
# reference point is the center of the core
x_core = 1.48
y_core = 1.48
core_shift = 0.1

# pool - cm
r_pool_up = 3
taper_depth = 1
furnace_depth = 2

## Calculations
D_bar = '${fparse D_LP/(l_c^2)}'

omega_C = '${fparse M_C/rho_C}'
omega_Si = '${fparse M_Si/rho_Si}'
omega_SiC = '${fparse M_SiC/rho_SiC}'

oCm1 = '${fparse 1/omega_C}'
oSiCm1 = '${fparse 1/omega_SiC}'

chem_ratio = '${fparse k_SiC/k_C}'

alpha0_SiC = '${fparse phi0_SiC/omega_SiC}'
alpha0_C = '${fparse phi0_C/omega_C}'

r_pool_down = '${fparse ((core_shift+(furnace_depth-taper_depth))/furnace_depth)*r_pool_up}'
h_pool_low = '${fparse furnace_depth-taper_depth-core_shift}'

V_pool_low = '${fparse 1/3*3.14156*h_pool_low*(r_pool_up^2 + r_pool_down^2 + r_pool_up*r_pool_down) - x_core*y_core*h_pool_low}'
V_extra_bottom = '${fparse x_core*y_core*core_shift}'

V_Si = '${fparse m_Si/rho_Si}'

h0_pool0 = '${fparse if(V_Si < (V_pool_low+V_extra_bottom), (V_pool_low-V_Si - V_extra_bottom)/(1/3*3.14156*(r_pool_up^2 + r_pool_down^2 + r_pool_up*r_pool_down) - x_core*y_core), (V_Si-V_pool_low-V_extra_bottom)/(3.14156*r_pool_up^2-x_core*y_core)+h_pool_low)}'
h0_pool = '${fparse h0_pool0 + core_shift}'

# h0_pool = 1.2 #cm

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = 'gold/core_in_meltpool_v2.msh'
    []
    [delete]
        type = BlockDeletionGenerator
        input = mesh0
        block = 'melt_pool'
    []
[]

[MultiApps]
    [melt_pool]
        type = TransientMultiApp
        input_files = 'melt_pool.i'
        cli_args = 'h0=${h0_pool};L0=${levelset_smooth_transistion};zshift=${zshift};base_fold=${base_fold}'
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
        to_boundaries = 'interface'
        error_on_miss = true
        search_value_conflicts = false
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
        prop_names = ' aSiC0         phi0_SiC    D          phi0_C   aC0'
        prop_values = '${alpha0_SiC} ${phi0_SiC} ${D_macro} ${phi0_C} ${alpha0_C}'
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
        boundary = 'interface'
        execute_on = 'TIMESTEP_END'
    []
    [volume_rate]
        type = ParsedPostprocessor
        expression = 'inlet_rate*${omega_Si}'
        pp_names = 'inlet_rate'
        execute_on = 'TIMESTEP_END'
    []
[]

[VectorPostprocessors]
    [data_center_line]
        type = LineValueSampler
        end_point = '0 0 6.46'
        num_points = 50
        sort_by = 'z'
        start_point = '0 0 0.1'
        variable = 'phi_SiC void_fraction phi_C phi_Si'
        execute_on = 'TIMESTEP_END'
    []
[]

[Functions]
    [flux]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux}'
    []
[]

[BCs]
    [inlet]
        type = InfiltrationWake
        variable = alpha
        boundary = 'interface'
        inlet_flux = 'flux'
        outlet_flux = 'flux'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdalpha
        liquid_fraction = phi_Si
        liquid_fraction_derivative = neml2_dphiSidalpha
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdalpha
        multiplier = M
        #multiplier_residual = 0.001
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options = '-ksp_converged_reason'
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
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
    reuse_preconditioner = true

    #fixed_point_max_its = 10
    #fixed_point_algorithm = picard
    #fixed_point_abs_tol = 1e-06
    #fixed_point_rel_tol = 1e-08
[]

[Outputs]
    exodus = true
    file_base = '${base_fold}/core'
    execute_on = 'INITIAL TIMESTEP_END'
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = '${base_fold}/out'
        time_step_interval = 10
    []
    print_linear_residuals = false
[]