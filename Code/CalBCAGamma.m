function [B,CA,Gamma,Bsig,CAsig]=CalBCAGamma(SL,LineLength,uLineLength,CLI,ns,gamma_est,mode)

% This function calculate gamma, b and c/a, using Gauss-Markov theorem.

% M=XTY
if strcmp(mode,'x') % Left error box
    H=[1,0;
         0,1];
elseif strcmp(mode,'y') % Right error box
	H=[0,1;
         1,0];
else
    error('Unknown mode.')
end

% Results
Gamma=zeros(ns,1);
B=zeros(ns,1);
Bsig=zeros(ns,1);
CA=zeros(ns,1);
CAsig=zeros(ns,1);

for f=1:ns
    ci=find(LineLength==uLineLength(CLI(f))); % index for common line(s) in SL
    oi=find(LineLength~=uLineLength(CLI(f))); % index for other line(s) in SL   
    a_gamma=[];
    b_gamma=[];
    a=ones(length(ci)*length(oi),1);
    b_alpha=[];
    b_beta=[];
    for i=1:length(ci)   % For every common line
        Mi=S2R(H*SL{ci(i)}(:,:,f)*H);      %-------------------> Swap port 1 and port 2 for mode y
        for j=1:length(oi) % For every other line    
            Mj=S2R(H*SL{oi(j)}(:,:,f)*H);  %-------------------> Swap port 1 and port 2 for mode y
            [XV,D]=eig(Mj/Mi);
            Eij=diag(D);
            deltaL=LineLength(oi(j))-LineLength(ci(i));
            % case 1  Eij(1)---> exp(-gamma*l), Eij(2)---> exp(gamma*l)
            Ea=(Eij(1)+1/Eij(2))/2; %exp(-gamma*l)
            Eb=(Eij(2)+1/Eij(1))/2; %exp(gamma*l)
            Pa=round(imag(gamma_est(f)*deltaL+log(Ea))/(2*pi));
            gamma_a=(-log(Ea)+1i*2*pi*Pa)/deltaL;
            Da=abs(imag(gamma_a)/imag(gamma_est(f))-1);
            Pb=round(-imag(gamma_est(f)*deltaL-log(Eb))/(2*pi));
            gamma_b=(log(Eb)-1i*2*pi*Pb)/deltaL;
            Db=abs(imag(gamma_b)/imag(gamma_est(f))-1);      
            % case 2 Eij(1)---> exp(gamma*l), Eij(2)---> exp(-gamma*l)
            Ec=(Eij(2)+1/Eij(1))/2; %exp(-gamma*l)
            Ed=(Eij(1)+1/Eij(2))/2; %exp(gamma*l)
            Pc=round(imag(gamma_est(f)*deltaL+log(Ec))/(2*pi));
            gamma_c=(-log(Ec)+1i*2*pi*Pc)/deltaL;
            Dc=abs(imag(gamma_c)/imag(gamma_est(f))-1);
            Pd=round(-imag(gamma_est(f)*deltaL-log(Ed))/(2*pi));
            gamma_d=(log(Ed)-1i*2*pi*Pd)/deltaL;
            Dd=abs(imag(gamma_d)/imag(gamma_est(f))-1); 

            a_gamma=[a_gamma;-deltaL];  
            % Determin the assigment of eigenvalue
            if (Da+Db)<=0.4*(Dc+Dd)
                b_gamma=[b_gamma;log(Ea)-1i*2*pi*Pa];
                b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                b_beta=[b_beta;XV(2,1)/XV(1,1)];
            elseif (Dc+Dd)<=0.4*(Da+Db)
                b_gamma=[b_gamma;log(Ec)-1i*2*pi*Pc];
                XV=XV(:,[2,1]);
                b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                b_beta=[b_beta;XV(2,1)/XV(1,1)];
            else
                if real(gamma_a+gamma_b)>=0 && real(gamma_c+gamma_d)<0
                    b_gamma=[b_gamma;log(Ea)-1i*2*pi*Pa];
                    b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                    b_beta=[b_beta;XV(2,1)/XV(1,1)];
                elseif real(gamma_a+gamma_b)<0 && real(gamma_c+gamma_d)>=0
                    b_gamma=[b_gamma;log(Ec)-1i*2*pi*Pc];
                    XV=XV(:,[2,1]);
                    b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                    b_beta=[b_beta;XV(2,1)/XV(1,1)];
                else
                    if (Da+Db)<=(Dc+Dd)
                        b_gamma=[b_gamma;log(Ea)-1i*2*pi*Pa];
                        b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                        b_beta=[b_beta;XV(2,1)/XV(1,1)];
                    else
                        b_gamma=[b_gamma;log(Ec)-1i*2*pi*Pc];
                        XV=XV(:,[2,1]);
                        b_alpha=[b_alpha;XV(1,2)/XV(2,2)];
                        b_beta=[b_beta;XV(2,1)/XV(1,1)];
                    end           
                end                
            end
        end       
    end 
    % Calculate propagatin constant (Gamma) at each frequency point
    V_gamma=kron(ones(length(ci)),eye(length(oi)))+kron(eye(length(ci)),ones(length(oi)));  % Important!
    [Gamma(f),~]=BLUE(a_gamma,b_gamma,V_gamma);
    % Calculate b and c/a at each frequency point
    [V_alpha, V_beta]=CalV(ci,oi,LineLength,Gamma(f));
    [B(f),Bsig(f)]=BLUE(a,b_alpha,V_alpha);
    [CA(f),CAsig(f)]=BLUE(a,b_beta,V_beta);

end

