############### Input ################

# Simulation parameters
dt = 5 #s
total_time = 5000 #s
n = 100
L = 2
t_ramp = 60

flux_in = 0.001 # volume fraction
# in case of overflown at boundary, the rate of silicon amount being remove
flux_out = 0.01

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_SiC = 3.21
rho_C = 2.26

# material property
D_LP = 2.65e-4 # cm2 s-1
l_c = 1.0 # cm

brooks_corey_threshold = 1e5 #Pa
capillary_pressure_power = 3
phi_L_residual = 0.0

permeability_power = 3

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# liquid viscosity
mu_Si = 10

# solid permeability
kk_Si = 2e-5

# macroscopic property
D_macro = 0.001 #cm2 s-1

# initial condition
phi0_SiC = 0.0
phi0_C = 0.75

## Calculations

advec_constant = '${fparse rho_Si/ (M_Si * mu_Si)}'

D_bar = '${fparse D_LP/(l_c^2)}'

omega_C = '${fparse M_C/rho_C}'
omega_Si = '${fparse M_Si/rho_Si}'
omega_SiC = '${fparse M_SiC/rho_SiC}'

oCm1 = '${fparse 1/omega_C}'
oSiCm1 = '${fparse 1/omega_SiC}'

chem_ratio = '${fparse k_SiC/k_C}'

alpha0_SiC = '${fparse phi0_SiC/omega_SiC}'
alpha0_C = '${fparse phi0_C/omega_C}'

[Mesh]
    type = GeneratedMesh
    dim = 1
    nx = ${n}
    xmax = ${L}
[]

[Variables]
    [phi_Si]
    []
[]

[AuxVariables]
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
            type = MaterialRealAux
            property = void_fraction
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [Pc]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = Pc
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [dPcdphiSi]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = dPcdphiSi
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [permeability]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = permeability
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [Dtotal]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = Ftotal
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[Kernels]
    [transient]
        type = TimeDerivative
        variable = phi_Si
    []
    [diffusion]
        type = PumaDiffusion
        diffusivity_derivative = neml2_dFluxdphiSi
        variable = phi_Si
        diffusivity = Ftotal
    []
    [reaction]
        type = MaterialSource
        variable = phi_Si
        prop = phirate_Si
        prop_derivative = neml2_dphiSiDotdphiSi
        coefficient = 1
    []
[]

[NEML2]
    input = 'neml2/Si_SiC_C.i'
    cli_args = 'D=${D_bar} omega_Si=${omega_Si} oSiCm1=${oSiCm1} oCm1=${oCm1}
                chem_ratio=${chem_ratio} chem_P=${k_SiC} kk_Si=${kk_Si}
                capillary_pressure_power=${capillary_pressure_power}
                brooks_corey_threshold=${brooks_corey_threshold}
                phi_L_residual=${phi_L_residual}
                F_diffusion=${D_macro} advec_constant=${advec_constant}
                permeability_power=${permeability_power}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE          POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL          MATERIAL      MATERIAL'
        moose_inputs = '     phi_Si            time          time          alpha_SiC
                             alpha_C           phi_SiC       phi_C'
        neml2_inputs = '     forces/phi_L      forces/t      old_forces/t  old_state/alpha_P
                             old_state/alpha_S state/phi_P   state/phi_S'

        moose_output_types = 'MATERIAL        MATERIAL        MATERIAL      MATERIAL     MATERIAL
                              MATERIAL        MATERIAL        MATERIAL      MATERIAL     MATERIAL'
        moose_outputs = '     phirate_Si      alpha_SiC       alpha_C       phi_SiC      phi_C
                              Pc              dPcdphiSi       permeability  Ftotal       void_fraction'
        neml2_outputs = '     state/phidot_L  state/alpha_P   state/alpha_S state/phi_P  state/phi_S
                              state/Pc        state/dPcdphiL state/perm     state/Ftotal state/vf'

        moose_derivative_types = 'MATERIAL                      MATERIAL
                                  MATERIAL                      MATERIAL
                                  MATERIAL                      '
        moose_derivatives = '     neml2_dphiSiDotdphiSi         neml2_dphiCdphiSi
                                  neml2_dphiSiCdphiSi           neml2_dPcdphiSi
                                  neml2_dFluxdphiSi             '
        neml2_derivatives = '     state/phidot_L forces/phi_L;  state/phi_S forces/phi_L;
                                  state/phi_P forces/phi_L;     state/Pc forces/phi_L;
                                  state/Ftotal forces/phi_L'

        initialize_outputs = '      alpha_SiC alpha_C phi_SiC  phi_C'
        initialize_output_values = 'aSiC0     aC0     phi0_SiC phi0_C'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = ' aSiC0         phi0_SiC    phi0_C    aC0'
        prop_values = '${alpha0_SiC} ${phi0_SiC} ${phi0_C} ${alpha0_C}'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[Functions]
    [flux_in]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux_in}'
    []
    [flux_out]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux_out}'
    []
[]

[BCs]
    #[left]
    #    type = NeumannBC
    #    boundary = 'left'
    #    variable = phi_Si
    #    value = 0.01
    #[]
    [left]
        type = InfiltrationWake
        variable = phi_Si
        boundary = left
        inlet_flux = 'flux_in'
        outlet_flux = 'flux_out'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdphiSi
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdphiSi
        no_flux_fraction_transition = 0.1
    []
    [right]
        type = InfiltrationWake
        variable = phi_Si
        boundary = right
        inlet_flux = 'flux_in'
        outlet_flux = 'flux_out'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdphiSi
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdphiSi
        no_flux_fraction_transition = 0.1
    []
[]

[VectorPostprocessors]
    [value]
        type = LineValueSampler
        start_point = '0 0 0'
        end_point = '${L} 0 0'
        num_points = ${n}
        variable = 'phi_Si phi_SiC phi_C void_fraction Pc dPcdphiSi permeability Dtotal'
        sort_by = 'x'
        execute_on = 'INITIAL TIMESTEP_END'
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type' #-snes_type'
    petsc_options_value = 'lu' # vinewtonrsls'
    automatic_scaling = true

    line_search = none

    nl_abs_tol = 1e-6
    nl_rel_tol = 1e-8
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
    [console]
        type = Console
        execute_postprocessors_on = NONE
    []
    [csv]
        type = CSV
        file_base = 'output/out'
    []
    print_linear_residuals = false
[]