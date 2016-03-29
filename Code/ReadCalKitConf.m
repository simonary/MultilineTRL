function handles=ReadCalKitConf(handles)

    %============================
    % Read CalKit configuration
    %============================
    fid = fopen([handles.CalKitDir,handles.CalKitConf]);
    STD = textscan(fid,'%s%s%f');
    fclose(fid);
    
    % Read lines
    LineIndex=find(strcmp(STD{1},'THRU')+strcmp(STD{1},'LINE'));
    LineFile=STD{2}(LineIndex);
    LineLength=STD{3}(LineIndex)/1e3;
    
    NOL=length(LineFile);
    LineDisp=cell(NOL,2);% For data display
    for i=1:NOL
        LineDisp{i,1}=LineFile{i};
        LineDisp{i,2}=LineLength(i);
    end
            
    % Read reflects
    ReflectIndex=find(strcmp(STD{1},'REFLECT'));
    ReflectFile=STD{2}(ReflectIndex);
    ReflectPort=STD{3}(ReflectIndex);
    
    NOR=length(ReflectFile);
    ReDisp=cell(NOR,2); % For data display
	for i=1:NOR
        ReDisp{i,1}=ReflectFile{i};
        ReDisp{i,2}=ReflectPort(i);
    end
     
    set(handles.TLObj,'Data',LineDisp)
    set(handles.ReObj,'Data',ReDisp)      
       
	%============================
    % Read estimated gamma
    %============================
    
	fid = fopen([handles.EstGammaDir,handles.EstGammaConf]);
    EstCell = textscan(fid,'%f%f%f');
    fclose(fid);
    [NOE,~]=size(EstCell{1});
    EstGamma=zeros(NOE,2);
    EstGamma(:,1)=EstCell{1};
    EstGamma(:,2)=EstCell{2}.*exp(1i*EstCell{3}/180*pi);    
    
    EstGammaDisp=cell2mat(EstCell);
    EstGammaDisp(:,1)=EstGammaDisp(:,1)/1e9;
    
    set(handles.EstGammaObj,'Data',EstGammaDisp)
    
 	%============================   
    %Save results to handles
    %============================    
	handles.LineFile=LineFile;
	handles.LineLength=LineLength;
    handles.LineDisp=LineDisp;
    
	handles.ReflectFile=ReflectFile;
	handles.ReflectPort=ReflectPort;
    handles.ReDisp=ReDisp;
    
	handles.EstGamma=EstGamma;
    handles.EstGammaDisp=EstGammaDisp;
    
end