clear;clc;
%% Set PWM Switching frequency
PWM_frequency 	= 1e4;    %Hz          // converter s/w freq
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // Sample time step for controller
Ts_simulink     = T_pwm/2;      %sec        // Simulation time step for model simulation
Ts_motor        = T_pwm/2;      %Sec        // Simulation sample time
Ts_inverter     = T_pwm/2;      %sec        // Simulation time step for average value inverter
Ts_speed        = 10*Ts;        %Sec        // Sample time for speed controller

%% Set data type for controller & code-gen
% dataType = 'fixdt(1,32,15)';            % Floating point code-generation, Fixed point is not supported.
dataTypeMemory = 'single';

%% System Parameters // Hardware parameters
% Motor parameters
% pmsm = mcb_SetPMSMMotorParameters('DM2BLD150-24A-30S');
pmsm.PositionOffset = 0;
pmsm.p      = 2;                %           // Pole Pairs for the motor
pmsm.Rs     = 0.3;              %Ohm        // Stator Resistor
pmsm.Ld     = 0.7e-3;           %H          // D-axis inductance value
pmsm.Lq     = 0.7e-3;           %H          // Q-axis inductance value
pmsm.J      = 2e-06;            %Kg-m2      // Inertia in SI units
pmsm.B      = 5e-06;           %Kg-m2/s    // Friction Co-efficient
pmsm.Ke     = 7.4317;           %Bemf Const	// Vpk_LL/krpm
pmsm.I_rated= 7.81;             %A      	// Rated current (phase-peak)
pmsm.N_max  = 4000;             %rpm        // Max speed
pmsm.N_base = 3000;
pmsm.FluxPM     = (pmsm.Ke)/(sqrt(3)*2*pi*1000*pmsm.p/60); %PM flux computed from Ke
pmsm.T_rated    = (3/2)*pmsm.p*pmsm.FluxPM*pmsm.I_rated;   %Get T_rated from I_rated
pmsm.QEPSlits = 1000;           %           // QEP Encoder Slits

%% Target & Inverter Parameters
target.CPU_frequency        = 60e6;                 %Hz     // Clock frequency
target.PWM_frequency        = PWM_frequency;        %Hz     // PWM frequency
target.PWM_Counter_Period   = round(target.CPU_frequency/target.PWM_frequency/2); %(PWM timer counts)
target.ADC_Vref             = 3.3;					%V		// ADC voltage reference
target.ADC_MaxCount         = 4095;					%		// Max count for 12 bit ADC
target.SCI_baud_rate        = 115200;               %Hz     // Set baud rate for serial communication

% Enable automatic calibration of ADC offset for current measurement
inverter.ADCOffsetCalibEnable = 1; % Enable: 1, Disable:0
% offset values below manually
inverter.CtSensAOffset = 1970;      % ADC Offset for phase current A
inverter.CtSensBOffset = 1967;      % ADC Offset for phase current B
% Max and min ADC counts for current sense offsets
inverter.CtSensOffsetMax = 2500; % Maximum permitted ADC counts for current sense offset
inverter.CtSensOffsetMin = 1500; % Minimum permitted ADC counts for current sense offset

inverter.V_dc = 24;                %V		// DC Link Voltage of the Inverter
inverter.I_trip        = 10;       				%Amps   // Max current for trip
inverter.Rds_on        = 6.5e-3;   				%Ohms   // Rds ON for BoostXL-DRV8301
inverter.Rshunt        = 0.025;    				%Ohms   // Rshunt for BoostXL-DRV8301
inverter.CtSensAOffset = 2048;     				%Counts // ADC Offset for phase-A
inverter.CtSensBOffset = 2048;     				%Counts // ADC Offset for phase-B
inverter.EnableLogic   = 1;    					% 		// Active high for DRV8301 enable pin (EN_GATE)
inverter.invertingAmp  = 1;   					% 		// Non inverting current measurement amplifier
inverter.ISenseVref    = 3.3;					%V 		// Voltage ref of inverter current sense circuit
inverter.ISenseVoltPerAmp = 0.025; 				%V/Amps // Current sense voltage output per 1 A current (Rshunt * iSense op-amp gain)
inverter.ISenseMax    = inverter.ISenseVref/(2*inverter.ISenseVoltPerAmp); %Amps // Maximum Peak-Neutral current that can be measured by inverter current sense
inverter.R_board        = inverter.Rds_on + inverter.Rshunt/3;  %Ohms

%% Position Sensor
PosSensAOffset = 2048;
PosSensBOffset = 2048;
ThetaOffset = 1-0.782;

%% PU System details // Set base values for pu conversion
SI_System = mcb_SetSISystem(pmsm);

%% Controller design // Get ballpark values!
%Updating delays for simulation
PI_params.delay_Currents    = int32(Ts/Ts_simulink);
PI_params.delay_Position    = int32(Ts/Ts_simulink);
PI_params.delay_Speed       = int32(Ts_speed/Ts_simulink);
PI_params.delay_IIR         = 0.02;
PI_params.delay_Speed1      = (PI_params.delay_IIR + 0.5*Ts)/Ts_speed;

%% Current PID Controller Gain
Gain = 10;
% mcb_getControlAnalysis(pmsm,inverter,PU_System,PI_params,Ts,Ts_speed);

%% Displaying model variables
disp(pmsm);
disp(inverter);
disp(target);


