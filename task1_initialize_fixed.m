%% task1_initialize_fixed.m
% Baseline parameters and smooth road input for quarterCarModel_fixed.slx.

clearvars
clc

%% Quarter-car parameters
ms = 300;       % Sprung mass [kg]
mu = 40;        % Unsprung mass [kg]
Ks = 18000;     % Suspension stiffness [N/m]
Cs = 1500;      % Suspension damping [N*s/m]
Kt = 180000;    % Tire stiffness [N/m]
Ct = 100;       % Small tire damping [N*s/m]

%% Simulation and road input
Tstop = 5;      % Simulation stop time [s]
dt = 0.001;     % Road sample time [s]
t = (0:dt:Tstop)';

bumpHeight = 0.05;      % 50 mm bump [m]
bumpStart = 1.0;        % [s]
bumpDuration = 0.50;    % [s]

zRoad = zeros(size(t));
idx = t >= bumpStart & t <= bumpStart + bumpDuration;
tau = t(idx) - bumpStart;
zRoad(idx) = bumpHeight*sin(pi*tau/bumpDuration);

% The model's From Workspace block reads this exact variable name.
roadInput = timeseries(zRoad,t);

fprintf('Task 1 initialized for quarterCarModel_fixed.slx\n');
fprintf('ms=%.1f kg, mu=%.1f kg, Ks=%.0f N/m, Cs=%.0f N*s/m\n', ...
    ms,mu,Ks,Cs);
