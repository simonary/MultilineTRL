function phi=ang(X)
    %
    % phi=ang(X)
    %
    % This function calculates the phase of a complex-valued variable, in
    % degrees.
    %
    % <version> 2015.9.1
    
    phi=angle(X)/pi*180;
end