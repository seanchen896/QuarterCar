function results = scoreSuspension(simout, roadName)
% Computes comfort/packaging/road-holding metrics for one road case

accelData  = extractSignalData(simout, 'sprungAccel');
travelData = extractSignalData(simout, 'suspTravel');
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
% Extracts numeric signal data from logsout

sig = simout.logsout.get(signalName);

if isempty(sig)
    error('Signal "%s" was not found in logsout.', signalName);
end

% A logged Simulink signal usually stores its values here
if isa(sig, 'Simulink.SimulationData.Signal')
    values = sig.Values;
else
    values = sig;
end

% Convert the stored values into numeric data
if isa(values, 'timeseries')
    data = values.Data;

elseif isnumeric(values) || islogical(values)
    data = values;

elseif isstruct(values) && isfield(values, 'Data')
    data = values.Data;

elseif isobject(values) && isprop(values, 'Data')
    data = values.Data;

else
    error('Unsupported data type for signal "%s": %s', ...
        signalName, class(values));
end

data = squeeze(double(data));
data = data(:);

end
