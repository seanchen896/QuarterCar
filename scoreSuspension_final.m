function results = scoreSuspension(simout, roadName)
%SCORESUSPENSION Compute comfort/packaging/road-holding metrics from a
%quarter-car suspension simulation run (quarterCarModel_fixed.slx).
%
%   results = scoreSuspension(simout, roadName)
%
%   INPUTS
%     simout   - Simulink.SimulationOutput returned by:
%                  sim('quarterCarModel_fixed', 'ReturnWorkspaceOutputs', 'on')
%     roadName - label for which road case this run used, e.g.
%                'speedBump', 'pothole', or 'roughRoad'
%
%   OUTPUT
%     results - struct with fields: road, rmsAccel, peakAccel, maxTravel,
%               maxTireDefl, score
%
%   Reads the model's three named root-level output ports directly:
%     tireDeflection, suspensionTravel, bodyAcceleration

    %% ---- Pull signals out of simout ----
    accelData  = extractSignalData(simout, 'bodyAcceleration');
    travelData = extractSignalData(simout, 'suspensionTravel');
    tireData   = extractSignalData(simout, 'tireDeflection');

    %% ---- Metrics ----
    rmsAccel    = rms(accelData);        % comfort metric
    peakAccel   = max(abs(accelData));   % comfort (secondary)
    maxTravel   = max(abs(travelData));  % packaging metric
    maxTireDefl = max(abs(tireData));    % road-holding metric

    %% ---- Combine into a single score (lower = better) ----
    % Starting weights - comfort weighted highest, travel/tire deflection
    % treated more like soft constraints. Tune these once you have real
    % numbers across all three road cases.
    wAccel  = 1.0;
    wTravel = 0.5;
    wTire   = 0.5;

    score = wAccel * rmsAccel + wTravel * maxTravel + wTire * maxTireDefl;

    %% ---- Package results ----
    results.road        = roadName;
    results.rmsAccel     = rmsAccel;
    results.peakAccel    = peakAccel;
    results.maxTravel    = maxTravel;
    results.maxTireDefl  = maxTireDefl;
    results.score        = score;

end

function data = extractSignalData(simout, signalName)
%EXTRACTSIGNALDATA Pull the numeric data out of a named signal from
%simout, whether it comes back as a timeseries, a Dataset element, or a
%plain structure-with-time - handles the common formats so this doesn't
%break based on the model's "Save format" setting.

    sig = simout.(signalName);

    if isa(sig, 'timeseries')
        data = sig.Data(:);
    elseif isa(sig, 'Simulink.SimulationData.Dataset')
        data = sig.get(1).Values.Data(:);
    elseif isstruct(sig) && isfield(sig, 'signals')
        data = sig.signals.values(:);
    else
        % Last resort: assume it's already numeric-like
        data = sig(:);
    end
end
