% Initialize
clc, clear;

% Read data
a = [1 2 3; 4 5 6; 7 8 9];

% calculate weight
[n, m] = size(a);
p = a ./ sum(a);
e = -sum(p .* log(p)) / log(n);
g = 1 - e;
w = g / sum(g);

% TOPSIS
b = rescale([1 2 3]);
C = w * b;
