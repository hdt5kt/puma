############### Input ################

# Simulation parameters
dt = 5 #s
total_time = 600 #s
n = 1
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

brooks_corey_threshold = 1e5 #Pa
capillary_pressure_power = 3
phi_L_residual = 0.0

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

# liquid viscosity
# mu_Si = 10

# solid permeability
# kk_Si = 1e-5 # 1e-5

# macroscopic property
D_macro = 0.0 #cm2 s-1

# initial condition
phi0_SiC = 0.0
phi0_C = 0.0

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

phimax_Si = '${fparse (1-phi0_SiC-phi0_C-0.001)}'

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
[]

[Kernels]
    [transient]
        type = TimeDerivative
        variable = phi_Si
    []
    [diffusion]
        type = MatDiffusion
        variable = phi_Si
        diffusivity = ${D_macro}
    []
[]

[NEML2]
    input = 'neml2/Si_SiC_C.i'
    cli_args = 'D=${D_bar} omega_Si=${omega_Si} oSiCm1=${oSiCm1} oCm1=${oCm1}
                chem_ratio=${chem_ratio} chem_P=${k_SiC}
                capillary_pressure_power=${capillary_pressure_power}
                brooks_corey_threshold=${brooks_corey_threshold}
                phi_L_residual=${phi_L_residual}'
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

        moose_output_types = 'MATERIAL        MATERIAL       MATERIAL      MATERIAL         MATERIAL
                              MATERIAL        MATERIAL       MATERIAL      MATERIAL         MATERIAL'
        moose_outputs = '     phirate_Si      alpha_SiC      alpha_C       phi_SiC          phi_C
                              Pc              phimax_L       Seff          dPcdphiSi        void_fraction'
        neml2_outputs = '     state/phidot_L  state/alpha_P  state/alpha_S state/phi_P      state/phi_S
                              state/Pc        state/phimax_L state/Seff    state/dPcdphiL   state/vf'

        moose_derivative_types = 'MATERIAL                      MATERIAL
                                  MATERIAL                      MATERIAL'
        moose_derivatives = '     neml2_dpDotdphiSi             neml2_dphiCdphiSi
                                  neml2_dphiSiCdphiSi           neml2_dPcdphiSi'
        neml2_derivatives = '     state/phidot_L forces/phi_L;  state/phi_S forces/phi_L;
                                  state/phi_P forces/phi_L;     state/Pc forces/phi_L'

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
    [Pc]
        type = ElementAverageMaterialProperty
        mat_prop = Pc
    []
    [phimax]
        type = ElementAverageMaterialProperty
        mat_prop = phimax_L
    []
    [Seff]
        type = ElementAverageMaterialProperty
        mat_prop = Seff
    []
    [phi_Si]
        type = ElementAverageValue
        variable = phi_Si
    []
    [dPcdphiSi]
        type = ElementAverageMaterialProperty
        mat_prop = dPcdphiSi
    []
[]

[Functions]
    [flux]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${flux}'
    []
    [phiSi_Dirichlet]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '0 ${phimax_Si}'
    []
[]

[BCs]
    [left]
        type = FunctionDirichletBC
        function = phiSi_Dirichlet
        boundary = 'left right'
        variable = phi_Si
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