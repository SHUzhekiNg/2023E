%% Initialize
clc, clear;

%% Choose state and factor to analysis
state = 4; % California
factor = 4; % 2 for Regional industrial structure, 4 for Limit magnitude
range = 5:0.02:7; % 0.20:0.0005:0.25  5:0.02:7

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
a = table2array(combined(:, 2:10));

%% Get data
result = [];
for data = range
    %% Replace data
    a(state, factor) = data;

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

out = cat(2, range', result');

%f = fittype()
%line = polyfit(range, result, 2);
%linefit = polyval(line, range);
%plot(range,result','bo',range,linefit,'k-','Markersize',3.5)
