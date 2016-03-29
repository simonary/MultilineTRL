function [A1,A2,R1,R2,Reflect]=CalAR(SL, LineLength,SRx, SRy, B1, B2, CA1, CA2, ns, RefType)

    % This function calculate a1, a2, r1 and r2

    A1=zeros(ns,1);         % a1
    A2=zeros(ns,1);         % a2
    R1=zeros(ns,1);         % r1
    R2=zeros(ns,1);         % r2
    Reflect=zeros(ns,1);   % gamma_l
    A1tA2=zeros(ns,1);    % a1*a2
    A1dA2=zeros(ns,1);   % a1/a2
    Ti=find(LineLength==0);  % THRU index
    H=[0,1;
         1,0];
    for f=1:ns
        for i=1:length(Ti)
                M_THRU=S2R(SL{Ti(i)}(:,:,f));
                X=[1,     B1(f);
                   CA1(f),  1];
                Y=[1,     B2(f);
                   CA2(f),  1];
                T=X\M_THRU*H*Y;
                A1tA2(f)=A1tA2(f)+ T(1,2)/T(2,1);
        end
        A1tA2(f)=A1tA2(f)/length(Ti);

        wx=SRx(:,:,f);
        wy=SRy(:,:,f);   
        A1dA2(f)=(wx-B1(f))/(1-wx*CA1(f))...
              *(1-wy*CA2(f))/(wy-B2(f));         % a/alpha

        A1(f)=(A1tA2(f)*A1dA2(f))^0.5;
        Reflect_Gamma=1/A1(f)*(wx-B1(f))/(1-wx*CA1(f));
        Reflect(f)=Reflect_Gamma;
        switch RefType
            case 'OPEN'
                if abs(Reflect_Gamma-1)>abs(Reflect_Gamma+1)  % For open REFLECT
                    A1(f)=-A1(f);
                    Reflect(f)=-Reflect(f);
                end
            case 'SHORT'
                if abs(Reflect_Gamma+1)>abs(Reflect_Gamma-1)  % For short REFLECT
                    A1(f)=-A1(f);
                    Reflect(f)=-Reflect(f);
                end
            otherwise
                error(['Unknown Reflect type "',RefType,'"'])
        end
        A2(f)=A1tA2(f)/A1(f);

        R1(f)=-1/mysqrt(A1(f)-A1(f)*B1(f)*CA1(f));
        % Correct R1's phase
        if f>2
            if abs(ang((R1(f)/R1(f-1))))>60;
                R1(f)=-R1(f);
            end
        end
        R2(f)=1/mysqrt(A2(f)-A2(f)*B2(f)*CA2(f));

        Q=[ 0 ,   A1(f);
           1/A2(f),  0   ];
        if norm(T-R1(f)/R2(f)*Q)>norm(T+R1(f)/R2(f)*Q)
            R2(f)=-R2(f);
        end

    end    

end