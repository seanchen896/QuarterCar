function summaryTable = runAllTests(modelName, requirements)
% RUNALLTESTS Automates running the Task 2 road suite and scores results
% using the unaltered scoreSuspension function from Task 3.

arguments
    modelName (1,1) string = "quarterCarModel_fixed"
    requirements struct = defaultRequirements()
end

validateRequirements(requirements);

modelFile = modelName + ".slx";
if ~isfile(modelFile)
    error('Model file "%s" was not found in the current folder.', modelFile);
end

% Baseline vehicle parameters
ms = 300;     % Sprung mass (kg)
mu = 40;      % Unsprung mass (kg)
Ks = 18000;   % Suspension stiffness (N/m)
Cs = 1500;    % Damping coefficient (N*s/m)
Kt = 180000;  % Tire stiffness (N/m)
Ct = 100;     % Tire damping (N*s/m)

% Load Task 2 road profiles
roads = roadSuite_task2();

resultsFolder = fullfile(pwd, "results");
if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end

load_system(modelName);

summaryTable = table();

for k = 1:numel(roads)
    roadName = roads(k).Name;
    fprintf('Running simulation %d/%d: %s\n', k, numel(roads), roadName);

    in = Simulink.SimulationInput(modelName);

    % Pass vehicle parameters
    in = in.setVariable("ms", ms);
    in = in.setVariable("mu", mu);
    in = in.setVariable("Ks", Ks);
    in = in.setVariable("Cs", Cs);
    in = in.setVariable("Kt", Kt);
    in = in.setVariable("Ct", Ct);

    % Pass road inputs
    in = in.setVariable("road_height", roads(k).road_height);
    in = in.setVariable("roadInput", roads(k).road_height);
    in = in.setVariable("Tstop", roads(k).StopTime);

    % Configure model parameters & enable logsout for scoreSuspension
    in = in.setModelParameter( ...
        "StopTime", num2str(roads(k).StopTime), ...
        "ReturnWorkspaceOutputs", "on", ...
        "SignalLogging", "on", ...
        "SignalLoggingName", "logsout", ...
        "SaveOutput", "on", ...
        "OutputSaveName", "yout", ...
        "SaveFormat", "Dataset");

    try
        simOut = sim(in);

        % Evaluates raw simOut with Task 3 scoreSuspension function
        metrics = scoreSuspension(simOut, roadName);

        % Evaluate pass/fail limits
        comfortPass = metrics.rmsAccel <= requirements.RMSAcceleration && ...
                      metrics.peakAccel <= requirements.PeakAcceleration;
        travelPass  = metrics.maxTravel <= requirements.SuspensionTravel;
        tirePass    = metrics.maxTireDefl <= requirements.TireDeflection;
        overallPass = comfortPass && travelPass && tirePass;

        row = table( ...
            string(metrics.road), ...
            metrics.rmsAccel, ...
            metrics.peakAccel, ...
            metrics.maxTravel, ...
            metrics.maxTireDefl, ...
            metrics.score, ...
            comfortPass, ...
            travelPass, ...
            tirePass, ...
            overallPass, ...
            "Completed", ...
            'VariableNames', { ...
            'Road', 'RMSAcceleration_mps2', 'PeakAcceleration_mps2', ...
            'MaxSuspensionTravel_m', 'MaxTireDeflection_m', 'Task3Score', ...
            'ComfortPass', 'TravelPass', 'TirePass', 'OverallPass', ...
            'SimulationStatus'});

    catch ME
        warning('Simulation failed for %s: %s', roadName, ME.message);

        row = table( ...
            roadName, NaN, NaN, NaN, NaN, Inf, ...
            false, false, false, false, ...
            "FAILED: " + string(ME.message), ...
            'VariableNames', { ...
            'Road', 'RMSAcceleration_mps2', 'PeakAcceleration_mps2', ...
            'MaxSuspensionTravel_m', 'MaxTireDeflection_m', 'Task3Score', ...
            'ComfortPass', 'TravelPass', 'TirePass', 'OverallPass', ...
            'SimulationStatus'});
    end

    summaryTable = [summaryTable; row]; %#ok<AGROW>
end

% Save outputs to /results
csvFile = fullfile(resultsFolder, "task4_summary_table.csv");
matFile = fullfile(resultsFolder, "task4_results.mat");

writetable(summaryTable, csvFile);
save(matFile, "summaryTable", "requirements", "ms", "mu", "Ks", "Cs", "Kt", "Ct", "roads");

% Create and save summary figure
createSummaryFigure(summaryTable, requirements, resultsFolder);

fprintf('\nAutomated Test Results:\n');
disp(summaryTable);
fprintf('Road cases passed: %d of %d\n', nnz(summaryTable.OverallPass), height(summaryTable));
end


function createSummaryFigure(T, requirements, resultsFolder)
labels = categorical(T.Road, T.Road);
fig = figure("Name", "Task 4 Summary Results", "Position", [100 80 1100 780]);

tl = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");

% Comfort (RMS)
nexttile
bar(labels, T.RMSAcceleration_mps2)
hold on
yline(requirements.RMSAcceleration, "r--", "Limit")
ylabel("RMS Accel (m/s^2)")
title("Ride Comfort")
grid on

% Peak Acceleration
nexttile
bar(labels, T.PeakAcceleration_mps2)
hold on
yline(requirements.PeakAcceleration, "r--", "Limit")
ylabel("Peak Accel (m/s^2)")
title("Transient Acceleration")
grid on

% Suspension Travel
nexttile
bar(labels, 1000 * T.MaxSuspensionTravel_m)
hold on
yline(1000 * requirements.SuspensionTravel, "r--", "Limit")
ylabel("Max Travel (mm)")
title("Suspension Packaging")
grid on

% Tire Deflection
nexttile
bar(labels, 1000 * T.MaxTireDeflection_m)
hold on
yline(1000 * requirements.TireDeflection, "r--", "Limit")
ylabel("Max Deflection (mm)")
title("Road Holding")
grid on

title(tl, sprintf("Automated Test Suite — %d of %d Cases Passed", ...
    nnz(T.OverallPass), height(T)));

exportgraphics(fig, fullfile(resultsFolder, "task4_summary_figure.png"), "Resolution", 200);
savefig(fig, fullfile(resultsFolder, "task4_summary_figure.fig"));
end


function requirements = defaultRequirements()
requirements = struct( ...
    "RMSAcceleration", 3.0, ...     % m/s^2
    "PeakAcceleration", 8.0, ...    % m/s^2
    "SuspensionTravel", 0.080, ...  % m
    "TireDeflection", 0.050);       % m
end


function validateRequirements(r)
fields = ["RMSAcceleration", "PeakAcceleration", "SuspensionTravel", "TireDeflection"];
for f = fields
    if ~isfield(r, f) || ~isscalar(r.(f)) || ~isfinite(r.(f)) || r.(f) <= 0
        error('Invalid requirement limit for "%s".', f);
    end
end
end