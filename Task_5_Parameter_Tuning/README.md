# Task 5 – Suspension Parameter Tuning

## Objective

The objective of Task 5 was to tune the suspension spring stiffness, `Ks`, and suspension damping coefficient, `Cs`, to improve quarter-car performance across multiple road conditions.

The tuning process prioritized ride comfort while also considering suspension travel and tire deflection.

## Baseline Parameters

The baseline quarter-car parameters were:

- `Ms = 300 kg`
- `Mu = 40 kg`
- `Ks = 18000 N/m`
- `Cs = 1500 N*s/m`
- `Kt = 180000 N/m`
- `Ct = 100 N*s/m`

Only `Ks` and `Cs` were changed during the parameter sweep. The remaining parameters were kept constant.

## Parameter Sweep

The following suspension values were tested:

```matlab
Ks_values = [15000 18000 21000];
Cs_values = [1200 1500 1800];
```

This created nine total suspension designs.

Each design was tested using three road cases:

- Speed bump
- Pothole
- Rough road

The road input was selected manually in the integrated Simulink model, so the parameter sweep was run separately for each road case.

## Performance Metrics

The following signals were logged from the Simulink model:

- `sprungAccel`
- `suspTravel`
- `tireDeflection`

The following metrics were calculated for every simulation:

- RMS sprung-mass acceleration
- Peak sprung-mass acceleration
- Maximum suspension travel
- Maximum tire deflection

RMS sprung-mass acceleration was used as the main ride-comfort metric because it represents the overall vertical vibration experienced by the vehicle body.

## Task 3 Integration

The logged signals were stored inside `simout.logsout`.

The Task 3 signal extraction function was updated to read each signal using:

```matlab
sig = simout.logsout.get(signalName);
```

The numeric data was then extracted using:

```matlab
data = sig.Values.Data(:);
```

The signal names were also updated to match the integrated model:

- `bodyAcceleration` was changed to `sprungAccel`
- `suspensionTravel` was changed to `suspTravel`
- `tireDeflection` stayed the same

The original RMS, peak, travel, tire-deflection, and scoring calculations were not changed.

## Metric Normalization

The measured metrics had different units and numerical scales. To compare them fairly, each metric was normalized relative to the baseline design.

```matlab
normalizedMetric = designMetric / baselineMetric;
```

The normalized values were interpreted as follows:

- A value below `1` means improvement compared with the baseline.
- A value equal to `1` means the same performance as the baseline.
- A value above `1` means worse performance than the baseline.

For the baseline design, every normalized metric is equal to `1`.

## Weighted Score

The normalized score was calculated using:

```matlab
normalizedScore = ...
    1.0 * normalizedAcceleration + ...
    0.5 * normalizedTravel + ...
    0.5 * normalizedTireDeflection;
```

Body acceleration received twice the weight of suspension travel and tire deflection because ride comfort was the main tuning objective.

The baseline normalized score was:

```text
2.0000
```

A score below `2.0000` represents an overall improvement compared with the baseline.

## Individual Road-Case Results

### Speed Bump

The best design for the speed-bump case was:

- `Ks = 21000 N/m`
- `Cs = 1200 N*s/m`
- Normalized score: `1.9935`

### Pothole

The best design for the pothole case was:

- `Ks = 21000 N/m`
- `Cs = 1200 N*s/m`
- Normalized score: `1.9499`

### Rough Road

The best design for the rough-road case was:

- `Ks = 15000 N/m`
- `Cs = 1200 N*s/m`
- Normalized score: `1.8083`

## Overall Score

The normalized scores from the speed-bump, pothole, and rough-road tests were averaged for each suspension design.

```matlab
overallScore = mean( ...
    [speedBumpScore, potholeScore, roughRoadScore], ...
    2);
```

The design with the lowest average normalized score was selected as the final design.

## Final Selected Design

The selected suspension parameters were:

- `Ks = 21000 N/m`
- `Cs = 1200 N*s/m`

The selected design produced the following scores:

| Road Case | Normalized Score |
|---|---:|
| Speed bump | 1.9935 |
| Pothole | 1.9499 |
| Rough road | 1.8174 |
| **Overall average** | **1.9203** |

The baseline overall score was `2.0000`.

The selected design therefore produced an overall weighted improvement of approximately `4%`.

## Design Tradeoffs

The selected design did not minimize every individual metric.

Some parameter combinations reduced suspension travel but increased body acceleration. Other combinations improved ride comfort while allowing slightly more suspension movement.

The final design was selected because it produced the lowest average normalized score across all three road conditions.

## How to Run

1. Open the integrated quarter-car Simulink model.
2. Run `quarterCarParameters.m`.
3. Manually select the desired road input in the Simulink model.
4. Update the road-case settings near the top of `task5_setup.m`.
5. Run `task5_setup.m`.
6. Repeat the process for the speed bump, pothole, and rough road.
7. Confirm that the three road-case CSV files were created.
8. Run `task5_overall_results.m`.
9. Review the final overall table and parameter-sweep plot.

Example rough-road settings:

```matlab
roadName = "Rough_Road";
resultsFile = "task5_rough_road_normalized_results.csv";
sortedFile = "task5_rough_road_normalized_results_sorted.csv";
```

Example pothole settings:

```matlab
roadName = "Pothole";
resultsFile = "task5_pothole_normalized_results.csv";
sortedFile = "task5_pothole_normalized_results_sorted.csv";
```

Example speed-bump settings:

```matlab
roadName = "Speed_Bump";
resultsFile = "task5_speed_bump_normalized_results.csv";
sortedFile = "task5_speed_bump_normalized_results_sorted.csv";
```

## Required Files

- Integrated quarter-car Simulink model
- `quarterCarParameters.m`
- `scoreSuspension.m`
- `task5_setup.m`
- `task5_overall_results.m`

## Output Files

- `task5_speed_bump_normalized_results.csv`
- `task5_pothole_normalized_results.csv`
- `task5_rough_road_normalized_results.csv`
- `task5_overall_normalized_results.csv`
- `task5_overall_score_plot.png`

## Final Recommendation

The recommended suspension design is:

```text
Ks = 21000 N/m
Cs = 1200 N*s/m
```

This design produced the lowest average normalized score across all three road cases and provided the best overall balance between ride comfort, suspension travel, and tire deflection.
