function handles=CalSASB(handles)
    
    ns=handles.ns;
    
    A1=handles.A1;
    B1=handles.B1;
    CA1=handles.CA1;
    R1=handles.R1;
    
	A2=handles.A2;
    B2=handles.B2;
    CA2=handles.CA2;
    R2=handles.R2;
    
    SA=zeros(2,2,ns);
    SB=zeros(2,2,ns);
    for f=1:ns
        X= R1(f)*[A1(f),              B1(f);
                      CA1(f)*A1(f),    1       ];
        Y= R2(f)*[A2(f),              B2(f);
                      CA2(f)*A2(f),    1       ];
        SA(:,:,f)=R2S(X);
        SB(:,:,f)=R2S(Y);
    end

	%============================   
    %Save results to handles
    %============================
    handles.SA=SA;
    handles.SB=SB;
    
end