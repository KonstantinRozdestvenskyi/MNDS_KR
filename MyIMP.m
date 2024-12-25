function result = MyIMP(X, a, h)
    
    X_prev = X;

    options = optimoptions('fsolve', 'Display', 'none', 'Algorithm', 'trust-region');

    
    X_mid = X_prev;

    fun = @(X_curr) X_curr - X_prev - h/2 * f(X_curr, a);

    X_mid = fsolve(fun, X_mid, options);

    Y = X_prev + h * f(X_mid, a);
    

    % Y_mid = Y_prev + h / 2 * f(Y_prev, a);
    % fun = @(Y_curr) Y_mid - Y_prev + h / 2 * f(Y_mid, a);
    % 
    % % fun = @(Y_curr) f_for_imp(Y_prev, Y_curr, h, a, b, c);
    % 
    %  Y(i, :) = 2 * fsolve(fun, Y_mid, options) - Y_prev;

    result = Y;
end