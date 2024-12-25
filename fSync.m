function [Y] = fSync(X, a, N)  
    % dx / dt = Y(1)
    % dy / dt = Y(2)
    % dz / dt = Y(3)
    % dw / dt = Y(4)

    Y = zeros(4, 1);
    Y(1) = a(1) * X(2) * X(4) + N(1);
    Y(2) = a(6) * X(2) * X(3) + N(2);
    Y(3) = -a(2) * X(2)^2 + a(3) * X(4) + N(3);
    Y(4) = -a(5) * X(1) * X(2) - a(5) * X(3)^3 + N(4);
    
    % Y = zeros(1, 3);
    % Y(1) = -X(2) - X(3);
    % Y(2) = X(1) + a(1) * X(2);
    % Y(3) = a(2) + X(3) * (X(1) - a(3));
end
