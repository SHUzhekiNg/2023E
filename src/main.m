%% Initialize
clc, clear;

%% Import data from csv
% Set option
opts = delimitedTextImportOptions("NumVariables", 9);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Area", "AllIndustryTotal", "AllTertiaryIndustryPercentage", "PopulationDensity", "LimitingMagnitude", "LastBus", "PowerConsumptionPerCapitaPerMonth", "AnnualPrecipitationinMillimetre", "WorkHoursPerWeek", "NightlifeIndex"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, "Area", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Area", "EmptyFieldRule", "auto");
combined = readtable("../data/combined.csv", opts);

cities = table2array(combined(:, 1));
a = table2array(combined(:, 2:10));

%% calculate weight
[n, m] = size(a);

% calculate weight
p = a ./ sum(a);
e = -sum(p .* log(p)) / log(n);
g = 1 - e;
w = g / sum(g); % this is weight

%% TOPSIS
% rescale
for i = 1:m
    a(:,i) = rescale(a(:,i));
end

b = a ./ vecnorm(a);
c = b .* w;
Cstar = max(c);
C0 = min(c);

% the lower the worser
Cstar(5) = min(c(:, 5)); 
Cstar(8) = min(c(:, 8));
C0(5) = max(c(:, 5));
C0(8) = max(c(:, 8));

Sstar = vecnorm(c - Cstar, 2, 2);
S0 = vecnorm(c - C0, 2, 2);
f = S0 ./ (Sstar + S0); % higher means worse light pollution
result = cat(2, cities, f)
