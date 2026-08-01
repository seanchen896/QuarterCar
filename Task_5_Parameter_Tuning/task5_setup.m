% Proposed Task 5 parameter sweep

Ks_values = [15000 18000 21000];  % N/m
Cs_values = [1200 1500 1800];     % N*s/m
[Ks_grid, Cs_grid] = ndgrid(Ks_values, Cs_values);

parameterGrid = table( ...
    Ks_grid(:), ...
    Cs_grid(:), ...
    'VariableNames', {'Ks', 'Cs'} ...
    );

disp(parameterGrid)


modelName = "quarter_car_model_and_road_test";


run("quarterCarParameters.m");


numberOfRuns = height(parameterGrid);


simInputs(1:numberOfRuns) = Simulink.SimulationInput(modelName);

for runNumber = 1:numberOfRuns

    Ks_test = parameterGrid.Ks(runNumber);
    Cs_test = parameterGrid.Cs(runNumber);

    simInputs(runNumber) = Simulink.SimulationInput(modelName);

    simInputs(runNumber) = simInputs(runNumber).setVariable( ...
        "Ks", Ks_test);

    simInputs(runNumber) = simInputs(runNumber).setVariable( ...
        "Cs", Cs_test);

    fprintf("Prepared run %d: Ks = %.0f, Cs = %.0f\n", ...
        runNumber, Ks_test, Cs_test);
end

% Create results table
resultsTable = table( ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    zeros(numberOfRuns,1), ...
    'VariableNames', { ...
        'Ks', ...
        'Cs', ...
        'RMS_Accel', ...
        'Peak_Accel', ...
        'Max_Travel', ...
        'Max_Tire_Deflection', ...
        'Score'});

% Run all 9 combinations
for runNumber = 1:numberOfRuns

    fprintf("Running simulation %d of %d...\n", ...
        runNumber, numberOfRuns);

    simOutput = sim(simInputs(runNumber));
  
  % Change these values to match the manually selected road case
  roadName = "Rough_Road";

    metrics = scoreSuspension(simOutput, "roadName");

    resultsTable.Ks(runNumber) = parameterGrid.Ks(runNumber);
    resultsTable.Cs(runNumber) = parameterGrid.Cs(runNumber);
    resultsTable.RMS_Accel(runNumber) = metrics.rmsAccel;
    resultsTable.Peak_Accel(runNumber) = metrics.peakAccel;
    resultsTable.Max_Travel(runNumber) = metrics.maxTravel;
    resultsTable.Max_Tire_Deflection(runNumber) = metrics.maxTireDefl;
    resultsTable.Score(runNumber) = metrics.score;
end

% Find official baseline row
baselineIndex = resultsTable.Ks == 18000 & ...
    resultsTable.Cs == 1500;

baselineRmsAccel = resultsTable.RMS_Accel(baselineIndex);
baselineMaxTravel = resultsTable.Max_Travel(baselineIndex);
baselineMaxTireDefl = ...
    resultsTable.Max_Tire_Deflection(baselineIndex);

% Normalize metrics relative to baseline
resultsTable.Norm_Accel = ...
    resultsTable.RMS_Accel ./ baselineRmsAccel;

resultsTable.Norm_Travel = ...
    resultsTable.Max_Travel ./ baselineMaxTravel;

resultsTable.Norm_Tire = ...
    resultsTable.Max_Tire_Deflection ./ baselineMaxTireDefl;

% Weighted normalized score
% Ride comfort is prioritized, so body acceleration receives twice
% the weight of suspension travel and tire deflection.
wAccel = 1.0;
wTravel = 0.5;
wTire = 0.5;

resultsTable.Normalized_Score = ...
    wAccel .* resultsTable.Norm_Accel + ...
    wTravel .* resultsTable.Norm_Travel + ...
    wTire .* resultsTable.Norm_Tire;

disp("All 9 simulations completed.");
disp(resultsTable);

% Sort results from lowest score to highest
sortedResults = sortrows(resultsTable, "Normalized_Score");

disp("Results sorted by score:");
disp(sortedResults);

% Lowest-score design
bestDesign = sortedResults(1,:);

disp("Current best design:");
disp(bestDesign);

% Change these values to match the manually selected road case
resultsFile = "task5_rough_road_normalized_results.csv";
sortedFile = "task5_rough_road_normalized_results_sorted.csv";


% Save results to CSV files
writetable(resultsTable, "resultsFile");
writetable(sortedResults, "sortedFile");

