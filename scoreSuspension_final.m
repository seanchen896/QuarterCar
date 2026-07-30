function results = scoreSuspension(simout, roadName)
% Computes comfort/packaging/road-holding metrics for one road case

    accelData  = extractSignalData(simout, 'bodyAcceleration');
    travelData = extractSignalData(simout, 'suspensionTravel');
    tireData   = extractSignalData(simout, 'tireDeflection');

    rmsAccel    = rms(accelData);
    peakAccel   = max(abs(accelData));
    maxTravel   = max(abs(travelData));
    maxTireDefl = max(abs(tireData));

    % weights are a starting point, tune once we have real numbers
    wAccel  = 1.0;
    wTravel = 0.5;
    wTire   = 0.5;

    score = wAccel * rmsAccel + wTravel * maxTravel + wTire * maxTireDefl;

    results.road        = roadName;
    results.rmsAccel     = rmsAccel;
    results.peakAccel    = peakAccel;
    results.maxTravel    = maxTravel;
    results.maxTireDefl  = maxTireDefl;
    results.score        = score;

end

function data = extractSignalData(simout, signalName)
% handles whatever format simout gives us back for a signal

    sig = simout.(signalName);

    if isa(sig, 'timeseries')
        data = sig.Data(:);
    elseif isa(sig, 'Simulink.SimulationData.Dataset')
        data = sig.get(1).Values.Data(:);
    elseif isstruct(sig) && isfield(sig, 'signals')
        data = sig.signals.values(:);
    else
        data = sig(:);
    end
end
