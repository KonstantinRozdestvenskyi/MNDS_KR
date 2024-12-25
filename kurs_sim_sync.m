clear; clc;
close all;

% XM_0 = [0.98, 1.9, 0.98, -0.98]; % Начальные значения ПС для Master системы
% 
% a = [5.8, 3.7, 2, 0.9, 1, 1.5]; % Параметры системы
% 
% XS_0 = [10, 1.9 0.98 -0.98]; % Начальные значения ПС Slave системы



TT = 100;               % Transient time
CT = 100;                % Computation time
WT = 2;              % Window time

h = 0.01;              % Integration step time
a = [5.8, 3.7, 2, 0.9, 1, 1.5]';   % parameters

Kforward = [0 5 5 0]';   % Synchronization coefficients for forward synchronization
Kbackward = [0 5 5 0]';  % Synchronization coefficients for backward synchronization

X = [0.98, 1.9, 0.98, -0.98]';          % Initial conditions for master system
X1 = [10, 1.9 0.98 -0.98]';         % Initial conditions for slave system
itrs = 100;             % Amount of synchronization iterations
y = 5;                 % Final array decimation coefficient

% Transient time calculation
for i = 1:ceil(TT/h)
    X = MyIMPSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    X1 = MyIMPSync(X1,a,h,[0 0 0 0],[0 0 0 0]);
    % X = MyCDSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    % X1 = MyCDSync(X1,a,h,[0 0 0 0],[0 0 0 0]);
end

X1_start = X1;
Xwrite = zeros(4, ceil(CT/h/y));

% Time domain calculation
m = 0;
for i = 1:ceil(CT/h)
    X = MyIMPSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    % X = MyCDSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    if mod(i,y) == 0
        m = m + 1 ;
        Xwrite(:,m)= X;
    end
end

% Initialization of helpfull arrays for calculation
WT_forward = zeros(4, ceil(WT/h));
buffer_norm = zeros(1, ceil(WT/h)-1);
buffer_rms = zeros(1, itrs);
buffer_last_rms = zeros(1, ceil(CT/h/y));
WT_iter = ceil(WT/h);


hw = waitbar(0,'Please wait...');

% Calculation of Forward-Backward synchronization for every y point in time domain
for k = 1:m
    waitbar(k/m,hw,'Processing...');

    disp(['progress: ' num2str(k/m * 100) '%']);

    X = Xwrite(:,k);
    %X1 = X1_start;
    X1 = X+5 ;
    % Window array calculation
    for i = 1:WT_iter
        WT_forward(:,i) = X;
        X = MyIMPSync(X,a,h,[0 0 0 0],[0 0 0 0]);
        % X = MyCDSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    end

    % Formatting window array for backward synchronization
    WT_backward = flip(WT_forward');
    WT_backward = WT_backward';

    %rms_error = log10(err1) - log10(err0);

    for i = 1:itrs
        %Forward synch
        for j = 1:(ceil(WT/h)-1)
            X11 = X1;
            Xf = WT_forward(:, j);
            RX = X1-WT_forward(:,j);
            buffer_norm(j) = norm(abs(X1-WT_forward(:,j)));
            X1 = MyIMPSync(X1,a,h,WT_forward(:,j),Kforward);
            % X1 = MyCDSync(X1,a,h,WT_forward(:,j),Kforward);
        end
        %Backward synch
        for j = 1:(ceil(WT/h)-1)
            X1 = MyIMPSync(X1,a,-h,WT_backward(:,j),-Kbackward);
            % X1 = MyCDSync(X1,a,-h,WT_backward(:,j),-Kbackward);
        end

        buffer_rms(i) = rms(buffer_norm);

    end
    buffer_last_rms(k) = log10(buffer_rms(end)) - log10(buffer_rms(1));

end
close(hw);

%isnan checking
buffer_last_rms(isnan(buffer_last_rms)) = 1000000;

figure
surf([Xwrite(1,:)', Xwrite(1,:)'], [Xwrite(2,:)', Xwrite(2,:)'], [Xwrite(3,:)', Xwrite(3,:)'],...
    [buffer_last_rms(1,:)',buffer_last_rms(1,:)'],'EdgeColor','flat', 'FaceColor','none',LineWidth=1.5);
zlabel('$z$','interpreter','latex','FontSize',15);
ylabel('$y$','interpreter','latex','FontSize',15);
xlabel('$x$','interpreter','latex','FontSize',15);
colorbar;
colormap([turbo(1000); 1-flip(copper(144));])
caxis([-14 2]);
% view(0,0);
title('Phase portret with logarithmic error');
view(0, 90);






