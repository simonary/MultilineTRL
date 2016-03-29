function S = R2S(R)

    [n,m]=size(R);
    if n~=2 || m~=2
        error('Input matrix must be 2 by 2.')
    end

    S=zeros(2,2);
    S(1,1)=R(1,2)/R(2,2);
    S(1,2)=R(1,1)-R(1,2)*R(2,1)/R(2,2);
    S(2,1)=1/R(2,2);
    S(2,2)=-R(2,1)/R(2,2);

end