% Task 4 Entry Point
% Executes the test runner across all road profiles and outputs summary figures.

clear; clc; close all;

modelName = "quarterCarModel_fixed";

% Pass/fail performance criteria
requirements = struct( ...
    "RMSAcceleration", 3.0, ...       % m/s^2
    "PeakAcceleration", 8.0, ...      % m/s^2
    "SuspensionTravel", 0.080, ...    % m
    "TireDeflection", 0.050);         % m

% Run automated test runner
summaryTable = runAllTests(modelName, requirements);