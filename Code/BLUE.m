function [b,a]=BLUEnew(X,y,V)
    % This function calculates the best linear unbiased estimator (BLUE) of
    % y, which still works when the covariance matrix V is singular.
    Q=X*pinv(X);
    M=eye(size(Q))-Q;  
    b=pinv(X)*(y-V*M*pinv(M*V*M)*M*y);
    a=pinv(X)*(V-V*M*pinv(M*V*M)*M*V)*pinv(X)';
end