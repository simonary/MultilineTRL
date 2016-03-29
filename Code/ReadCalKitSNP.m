function handles=ReadCalKitSNP(handles)
    
        LineFile=handles.LineFile;
        NOL=numel(LineFile);
        SL=cell(1,NOL);
        for i=1:NOL
            SL_obj=read(rfdata.data, [handles.CalKitDir,LineFile{i}]);
            SL{i}=SL_obj.S_Parameters(:,:,1:handles.DROP:end);
            if (i==1)
                Freq=SL_obj.Freq(1:handles.DROP:end);
            end
            AppendMsg(handles.DispWinObj,['CalKit ', LineFile{i},' loaded.'])
        end
        ns=numel(Freq);
        
        % Read reflects
        ReflectFile=handles.ReflectFile;
        ReflectPort=handles.ReflectPort;
        ReflectPort1Index=find(ReflectPort==1);
        ReflectPort2Index=find(ReflectPort==2);
        SRa=zeros(1,1,ns);
        SRb=zeros(1,1,ns);
        for i=1:numel(ReflectPort1Index)
            SR_obj=read(rfdata.data,[handles.CalKitDir,ReflectFile{ReflectPort1Index(i)}]);
            SRa=SRa+SR_obj.S_Parameters(1:handles.DROP:end);
            AppendMsg(handles.DispWinObj,['CalKit ', ReflectFile{ReflectPort1Index(i)},' for port 1 loaded.'])
        end
        for i=1:numel(ReflectPort2Index)
            SR_obj=read(rfdata.data,[handles.CalKitDir,ReflectFile{ReflectPort2Index(i)}]);
            SRb=SRb+SR_obj.S_Parameters(1:handles.DROP:end);
            AppendMsg(handles.DispWinObj,['CalKit ', ReflectFile{ReflectPort2Index(i)},' for port 2 loaded.'])
        end
        SRa=SRa/numel(ReflectPort1Index);
        SRb=SRb/numel(ReflectPort2Index);
        
        
        %============================   
        %Save results to handles
        %============================       
        handles.SL=SL;
        handles.SRa=SRa;
        handles.SRb=SRb;
        handles.Freq=Freq;
        handles.ns=numel(Freq);
        handles.EstGammaIntp=interp1(handles.EstGamma(:,1),handles.EstGamma(:,2),Freq,'linear','extrap');

end