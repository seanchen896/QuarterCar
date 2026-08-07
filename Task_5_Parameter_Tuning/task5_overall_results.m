clear;
clc;

% Load the three road-case result tables
speedBump = readtable("task5_speed_bump_normalized_results.csv");
pothole   = readtable("task5_pothole_normalized_results.csv");
roughRoad = readtable("task5_rough_road_normalized_results.csv");

% Start with the common Ks and Cs values
overallResults = table( ...
    speedBump.Ks, ...
    speedBump.Cs, ...
    speedBump.Normalized_Score, ...
    pothole.Normalized_Score, ...
    roughRoad.Normalized_Score, ...
    'VariableNames', { ...
    'Ks', ...
    'Cs', ...
    'SpeedBumpScore', ...
    'PotholeScore', ...
    'RoughRoadScore'});

% Average score across all three road cases
overallResults.OverallScore = mean( ...
    [overallResults.SpeedBumpScore, ...
    overallResults.PotholeScore, ...
    overallResults.RoughRoadScore], ...
    2);

% Sort lowest overall score to highest
overallResults = sortrows(overallResults, "OverallScore");

disp("Overall results:");
disp(overallResults);

disp("Final overall best design:");
disp(overallResults(1,:));

% Save final comparison
writetable(overallResults, ...
    "task5_overall_normalized_results.csv");


% Final selected design
Ks_opt = 21000;
Cs_opt = 1200;

% Create labels for each parameter combination
designLabels = string(overallResults.Ks) + ", " + ...
    string(overallResults.Cs);

% Plot overall normalized score
figure;

bar(overallResults.OverallScore);

xticks(1:height(overallResults));
xticklabels(designLabels);
xtickangle(45);

xlabel("Suspension Design (Ks, Cs)");
ylabel("Overall Normalized Score");
title("Overall Quarter-Car Suspension Parameter Sweep");


yline(2.0, "--", "Baseline Score");

grid on;

exportgraphics(gcf, "task5_overall_score_plot.png");
