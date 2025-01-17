clc;
close all;

%Define parameters to sweep
Vin_vals = [100, 200, 300, 400];
Rout_values = [1, 10, 50, 100];
Lout_values = [0.001, 0.01, 0.1, 1];

%lengths
lenVin = length(Vin_vals);
lenRout = length(Rout_values);
lenLout = length(Lout_values);

%Initialize results arrays
THD_resultsI = zeros(lenVin, lenRout, lenLout);
THD_resultsV = zeros(lenVin, lenRout, lenLout);
EfficiencyResults = zeros(lenVin, lenRout, lenLout);
resultsTable=[];

%Simulink Model name
model_name = 'HW2SVPWM';

%Load Model
load_system(model_name);

%get parameters from a block
%get_param('HW2SVPWM/Three-Phase Series RLC Branch', 'DialogParameters')

%Grid Search
for i = 1:lenVin
    for j = 1:lenRout
        for k = 1:lenLout
            %Set params
            set_param([model_name '/DC Voltage Source'], 'Amplitude', num2str(Vin_vals(i)));
            set_param([model_name '/Three-Phase Series RLC Branch'], 'Resistance', num2str(Rout_values(j)));
            set_param([model_name '/Three-Phase Series RLC Branch'], 'Inductance', num2str(Lout_values(k)));

            %run
            simOut = sim(model_name, 'StopTime', '1.0');
            
            % Get the last signal value
            Efficiency = simOut.get('efficiency').signals.values(end, :);

            %Extract Results
            THDI = simOut.get('THDI').signals.values(end, :) * 100;
            THDV = simOut.get('THDV').signals.values(end, :) * 100;

            % Store results in arrays
            THD_resultsI(i, j, k) = THDI;
            THD_resultsV(i, j, k) = THDV;
            EfficiencyResults(i, j, k) = Efficiency;

            %Append to results table
            resultsTable = [resultsTable;
                table(Vin_vals(i), Rout_values(j), Lout_values(k), THDI, THDV, Efficiency, ...
                'VariableNames', {'Vin', 'Rout', 'Lout', 'THD (I)', 'THD (V)', 'Efficiency'})]
        end
    end
end

close_system(model_name);

%Analyze Results:
dips('Simulation Results:');
disp(resultsTable);
