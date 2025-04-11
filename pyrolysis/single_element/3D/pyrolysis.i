############### Input ################
# Simulation parameters
dt = 1
total_time = 3600
t_ramp = ${total_time}
nx = 1

# denisty kgm-3
rho_s = 2100
rho_b = 1250 # 1.2 and 1.4
rho_p = 3210

# heat capacity Jkg-1K-1
cp_s = 1592
cp_b = 1200
cp_g = 1e-4
cp_p = 750

# thermal conductivity W/m-1K-1
k_s = 1.5
k_b = 0.279
k_g = 1e-4
k_p = 380 #120 and 490

# reaction type
Ea = 41220 # 177820 # J mol-1
A = 1.24e4 # 5.24e12 # s-1
R = 8.31446261815324 # JK-1mol-1
#hrp = 1.58e6 # J kg-1

Y = 0.575
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 0.00015

# models
cp_to_wg_relation = 0.001
op_to_solid_relation = 0.1
rho_g = 13 #kgm-3

# initial condition
ms0 = 1
mb0 = 10
mp0 = 3
mg0 = 0.001
mgcp0 = '${fparse mg0}'
phiop0 = 0.001 #void fraction
T0 = 300 #K

# calculations

Mref = '${fparse ms0 + mb0 + mp0 + mg0}'
V0 = '${fparse (ms0/rho_s + mb0/rho_b + mp0/rho_p + mgcp0/rho_g)/(1 - phiop0)}'
wb0 = '${fparse mb0/Mref}'
ws0 = '${fparse ms0/Mref}'
wp0 = '${fparse mp0/Mref}'
wgcp0 = '${fparse mgcp0/Mref}'
phis0 = '${fparse ws0*Mref/(rho_s*V0)}'
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)

Tmax = 1500 #K
Tref = 300 #K

#### stress-strain ####
E = 400e9
mu = 0.3

# thermal expansion coefficients (degree-1)
g = 0.0

[GlobalParams]
    displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
    type = GeneratedMesh
    dim = 3
    nx = '${nx}'
    ny = '${nx}'
    nz = '${nx}'
    xmax = 1.0
    ymax = 1.0
    zmax = 1.0
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [heat_eq]
        type = Diffusion
        variable = T
    []
[]

[Physics]
    [SolidMechanics]
        [QuasiStatic]
            [sample]
                new_system = true
                add_variables = true
                strain = SMALL
                formulation = TOTAL
                volumetric_locking_correction = true
                generate_output = "cauchy_stress_xx cauchy_stress_yy cauchy_stress_zz
                                cauchy_stress_xy cauchy_stress_xz cauchy_stress_yz
                                strain_xx strain_yy strain_zz"
                additional_generate_output = 'vonmises_cauchy_stress'
            []
        []
    []
[]

[NEML2]
    input = 'neml2/PR_pyrolysis.i'
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p} Mref=${Mref}
                rho_sm1M=${fparse Mref/rho_s} rho_bm1M=${fparse Mref/rho_b}
                rho_gm1M=${fparse Mref/rho_g} rho_pm1M=${fparse Mref/rho_p}
                cp_s=${cp_s} cp_b=${cp_b} cp_g=${cp_g} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_g=${k_g} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} invYm1=${invYm1}
                order=${order} order_k=${order_k}
                cp_to_wg_relation=${cp_to_wg_relation} op_to_solid_relation=${op_to_solid_relation}
                ws0=${ws0} wb0=${wb0} alpha0=${alpha0} Tref=${Tref} E=${E} g=${g} mu=${mu}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL'
        moose_inputs = '     T            time          time          alpha           phis
                             wb           wp            ws            wgcp            phiop
                             wb           wp            ws            wgcp            phiop
                             eps_Ev       eps_Ev        neml2_strain  V'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha old_state/phis
                             state/wb     state/wp      state/ws      state/wgcp      state/phiop
                             old_state/wb old_state/wp  old_state/ws  old_state/wgcp  old_state/phiop
                             state/Ev     old_state/Ev  forces/eps    old_state/V'

        moose_output_types = 'MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL
                              MATERIAL        MATERIAL'
        moose_outputs = '     wb              wp         ws         wgcp         phiop
                              phib            phip       phis       phigcp       alpha
                              alpha_dot       K          V          rhocp
                              neml2_stress    eps_Ev'
        neml2_outputs = '     state/wb        state/wp   state/ws   state/wgcp   state/phiop
                              state/phib      state/phip state/phis state/phigcp state/alpha
                              state/alpha_dot state/K    state/V    state/rhocp
                              state/sigma     state/Ev'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL
                                  MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT
                                  neml2_dsigdeps'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T;
                                  state/sigma forces/eps'

        initialize_outputs = '      wp  wb  wgcp  ws  alpha  phis  phiop  V eps_Ev'
        initialize_output_values = 'wp0 wb0 wgcp0 ws0 alpha0 phis0 phiop0 V0 eps_Ev0'
    []
[]

[AuxVariables]
    [volume]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
    [volume_aux]
        type = VolumeAux
        variable = volume
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'wp0 wb0 wgcp0 ws0 alpha0 phis0 phiop0 V0 eps_Ev0'
        prop_values = '${wp0} ${wb0} ${wgcp0} ${ws0} ${alpha0} ${phis0} ${phiop0} ${V0} 0.0'
    []
    [convert_strain]
        type = RankTwoTensorToSymmetricRankTwoTensor
        from = 'total_strain'
        to = 'neml2_strain'
    []
    [stress]
        type = ComputeLagrangianObjectiveCustomSymmetricStress
        custom_small_stress = 'neml2_stress'
        custom_small_jacobian = 'neml2_dsigdeps'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [neml2V]
        type = ElementAverageMaterialProperty
        mat_prop = V
    []
    [temp]
        type = ElementAverageValue
        variable = T
    []
    [epsxx]
        type = ElementAverageMaterialProperty
        mat_prop = strain_xx
    []
    [epsyy]
        type = ElementAverageMaterialProperty
        mat_prop = strain_yy
    []
    [epszz]
        type = ElementAverageMaterialProperty
        mat_prop = strain_zz
    []
    [feaV]
        type = VolumePostprocessor
        use_displaced_mesh = true
    []
    [maxdispx]
        type = NodalExtremeValue
        variable = disp_x
    []
    [volume_eigenstrain]
        type = ElementAverageMaterialProperty
        mat_prop = eps_Ev
    []
    [wb]
        type = ElementAverageMaterialProperty
        mat_prop = wb
    []
[]

[ICs]
    [alphaIC]
        type = ConstantIC
        variable = T
        value = ${T0}
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '${T0} ${Tmax}'
    []
[]

[BCs]
    [Temp]
        type = FunctionDirichletBC
        boundary = 'top bottom right left front back'
        variable = T
        function = tramp
    []
    [roller_left]
        type = DirichletBC
        boundary = left
        value = 0.0
        variable = disp_x
    []
    [roller_bot]
        type = DirichletBC
        boundary = bottom
        value = 0.0
        variable = disp_y
    []
    [roller_back]
        type = DirichletBC
        boundary = back
        value = 0.0
        variable = disp_z
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
        optimal_iterations = 7
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
        file_base = 'volume_check/out'
    []
    print_linear_residuals = false
[]