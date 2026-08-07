# Quarter-Car Suspension Project

This repository contains the MATLAB and Simulink files for the quarter-car suspension modeling and optimization project.

Project Tasks

- Task 1: Baseline quarter-car model
- Task 2: Road test suite
- Task 3: Signal logging and performance metrics
- Task 4: Automated test runner
- Task 5: Suspension parameter tuning
- Task 6: Robustness validation

## Overview 
This project uses MATLAB, Simulink, and Simscape Multibody to model and test a quarter-car suspension system.

We tested the suspension using three road inputs:
- Speed bump
- Pothole
- Rough road

The model was evaluated using sprung-mass acceleration, suspension travel, and tire deflection. We also tested different suspension stiffness and damping values to find the best overall setup.

## Final Results

Final tuned suspension values:

- Ks = 21000 N/m
- Cs = 1200 N*s/m
- Overall normalized score = 1.9414

The final design passed 2 out of 3 road cases. The speed bump was the limiting case because the tire-deflection requirement was not met.

For the robustness test, the sprung mass was increased by 25% from 300 kg to 375 kg. The tuned suspension again passed 2 out of 3 road cases.

## How to Run

1. Download or clone the repository.
2. Open the project folder in MATLAB.
3. Open `QuarterCar_Final_Report.mlx` for the full project report.
4. Run `runAllTests.m` for the automated road tests.
5. Run the Task 5 scripts for the parameter sweep and tuning results.
6. Run `task6.m` for the robustness test.

## Required MATLAB Products

- MATLAB
- Simulink
- Simscape
- Simscape Multibody

## Main Files

- `QuarterCar_Final_Report.mlx` - final Live Script report
- `QuarterCar_Final_Report.pdf` - PDF version of the report
- `quarter_car_model_and_road_test.slx` - integrated quarter-car model
- `runAllTests.m` - automated road-test runner
- `scoreSuspension.m` - calculates suspension performance metrics
- `task6.m` - robustness test
- `Task_2_Road_Test_Suite/` - road input model and files
- `Task_5_Parameter_Tuning/` - parameter sweep files and results

## Notes

The speed bump, pothole, and rough-road cases were used throughout the project. The speed bump was the most difficult case and exceeded the selected tire-deflection limit.

