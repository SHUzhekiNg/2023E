%% Initialize
clc, clear;

%% Set import option and import data
opts = spreadsheetImportOptions("NumVariables", 9);

% Delimit
opts.Sheet = "combined";
opts.DataRange = "B2:J10";

% Set column name and type
opts.VariableNames = ["AllIndustryTotal", "AllTertiaryIndustryPercentage", "PopulationDensity", "LimitingMagnitude", "LastBus", "PowerConsumptionPerCapitaPerMonth", "AnnualPrecipitationinMillimetre", "WorkHoursPerWeek", "NightlifeIndex"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Set variable property
% opts = setvaropts(opts, "Area", "WhitespaceRule", "preserve");
% opts = setvaropts(opts, "Area", "EmptyFieldRule", "auto");

% Import data
a = readtable("../data/合并数据.xlsx", opts, "UseExcel", false);

% Clear temporary data
clear opts

%% convert to matrix
a = table2array(a);

%% calculate weight
[n, m] = size(a);
p = a ./ sum(a);
e = -sum(p .* log(p)) / log(n);
g = 1 - e;
w = g / sum(g);

%% rescale
for i = 1:m
    a(:,i) = rescale(a(:,i));
end

%% TOPSIS
%x2 = @(range, lb, ub, x)(1-(range(1)-x)./(range(1)-lb)).*...
%(x>=lb&x<range(1))+(x>=range(1)&x<=range(2))+...
%(1-(x-range(2))./(ub-range(2))).*(x>range(2)&x<=ub);
%range = [0, 1]; lb = 2; ub = 12;
%a(:, 2) = x2(range, lb, ub, a(:, 2));
b = a ./ vecnorm(a);
c = b .* w;
Cstar = max(c);
Cstar(5) = min(c(:, 5));
Cstar(8) = min(c(:, 8));
C0 = min(c);
C0(5) = max(c(:, 5));
C0(8) = max(c(:, 8));
Sstar = vecnorm(c - Cstar, 2, 2);
S0 = vecnorm(c - C0, 2, 2);
f = S0 ./ (Sstar + S0); % higher means worse light pollution
[sf, ind] = sort(f, 'descend');
