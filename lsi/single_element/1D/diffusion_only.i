############### Input ################

# Simulation parameters
dt = 1
total_time = 21000
t_ramp = ${total_time}
nx = 1
xmax = 1
alpha0 = 0.01
alpha_max = 0.1 # mol/cm^3

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_SiC = 3.21
rho_C = 2.26

# material property
D_LP = 2.65e-10 # cm2 s-1
l_c = 100e-4 # cm

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# macroscopic property
# D_macro = 1e-6 #cm2 s-1

# initial condition
phi0_SiC = 0.000001
phi0_C = 0.5

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
    nx = '${nx}'
    xmax = '${xmax}'
[]

[Variables]
    [alpha]
    []
[]

[Kernels]
    [diffusion]
        type = Diffusion
        variable = alpha
    []
[]

[NEML2]
    input = 'neml2/Si_SiC_C.i'
    cli_args = 'D=${D_bar} omega_Si=${omega_Si} oSiCm1=${oSiCm1} oCm1=${oCm1} chem_ratio=${chem_ratio}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE          POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL          MATERIAL      MATERIAL'
        moose_inputs = '     alpha             time          time          alpha_SiC
                             alpha_C           phi_SiC       phi_C'
        neml2_inputs = '     forces/alpha      forces/t      old_forces/t  old_state/alpha_P
                             old_state/alpha_S state/phi_P   state/phi_S'

        moose_output_types = 'MATERIAL      MATERIAL      MATERIAL    MATERIAL    MATERIAL'
        moose_outputs = '     alpha_SiC     alpha_C       phi_Si      phi_SiC    phi_C'
        neml2_outputs = '     state/alpha_P state/alpha_S state/phi_L state/phi_P state/phi_S'

        #moose_derivative_types = ''
        #moose_derivatives = ''
        #neml2_derivatives = ''

        initialize_outputs = '      alpha_SiC alpha_C phi_SiC  phi_C'
        initialize_output_values = 'aSiC0     aC0     phi0_SiC phi0_C'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = ' aSiC0         aC0         phi0_SiC    phi0_C'
        prop_values = '${alpha0_SiC} ${alpha0_C} ${phi0_SiC} ${phi0_C}'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [alpha]
        type = ElementAverageValue
        variable = alpha
    []
    [phi_Si]
        type = ElementAverageMaterialProperty
        mat_prop = phi_Si
    []
    [phi_SiC]
        type = ElementAverageMaterialProperty
        mat_prop = phi_SiC
    []
    [phi_C]
        type = ElementAverageMaterialProperty
        mat_prop = phi_C
    []
[]

[ICs]
    [alphaIC]
        type = ConstantIC
        variable = alpha
        value = ${alpha0}
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '${alpha_max} ${alpha_max}'
    []
[]

[BCs]
    [left]
        type = FunctionDirichletBC
        boundary = left
        variable = alpha
        function = tramp
    []
    [right]
        type = FunctionDirichletBC
        boundary = right
        variable = alpha
        function = tramp
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true

    nl_abs_tol = 1e-8

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
[]

[Outputs]
    exodus = true
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = 'solution1/out'
    []
    print_linear_residuals = false
[]