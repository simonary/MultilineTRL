function handles=CalOptCommonLine(handles)

    g=handles.EstGammaIntp;
    ns=handles.ns;
    
    uLineLength=unique(handles.LineLength);  % Find unique line length
    phi_eff_min=zeros(ns,numel(uLineLength));
    for i=1:numel(uLineLength)
        deltaL=uLineLength([1:i-1,i+1:end])-uLineLength(i);
        d=abs(exp(-g*deltaL.')-exp(g*deltaL.'))/2;
        d(d>1)=1;
        phi_eff_min(:,i)=min(asin(d)/pi*180,[],2);
    end
    [phi_eff_max,CLI]=max(phi_eff_min,[],2);    % Common Line Index (CLI)
    
    AppendMsg(handles.DispWinObj,'Optimal common line at each frequency has been determined.')
        
    %============================   
    %Save results to handles
    %============================
    handles.uLineLength=uLineLength;
    handles.phi_eff_max=phi_eff_max;
    handles.CLI=CLI;
    
end