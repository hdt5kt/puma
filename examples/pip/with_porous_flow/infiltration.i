############### Calculations ################
# Simulation parameters
dt = 5

t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
theat = '${fparse t_ramp+t_hold*3600}'
dTdtcool = '${fparse (Tmax-T0)/(tcool*3600)}' #Ks-1
total_time = '${fparse theat + tcool*3600}'

[GlobalParams]
    displacements = 'disp_x disp_y'
    temperature = 'T'
    fluid_fraction = 'phif'
    pressure = 'P'
[]

[Variables]
    [P]
    []
    [phif]
    []
    [T]
    []
[]

[Kernels]
    ## Fluid flow ---------------------------------------------------------
    [time]
        type = PumaCoupledTimeDerivative
        material_prop = M1
        variable = phif
        material_fluid_fraction_derivative = dM1dphif
        material_pressure_derivative = dM1dP
        material_temperature_derivative = dM1dT
        material_deformation_gradient_derivative = dM1dF
        stabilize_strain = true
    []
    [diffusion]
        type = PumaCoupledDiffusion
        material_prop = M2
        variable = phif
        material_fluid_fraction_derivative = dM2dphif
        material_pressure_derivative = dM2dP
        material_temperature_derivative = dM2dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [darcy_nograv]
        type = PumaCoupledDarcyFlow
        coupled_variable = P
        material_prop = M3
        variable = phif
        material_fluid_fraction_derivative = dM3dphif
        material_pressure_derivative = dM3dP
        material_temperature_derivative = dM3dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [gravity]
        type = CoupledAdditiveFlux
        material_prop = M4
        value = '0.0 ${gravity} 0.0'
        variable = phif
        material_fluid_fraction_derivative = dM4dphif
        material_pressure_derivative = dM4dP
        material_temperature_derivative = dM4dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [L2]
        type = CoupledL2Projection
        material_prop = M5
        variable = P
        material_fluid_fraction_derivative = dM5dphif
        material_pressure_derivative = dM5dP
        material_temperature_derivative = dM5dT
        material_deformation_gradient_derivative = dM5dF
        stabilize_strain = true
    []
    ## Temperature flow ---------------------------------------------------------
    [temp_time]
        type = PumaCoupledTimeDerivative
        material_prop = M6
        variable = T
        material_fluid_fraction_derivative = dM6dphif
        material_pressure_derivative = dM6dP
        material_temperature_derivative = dM6dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [temp_diffusion]
        type = PumaCoupledDiffusion
        material_prop = M7
        variable = T
        material_fluid_fraction_derivative = dM7dphif
        material_pressure_derivative = dM7dP
        material_temperature_derivative = dM7dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [temp_darcy_nograv]
        type = PumaCoupledDarcyFlow
        coupled_variable = P
        material_prop = M8
        variable = T
        material_fluid_fraction_derivative = dM8dphif
        material_pressure_derivative = dM8dP
        material_temperature_derivative = dM8dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    [temp_gravity]
        type = CoupledAdditiveFlux
        material_prop = M9
        value = '0.0 ${gravity} 0.0'
        variable = T
        material_fluid_fraction_derivative = dM9dphif
        material_pressure_derivative = dM9dP
        material_temperature_derivative = dM9dT
        material_deformation_gradient_derivative = zeroR2
        stabilize_strain = true
    []
    ##
    ## solid mechanics ---------------------------------------------------------
    [offDiagStressDiv_x]
        type = MomentumBalanceCoupledJacobian
        component = 0
        variable = disp_x
        material_fluid_fraction_derivative = dpk1dphif
        material_pressure_derivative = zeroR2
        material_temperature_derivative = dpk1dT
    []
    [offDiagStressDiv_y]
        type = MomentumBalanceCoupledJacobian
        component = 1
        variable = disp_y
        material_fluid_fraction_derivative = dpk1dphif
        material_pressure_derivative = zeroR2
        material_temperature_derivative = dpk1dT
    []
[]

[Physics]
    [SolidMechanics]
        [QuasiStatic]
            [sample]
                new_system = true
                add_variables = true
                strain = FINITE
                formulation = TOTAL
                volumetric_locking_correction = true
                generate_output = "pk1_stress_xx pk1_stress_yy pk1_stress_zz 
                                    pk1_stress_xy pk1_stress_xz pk1_stress_yz vonmises_pk1_stress
                                    max_principal_pk1_stress"
            []
        []
    []
[]

[NEML2]
    input = 'neml2/infiltration.i'
    cli_args = 'kk_L=${kk_PR} permeability_power=${permeability_power} rhof_nu=${fparse rho_PR/mu_PR}
              rhof2_nu=${fparse rho_PR^2/mu_PR} phif_residual=${phi_L_residual} rho_f=${fparse rho_PR}
              brooks_corey_threshold=${brooks_corey_threshold} capillary_pressure_power=${capillary_pressure_power}
              nu=${nu} advs_coefficient=${advs_coefficient} hf_rhof_nu=${fparse hf*rho_PR/mu_PR}
              hf_rhof2_nu=${fparse hf*rho_PR^2/mu_PR} therm_expansion=${therm_expansion} Tref=${T0}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE    VARIABLE MATERIAL'
        moose_inputs = '     phif        T        deformation_gradient'
        neml2_inputs = '     forces/phif forces/T forces/F'

        moose_parameter_types = 'MATERIAL       MATERIAL'
        moose_parameters = '     void           E       '
        neml2_parameters = '     phif_max_param S_pk2_E '

        moose_output_types = 'MATERIAL   MATERIAL MATERIAL MATERIAL MATERIAL
                          MATERIAL MATERIAL MATERIAL   MATERIAL    MATERIAL'
        moose_outputs = '     pk1_stress M1       M3       M4       M5
                          M8       M9       poro       phis        perm'
        neml2_outputs = '     state/pk1  state/M1 state/M3 state/M4 state/M5
                          state/M8 state/M9 state/poro state/solid state/perm'

        moose_derivative_types = 'MATERIAL               MATERIAL             MATERIAL
                              MATERIAL               MATERIAL             MATERIAL
                              MATERIAL               MATERIAL'
        moose_derivatives = '     dM5dphif               dM1dF                pk1_jacobian
                              dpk1dphif              dM5dF                dpk1dT
                              dM4dphif               dM9dphif'
        neml2_derivatives = '     state/M5  forces/phif; state/M1 forces/F;   state/pk1 forces/F;
                              state/pk1 forces/phif; state/M5 forces/F;   state/pk1 forces/T;
                              state/M4  forces/phif; state/M9 forces/phif'
    []
[]