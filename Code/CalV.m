function [V_alpha, V_beta]=CalV(ci,oi,LineLength,gamma)
    
    % This function calculate the covariance matrix for BLUE.
    % Refer to [20140730]MultiLineTRL-Note1.doc for more details.

    % Dimension of the covariance matrix V
    M=length(oi)*length(ci);
    
    % Meshgrid for calculating the Kronecker delta. A little bit tricky...
    I=kron(kron(ci,ones(length(oi),1)),ones(1,M));
    J=kron(kron(ones(length(ci),1),oi),ones(1,M));
    K=I.';
    L=J.';
 
    V_alpha=zeros(M);
    V_beta=zeros(M);
    for m=1:M*M
        
        E1i=exp(-gamma*LineLength(I(m)));   E2i=1/E1i;
        E1j=exp(-gamma*LineLength(J(m)));   E2j=1/E1j;
        
        E1k=exp(-gamma*LineLength(K(m)));  E2k=1/E1k;
        E1l=exp(-gamma*LineLength(L(m)));   E2l=1/E1l;
        
        V_alpha(m)= conj(E1j/E1i)*(E1l/E1k)*KronDel(I(m),K(m))+...
                          conj(E1i)*conj(E1j)*E1k*E1l*KronDel(I(m),K(m))+...
                          conj(E2j/E2i)*(E2l/E2k)*KronDel(J(m),L(m))+...
                          conj(E1i)*conj(E1j)*E1k*E1l*KronDel(J(m),L(m));
        V_beta(m)= conj(E2j/E2i)*(E2l/E2k)*KronDel(I(m),K(m))+...
                          conj(E2i)*conj(E2j)*E2k*E2l*KronDel(I(m),K(m))+...
                          conj(E1j/E1i)*(E1l/E1k)*KronDel(J(m),L(m))+...
                          conj(E2i)*conj(E2j)*E2k*E2l*KronDel(J(m),L(m));              
                      
                      
        V_alpha(m)=V_alpha(m)/conj(E2j/E2i-E1j/E1i)/(E2l/E2k-E1l/E1k);
        V_beta(m)=V_beta(m)/conj(E2j/E2i-E1j/E1i)/(E2l/E2k-E1l/E1k);
    end
end