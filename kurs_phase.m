clear; clc;
close all;

t = 100;

h = 0.01;

N = t/h;

X_0 = [0.98, 1.9, 0.98, -0.98]'; % Начальные значения ПС для Master системы

a = [5.8, 3.7, 2, 0.9, 1, 1.5]'; % Параметры системы

% X_0 = [3 -3 0];
% a = [0.2 0.2 5.7];

PS_X = zeros(1, N);
PS_Y = zeros(1, N);
PS_Z = zeros(1, N);
PS_W = zeros(1, N);

X = X_0;

hw1 = waitbar(0,'Please wait...');

col = 5/h;

for i = 1:5/h
    waitbar(i/col, hw1, 'Transient');
    X = MyIMP(X, a, h);
end

close(hw1);

PS_X(1) = X(1);
PS_Y(1) = X(2);
PS_Z(1) = X(3);
PS_W(1) = X(4);

hw = waitbar(0,'Please wait...');

for i = 2:N
    % X = MyIMP(X, a, h);
    X = MyIMP(X, a, h);

    PS_X(i) = X(1);
    PS_Y(i) = X(2);
    PS_Z(i) = X(3);
    PS_W(i) = X(4);

    waitbar(i/N, hw, 'Proccessing...')
end

close(hw);

figure
plot(PS_Z, PS_W, 'b-', 'LineWidth', 1);
xlabel('$z$','interpreter','latex','FontSize',12);
ylabel('$w$','interpreter','latex','FontSize',12);
% zlabel('z');
% zlabel('z');
title ('Phase portret ZW IMP');

% view(-60, 30);


hold on

