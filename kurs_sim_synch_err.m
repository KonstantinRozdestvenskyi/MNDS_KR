clear; clc;
close all;

% XM_0 = [0.98, 1.9, 0.98, -0.98]; % Начальные значения ПС для Master системы
% 
% a = [5.8, 3.7, 2, 0.9, 1, 1.5]; % Параметры системы
% 
% XS_0 = [10, 1.9 0.98 -0.98]; % Начальные значения ПС Slave системы



TT = 100;               % Transient time
CT = 10;                % Computation time
WT = 2;              % Window time

h = 0.01;              % Integration step time
a = [5.8, 3.7, 2, 0.9, 1, 1.5]';   % parameters

Kforward = [0 5 5 0]';   % Synchronization coefficients for forward synchronization
Kbackward = [0 5 5 0]';  % Synchronization coefficients for backward synchronization

X = [0.98, 1.9, 0.98, -0.98]';          % Initial conditions for master system
X1 = [10, 1.9 0.98 -0.98]';         % Initial conditions for slave system
itrs = 100;             % Amount of synchronization iterations
y = 200;                 % Final array decimation coefficient

% Transient time calculation
disp('Transient');

for i = 1:ceil(TT/h)
    disp(['Progress: ' num2str(i/ceil(TT/h) * 100) '%']);
    X = MyIMPSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    X1 = MyIMPSync(X1,a,h,[0 0 0 0],[0 0 0 0]);
    % X = MyCDSync(X,a,h,[0 0 0 0],[0 0 0 0]);
    % X1 = MyCDSync(X1,a,h,[0 0 0 0],[0 0 0 0]);
end

E0 = norm(abs(X1 - X));

E0_log = log10(E0);

X1_start = X1;
X_start = X;
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

Err(1) = norm(abs(X1_start - X));


WT_forward = zeros(4, ceil(WT/h));
buffer_norm = zeros(1, ceil(WT/h)-1);
buffer_rms = zeros(1, itrs);
buffer_last_rms = zeros(1, ceil(CT/h/y) + 1);
buffer_last_err = zeros(1, ceil(CT/h/y) + 1);
WT_iter = ceil(WT/h);

buffer_last_rms(1) = E0_log;
buffer_last_err(1) = E0;

hw = waitbar(0,'Please wait...');

last_k = m + 1;

% Calculation of Forward-Backward synchronization for every y point in time domain
for k = 1:m
    waitbar(k/m,hw,'Processing...');
    disp(['Progress' num2str(k/m * 100) '%']);

    X = Xwrite(:,k);
    %X1 = X1_start;
    X1 = X + 5 ;
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

        disp(['itr = ' num2str(i)]);
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


    R_log = log10(buffer_rms(end)) - log10(buffer_rms(1)); 
    buffer_last_rms(k + 1) = log10(buffer_rms(end)) - log10(buffer_rms(1));
    buffer_last_err(k + 1) = buffer_rms(end);

    Err = [Err, buffer_norm];

    if(R_log <= -12)
        last_k = k;
        break
    end



end

% for k = (last_k + 1):m
%     waitbar(k/m,hw,'Processing...');
%     X = Xwrite(:, k);
%     for i = 1:y 
%         X = MyCD(X, a, h);
%         X1 = MyCD(X1, a, h);
%         % X = MyIMP(X, a, h);
%         % X1 = MyIMP(X1, a, h);
%         buffer_norm(i) = norm(abs(X1-X));
%     end
%     buffer_last_rms(k + 1) = log10(buffer_norm(end)) - log10(buffer_norm(1));
%     buffer_last_err(k + 1) = buffer_rms(end);
% end

Err_size = y*m + 1;
    
for i = 1:(Err_size - length(Err))
    tmp_e = Err(end);
    Err = [Err, tmp_e];
end
    
l_other = (CT/h + 1) - Err_size;

% figure;

if last_k <= m

    q = last_k;
    
    
    
    X = Xwrite(:, last_k);
    
    for i = 1:l_other
        % X = MyCD(X, a, h);
        % X1 = MyCD(X1, a, h);

        X = MyIMP(X, a, h);
        X1 = MyIMP(X1, a, h);
    
        % plot(i * h, X(1), 'b.', 'MarkerSize', 20);
        % hold on
        % plot(i * h, X1(1), 'r.', 'MarkerSize', 10);
    
        Err3 = norm(abs(X1 - X));
    
        Err = [Err, Err3];
    
        if mod(i, y) == 0
            q = q + 1;
            pr = q/m;
            waitbar(k/m,hw,'Processing...');
        end
    end
end

close(hw);


%isnan checking
buffer_last_rms(isnan(buffer_last_rms)) = 1000000;

figure
tc = 0:h:CT;
plot(tc, Err, 'LineWidth', 1.5);
ylabel('$Error$','interpreter','latex','FontSize',12);
xlabel('$t$','interpreter','latex','FontSize',12);
set(gca, 'YScale', 'Log');
title('Error of symetric synchronization systems CD');

