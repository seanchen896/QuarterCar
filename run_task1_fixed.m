%% run_task1_fixed.m
% Initialize, check, simulate, and plot the corrected Task 1 model.

clear
clc
close all

run('task1_initialize_fixed.m')
model = 'quarterCarModel_fixed';

if ~isfile(model + ".slx")
    error('Place %s.slx in the current MATLAB folder.',model)
end

load_system(model)

% Confirm that required workspace variables are available.
required = {'ms','mu','Ks','Cs','Kt','Ct','Tstop','roadInput'};
for k = 1:numel(required)
    if ~evalin('base',sprintf("exist('%s','var')",required{k}))
        error('Required variable %s is missing.',required{k})
    end
end

% Compile/update first so configuration problems appear clearly.
set_param(model,'SimulationCommand','update')

simOut = sim(model, ...
    'StopTime',num2str(Tstop), ...
    'ReturnWorkspaceOutputs','on');

% Outports are returned in yout for standard Simulink output settings.
if isprop(simOut,'yout') || any(strcmp(simOut.who,'yout'))
    yout = simOut.yout;
else
    error(['Simulation completed, but yout was not returned. In Model Settings > ' ...
           'Data Import/Export, enable Output and use Dataset format.'])
end

names = {'tireDeflection','suspensionTravel','bodyAcceleration'};
units = {'mm','mm','m/s^2'};
scales = [1000 1000 1];

figure('Name','Quarter-Car Task 1 Results')
tiledlayout(3,1)
for k = 1:3
    sig = yout.getElement(names{k});
    nexttile
    plot(sig.Values.Time,scales(k)*sig.Values.Data,'LineWidth',1.2)
    ylabel(sprintf('%s [%s]',names{k},units{k}))
    grid on
end
xlabel('Time [s]')
sgtitle('Task 1 Baseline Quarter-Car Response')

exportgraphics(gcf,'task1_results.png')
fprintf('Task 1 simulation completed. Figure saved as task1_results.png\n')
