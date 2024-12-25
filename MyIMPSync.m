function result = MyIMPSync(X, a, h, S, K)

    N(1) = K(1) * (S(1) - X(1));
    N(2) = K(2) * (S(2) - X(2));
    N(3) = K(3) * (S(3) - X(3));
    N(4) = K(4) * (S(4) - X(4));
    
    X_prev = X;

    options = optimoptions('fsolve', 'Display', 'none', 'Algorithm', 'trust-region');

    
    % X_mid = X_prev + h/2 * f(X_prev, a);

    fun = @(X_curr) X_curr - X_prev - h/2 * fSync(X_curr, a, N);

    X_mid = fsolve(fun, X_prev, options);

    Y = X_prev + h * fSync(X_mid, a, N);

    % Y = 2 * fsolve(fun, X_mid, options) - X_prev;
    

    % Y_mid = Y_prev + h / 2 * f(Y_prev, a);
    % fun = @(Y_curr) Y_mid - Y_prev + h / 2 * f(Y_mid, a);
    % 
    % % fun = @(Y_curr) f_for_imp(Y_prev, Y_curr, h, a, b, c);
    % 
    %  Y(i, :) = 2 * fsolve(fun, Y_mid, options) - Y_prev;

    result = Y;
end