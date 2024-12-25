clear; clc;
close all;


% Лучший вариант

t = 100;

h = 0.01;

XM_0 = [0.98, 1.9, 0.98, -0.98]'; % Начальные значения ПС для Master системы

a = [5.8, 3.7, 2, 0.9, 1, 1.5]'; % Параметры системы

XS_0 = [10, 1.9 0.98 -0.98]'; % Начальные значения ПС Slave системы

% XM_0 = [3, -3, 0]; % Начальные значения ПС для Master системы
% 
% a = [10, 28, 8/3]; % Параметры системы
% 
% XS_0 = [10, -3, 0]; % Начальные значения ПС Slave системы
% 

XM = XM_0;
XS = XS_0;

N = zeros(1, 4);
K = [0, 5, 5, 0];

str = join(num2str(K), ',');

Col = t/h;

t_pred = 0;
E_pred = 0;

q = 1;

hw = waitbar(0,'Please wait...');


for i = 1:Col
    N(1) = K(1) * (XM(1) - XS(1));
    N(2) = K(2) * (XM(2) - XS(2));
    N(3) = K(3) * (XM(3) - XS(3));
    N(4) = K(4) * (XM(4) - XS(4));

    XM = MyIMP(XM, a, h);
    XS = MyIMP(XS, a, h);

    for j = 1:4
        XS(j) = XS(j) + h * N(j);
    end

    E(q) = Mynorma(XM - XS);
    
    PS_M_X(q) = XM(1);
    PS_M_Y(q) = XM(2);

    PS_S_X(q) = XS(1);
    PS_S_Y(q) = XS(2);

    progress = i/Col;

    waitbar(progress, hw, 'Proccessing...');

    disp(['Progress: ' num2str(progress * 100) '%']);

    pause(0.001);
    q = q + 1;

end

t_c = h:h:t;

close(hw);

figure;
plot (t_c, E, 'b-');
set(gca, 'YScale', 'Log');
title(['Error of one-way synchronization, IMP, K = [' str ']']);
xlabel('t');
ylabel('error')

% name1 = ['Графики\Lab7\Односторонняя\Ошибка односторонней синхронизации систем, моделируемых методом CD, Master NU = (' str_M '), Slave NU = (' str_S '), K = (' str ').png'];
% name2 = ['Figures\Lab7\Односторонняя\Error of one-way synchronization, CD, Master NU = (' str_M '), Slave NU = (' str_S '), K = (' str ').fig'];
% saveas(gcf, name1);
% saveas(gcf, name2);
% 
% figure;
% plot(PS_M_X, PS_M_Y, 'b-', 'LineWidth', 2);
% hold on
% plot(PS_S_X, PS_S_Y, 'r-', 'LineWidth', 1);
% title('Phase portrets XY');
% xlabel('x');
% ylabel('y');
% legend('Master', 'Slave');
% 
% name1 = 'Графики\Lab7\Односторонняя\Фазовые портреты синхронизируемых систем.png';
% name2 = 'Figures\Lab7\Односторонняя\Phase portraits of synchronized systems.fig';
% saveas(gcf, name1);
% saveas(gcf, name2);
% 
