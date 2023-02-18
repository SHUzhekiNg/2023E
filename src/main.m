% Initialize
clc, clear;



% Read data
a = [1:4; 5:8; 9:12];

% calculate weight
[n, m] = size(a);
p = a ./ sum(a);
e = -sum(p .* log(p)) / log(n);
g = 1 - e;
w = g / sum(g);

% TOPSIS
x2 = @(range, lb, ub, x)(1-(range(1)-x)./(range(1)-lb)).*...
(x>=lb&x<range(1))+(x>=range(1)&x<=range(2))+...
(1-(x-range(2))./(ub-range(2))).*(x>range(2)&x<=ub);
range = [5, 6]; lb = 2; ub = 12;
a(:, 2) = x2(range, lb, ub, a(:, 2));
b = a ./ vecnorm(a);
c = b .* w;
Cstar = max(c);
Cstar(4) = min(c(:, 4));
C0 = min(c);
C0(4) = max(c(:, 4));
Sstar = vecnorm(c - Cstar, 2, 2);
S0 = vecnorm(c - C0, 2, 2);
f = S0 ./ (Sstar + S0);
[sf, ind] = sort(f, 'descend');
