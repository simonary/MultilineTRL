function R = S2R(S)
    
    [n,m]=size(S);
    if n~=2 || m~=2
        error('Input matrix must be 2 by 2.')
    end
    R=zeros(2,2);
    R(1,1)=-(S(1,1)*S(2,2)-S(1,2)*S(2,1))/S(2,1);
    R(1,2)=S(1,1)/S(2,1);
    R(2,1)=-S(2,2)/S(2,1);
    R(2,2)=1/S(2,1);

end