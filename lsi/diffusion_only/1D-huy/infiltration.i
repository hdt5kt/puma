############### Input ################

# Simulation parameters
dt = 5 #s
total_time = 1800 #s
n = 100
L = 1
t_ramp = 600

# in case of overflown at boundary, the rate of silicon amount being remove
flux = 1e-4 #5e-2

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

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# macroscopic property
D_macro = 1e-3 #cm2 s-1

# initial condition
phi0_SiC = 0.0001
phi0_C = 0.6

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

[Mesh]
    type = GeneratedMesh
    dim = 1
    nx = ${n}
    xmax = ${L}
[]

[Variables]
    [alpha]
    []
[]

[AuxVariables]
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
        diffusivity = ${D_macro}
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
    [flux]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux}'
    []
[]

[BCs]
    [left]
        type = InfiltrationWake
        variable = alpha
        boundary = left
        inlet_flux = 'flux'
        outlet_flux = 'flux'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdalpha
        liquid_fraction = phi_Si
        liquid_fraction_derivative = neml2_dphiSidalpha
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdalpha
    []
    [right]
        type = InfiltrationWake
        variable = alpha
        boundary = right
        inlet_flux = 'flux'
        outlet_flux = 'flux'
        solid_fraction = phi_C
        solid_fraction_derivative = neml2_dphiCdalpha
        liquid_fraction = phi_Si
        liquid_fraction_derivative = neml2_dphiSidalpha
        product_fraction = phi_SiC
        product_fraction_derivative = neml2_dphiSiCdalpha
    []
[]

[VectorPostprocessors]
    [value]
        type = LineValueSampler
        start_point = '0 0 0'
        end_point = '${L} 0 0'
        num_points = ${n}
        variable = 'alpha phi_Si phi_SiC phi_C void_fraction'
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

    nl_abs_tol = 1e-06
    nl_rel_tol = 1e-08
    nl_max_its = 12

    end_time = ${total_time}
    dtmax = '${fparse 1*dt}'

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
    [csv]
        type = CSV
        file_base = 'results/out'
    []
    print_linear_residuals = false
[]