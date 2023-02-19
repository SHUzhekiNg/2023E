%% Initialize
clc, clear;

%% Choose state and factor to analysis
% 3 for Population Density             253.7 to 252
% 4 for Limit magnitude                6 to 7
% 8 for Work hours per Week            38.3 to 37.7

state = 4; % California
factor = [3 4 8];
changed = [253.7 252; 6 7; 38.3 37.7];

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

states = table2array(combined(:, 1));

%% Get data
result = [];
for data = 1:2
    %% Reread data
    a = table2array(combined(:, 2:10));

    %% Replace data
    for f=1:length(factor)
        a(state, factor(f)) = changed(f, data);
    end

    %% calculate weight
    % m for the number of samples, n for the number of factors
    [m, n] = size(a);

    % rescale
    for i = 1:n
        if n == 5 || n == 8
            a(:, i) = 1 - (a(:, i) - min(a(:, i))) / (max(a(:, i)) - min(a(:, i)));
        else
            a(:, i) = (a(:, i) - min(a(:, i))) / (max(a(:, i)) - min(a(:, i)));
        end
    end

    % calculate weight
    p = a ./ sum(a);
    h = zeros(1, n);
    for i = 1:n
        for j = 1:m
            if p(j, i) ~= 0
                h(i) = h(i) - p(j, i) * log(p(j, i)) / log(n);
            end
        end
    end

    w = zeros(1, n);

    for i = 1:n
        w(i) = (sum(h) + 1 - h(i)) / sum(sum(h) + 1 - 2 .* h);
    end
    
    % Fix weight
    % w = [0.127087741240120	0.123761157821582	0.127423839685724	0.123903097673091	0.124360802763785	0.123780549158867	0.124106686595032	0.125811891189744	0.124024924276506];

    %% TOPSIS

    b = a ./ vecnorm(a);
    c = b .* w;
    Cstar = max(c);
    C0 = min(c);

    % the lower the worser
    Cstar(4) = min(c(:, 4));
    Cstar(8) = min(c(:, 8));
    C0(4) = max(c(:, 4));
    C0(8) = max(c(:, 8));

    Sstar = vecnorm(c - Cstar, 2, 2);
    S0 = vecnorm(c - C0, 2, 2);
    f = S0 ./ (Sstar + S0); % higher means worse light pollution
    result = [result f(state)];

end

result
