############### Input ################
# Simulation parameters

T0 = 400 #K
Tmax = 1000 #K
Tref = 273 #K

dt = 10
dTdt = 10 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
total_time = ${t_ramp}

n = 1

# denisty kgm-3
rho_s = 320
rho_b = 1250 # 1.2 and 1.4
rho_g = 1
rho_p = 3210

rho_sm1 = '${fparse 1/rho_s}'
rho_bm1 = '${fparse 1/rho_b}'
rho_gm1 = '${fparse 1/rho_g}'
rho_pm1 = '${fparse 1/rho_p}'

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
Ea = 177820 # J mol-1
A = 5.24e12 # s-1
R = 8.31446261815324 # JK-1mol-1
#hrp = 1.58e6 #e6 J kg-1
#factor = 1.0

Y = 0.55
Ym1 = '${fparse 1/Y}' # 1/Y
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 1.0

# initial condition #kg
ms0 = 300
mb0 = 1200
mp0 = 3000
mg0 = 1e-4
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)
vv0 = 0.1 #void fraction
Vv0 = '${fparse vv0/(1-vv0)*(ms0/rho_s + mb0/rho_b + mp0/rho_p)}'

V0 = '${fparse ms0/rho_s + mb0/rho_b + mp0/rho_p + Vv0}'

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
    nx = '${n}'
    ny = '${n}'
    nz = '${n}'
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
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p}
                rho_sm1=${rho_sm1} rho_bm1=${rho_bm1} rho_gm1=${rho_gm1} rho_pm1=${rho_pm1}
                cp_s=${cp_s} cp_b=${cp_b} cp_g=${cp_g} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_g=${k_g} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} Ym1=${Ym1} invYm1=${invYm1}
                order=${order} order_k=${order_k}
                ms0=${ms0} mb0=${mb0} mg0=${mg0} mp0=${mp0} Vv0=${Vv0} V0=${V0} alpha0=${alpha0}
                E=${E} mu=${mu} g=${g} Tref=${Tref}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL'
        moose_inputs = '     T            time          time          alpha
                             mb           mg            mp            ms              Vv
                             mb           mg            mp            ms              Vv
                             neml2_strain'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha
                             state/mb     state/mg      state/mp      state/ms        state/Vv
                             old_state/mb old_state/mg  old_state/mp  old_state/ms    old_state/Vv
                             forces/eps'

        moose_output_types = 'MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL    MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL    MATERIAL
                              MATERIAL'
        moose_outputs = '     mp       mb       mg        ms
                              wp       wb       ws        alpha       alphadot
                              vp       vb       vv        vs
                              Vp       Vb       Vv        Vs
                              K        V        rho       cp          rhocp
                              neml2_stress'
        neml2_outputs = '     state/mp state/mb state/mg  state/ms
                              state/wp state/wb state/ws  state/alpha state/alpha_dot
                              state/vp state/vb state/vv  state/vs
                              state/Vp state/Vb state/Vv  state/Vs
                              state/K  state/V  state/rho state/cp    state/rhocp
                              state/sigma'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL
                                  MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT
                                  neml2_dsigdeps'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T;
                                  state/sigma forces/eps'

        initialize_outputs = '      mp  mb  mg  ms  alpha  Vv'
        initialize_output_values = 'mp0 mb0 mg0 ms0 alpha0 Vv0'
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
        prop_names = 'mp0 mb0 mg0 ms0 alpha0 Vv0'
        prop_values = '${mp0} ${mb0} ${mg0} ${ms0} ${alpha0} ${Vv0}'
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
        type = NodalMaxValue
        variable = disp_x
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
    dtmax = '${fparse 2*dt}'

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