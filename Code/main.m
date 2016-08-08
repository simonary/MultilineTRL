function varargout = main(varargin)
% main MATLAB code for main.fig
%      main, by itself, creates a new main or raises the existing
%      singleton*.
%
%      H = main returns the handle to a new main or the handle to
%      the existing singleton*.
%
%      main('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in main.M with the given input arguments.
%
%      main('Property','Value',...) creates a new main or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 28-Mar-2016 18:46:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',           mfilename, ...
                          'gui_Singleton',      gui_Singleton, ...
                          'gui_OpeningFcn',  @main_OpeningFcn, ...
                          'gui_OutputFcn',     @main_OutputFcn, ...
                          'gui_LayoutFcn',      [] , ...
                          'gui_Callback',        []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)
     
    % Choose default command line output for main
    handles.output = hObject;

    % Initialization - by Simon
    handles.DROP=1;                 %Frequency drop
    handles.c=2.997924574e8;    %Light speed
    handles.g=[43,129,86]/255;   %Color specification for plot
    handles.la = 0;                     %RP Shift for Port 1
    handles.lb = 0;                     %RP Shift for Port 2
    handles.calflag=0;                %A flag indicating whether calibration has been performed.
    
    set(handles.TLObj,'Data',[])
    set(handles.ReObj,'Data',[])
    set(handles.EstGammaObj,'Data',[])
       
    handles.store=handles;         %Record initial state

    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles)%#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in ReadCalKitObj.
function ReadCalKitObj_Callback(hObject, eventdata, handles)%#ok

    try exist(handles.CalKitDir,'var');
        [CalKitConf,CalKitDir]=uigetfile('*.*','Select a configuration file',handles.CalKitDir);
    catch
        [CalKitConf,CalKitDir]=uigetfile('*.*','Select a configuration file','');
    end
    if CalKitDir
        try exist(handles.EstGammaDir,'var');
            [EstGammaConf,EstGammaDir]=uigetfile([handles.EstGammaDir,'*.*'],'Specify the estimated Gamma');
        catch
            [EstGammaConf,EstGammaDir]=uigetfile([CalKitDir,'*.*'],'Specify the estimated Gamma');
        end
        if EstGammaDir
            handles.CalKitDir = CalKitDir;
            handles.CalKitConf=CalKitConf;
            handles.EstGammaDir=EstGammaDir;
            handles.EstGammaConf=EstGammaConf;
            handles=ReadCalKitConf(handles); % read CalKit conf and estimated gamma
            flag=~isempty(handles.LineLength) && ~isempty(handles.ReflectPort) && ~isempty(handles.EstGamma);
            if flag
                % Deactive further steps if calibration results already esist
                if handles.calflag
                    handles.calflag=0;
                    DisbaleCalResult(handles,'newly defined CalKit');
                end
                % Activate the Start button if possible
                if ~isempty(get(handles.RefTypeObj,'SelectedObject'))
                    set(handles.StartCalObj,'enable','on')
                else
                    set(handles.StartCalObj,'enable','off')
                end
                AppendMsg(handles.DispWinObj,['CalKit configuration file loaded. ',handles.CalKitDir,handles.CalKitConf])
                AppendMsg(handles.DispWinObj,['Estimated gamma loaded. ',handles.EstGammaDir,handles.EstGammaConf])
            else
                if isempty(handles.LineLength) || isempty(handles.ReflectPort)
                    AppendMsg(handles.DispWinObj,'Error: Invalid CalKit configuration file. ')
                else
                    AppendMsg(handles.DispWinObj,['CalKit configuration file loaded. ',handles.CalKitDir,handles.CalKitConf])
                end
                if isempty(handles.EstGamma)
                    AppendMsg(handles.DispWinObj,'Error: Invalid estimated Gamma. ')
                else
                    AppendMsg(handles.DispWinObj,['Estimated gamma loaded. ',handles.EstGammaDir,handles.EstGammaConf])
                end
                % Deactive further step when any reading fails
                set(handles.StartCalObj,'enable','off')
                if handles.calflag
                    handles.calflag=0;
                    DisbaleCalResult(handles,'invalid CalKit');
                end
            end
            guidata(hObject,handles);
        end
    end

% --- Executes when selected object is changed in RefTypeObj.
function RefTypeObj_SelectionChangeFcn(hObject, eventdata, handles)%#ok

    RefTypeObj=get(hObject,'Tag');
    switch RefTypeObj
        case 'SHORTObj'
            handles.RefType='SHORT';
        case 'OPENObj'
            handles.RefType='OPEN';
        otherwise
            error(['Unknown RefTypeObj "',RefTypeObj,'"'])
    end
    
    % Change of reflect type will deactive further steps
	if handles.calflag
        handles.calflag=0;
        DisbaleCalResult(handles,'change of reflect type');
	end
    try flag=~isempty(handles.LineLength) && ~isempty(handles.ReflectPort) && ~isempty(handles.EstGamma);
        if flag
            set(handles.StartCalObj,'enable','on')
        end
    catch
    end
    guidata(hObject,handles);
    
% --- Executes on button press in ResetObj.
function ResetObj_Callback(hObject, eventdata, handles)%#ok

	handles=handles.store;
    handles.store=handles; 
    
    set(handles.TLObj,'Data',[])
    set(handles.ReObj,'Data',[])
    set(handles.EstGammaObj,'Data',[])
    set(handles.OPENObj,'Value',0);
    set(handles.SHORTObj,'Value',0);
    set(handles.DropObj,'Value',handles.DROP);
    set(handles.StartCalObj,'enable','off')
    set(handles.CalKitParaObj,'enable','off')
    set(handles.ErrBoxObj,'enable','off')
    set(handles.ExportObj,'enable','off')
    set(handles.DeEmObj,'enable','off')
    set(handles.DispWinObj,'String','');
    
    guidata(hObject, handles);
    
% --- Executes on selection change in DropObj.
function DropObj_Callback(hObject, eventdata, handles)%#ok

    contents = cellstr(get(hObject,'String'));
    handles.DROP=str2num(contents{get(hObject,'Value')});%#ok
    if handles.calflag
        handles.calflag=0;
        DisbaleCalResult(handles,'change of DROP');
    end
    guidata(hObject, handles);

% --- Executes on button press in StartCalObj.
function StartCalObj_Callback(hObject, eventdata, handles)%#ok
    
    % disable all button while calibrating
    set([
        handles.ReadCalKitObj;
        handles.OPENObj;
    	handles.SHORTObj;
    	handles.ResetObj;
    	handles.DropObj;
    	handles.StartCalObj;
    	handles.CalKitParaObj;
    	handles.ErrBoxObj;
    	handles.ExportObj;
    	handles.RefShiftObj;
    	handles.DeEmObj;
        ],'enable','off');

    % Step 1: Read CalKit sNp files
    handles=ReadCalKitSNP(handles);
    % Step 2: Determine the optimal common line
    handles=CalOptCommonLine(handles);
    % Step 3: Calculate b1, b2 (c/a)1, (c/a)2 for both X and Y
    AppendMsg(handles.DispWinObj,'Caculating B1, CA1, Gamma1, B1sig and CA1sig...')
    [handles.B1,handles.CA1,handles.Gamma1,handles.B1sig,handles.CA1sig]=CalBCAGamma(handles.SL,...
                                                                                                                                      handles.LineLength,...
                                                                                                                                      handles.uLineLength,...
                                                                                                                                      handles.CLI,...
                                                                                                                                      handles.ns,...
                                                                                                                                      handles.EstGammaIntp,...
                                                                                                                                      'x');
    AppendMsg(handles.DispWinObj,'Caculating B2, CA2, Gamma2, B2sig and CA2sig...')
    [handles.B2,handles.CA2,handles.Gamma2,handles.B2sig,handles.CA2sig]=CalBCAGamma(handles.SL,...
                                                                                                                                      handles.LineLength,...
                                                                                                                                      handles.uLineLength,...
                                                                                                                                      handles.CLI,...
                                                                                                                                      handles.ns,...
                                                                                                                                      handles.EstGammaIntp,...
                                                                                                                                      'y');  
    % Step 4: Calculate a1, a2, and r1/r2
    AppendMsg(handles.DispWinObj,'Calculating A and R...')
    [handles.A1,handles.A2,handles.R1,handles.R2,handles.Reflect]=CalAR(handles.SL,...
                                                                                                           handles.LineLength,...
                                                                                                           handles.SRa,...
                                                                                                           handles.SRb,...
                                                                                                           handles.B1,...
                                                                                                           handles.B2,...
                                                                                                           handles.CA1,...
                                                                                                           handles.CA2,...
                                                                                                           handles.ns,...
                                                                                                           handles.RefType);
    % Step 5: Calculate Error Box X and Y
    AppendMsg(handles.DispWinObj,'Calculating S-Parameters of error box A and B...')
    handles=CalSASB(handles);
    AppendMsg(handles.DispWinObj,'Done.')
    
    handles.calflag=1;
    
    %reactivate buttons
    set([
        handles.ReadCalKitObj;
        handles.OPENObj;
    	handles.SHORTObj;
    	handles.ResetObj;
    	handles.DropObj;
    	handles.StartCalObj;
    	handles.CalKitParaObj;
    	handles.ErrBoxObj;
    	handles.ExportObj;
    	handles.RefShiftObj;
    	handles.DeEmObj;
        ],'enable','on');
    
    guidata(hObject,handles);

% --- Executes on button press in CalKitParaObj.
function CalKitParaObj_Callback(hObject, eventdata, handles)%#ok

    figure('name','Results: CalKit Properties','position',[50,150,1100,500])
    %Minium Effective Phase Difference
    subplot(2,4,1)
    plot(handles.Freq/1e9,handles.phi_eff_max,'Color',handles.g)
    hold on
    plot(handles.Freq/1e9,ones(size(handles.Freq))*20,':r')
    hold on
    plot(handles.Freq/1e9,ones(size(handles.Freq))*90,':b')
    hold off
    title('Minium Effective Phase Difference (deg)')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    ylim([0,100])
    xlabel('Frequency (GHz)');
    % Common Line Index
    subplot(2,4,5)
    plot(handles.Freq/1e9,handles.CLI,'s','Color',handles.g)
    set(gca,'YTick',1:length(handles.uLineLength))
    title('Common Line Index')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %Propagation Constant
    subplot(2,4,2)
	plot(handles.Freq/1e9,imag([handles.Gamma1,handles.EstGammaIntp]))
    legend({'Measured','Estimated'},'Location','Northwest');
    title('Propagation Constant')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %Attenuation Constant
    subplot(2,4,3)
	plot(handles.Freq/1e9,real([handles.Gamma1,handles.EstGammaIntp]))
    legend({'Measured','Estimated'},'Location','Northwest');
    title('Attenuation Constant')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %Effective Permittivity
    subplot(2,4,6)
	EffPermMeas=(handles.c*imag(handles.Gamma1)./handles.Freq/2/pi).^2;
    EffPermEst=(handles.c*imag(handles.EstGammaIntp)./handles.Freq/2/pi).^2;
    plot(handles.Freq/1e9,[EffPermMeas,EffPermEst])
    legend({'Measured','Estimated'},'Location','Northwest');
    title('Effective Permittivity')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    % Normalized Standard Deviations
    subplot(2,4,7)
    plot(handles.Freq/1e9,abs([handles.B1sig,handles.CA1sig].^0.5))
    legend({'b','c/a'})
    title('Normalized Standard Deviations')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    subplot(2,4,4)
    plot(handles.Freq/1e9,abs(handles.Reflect));
    title('|\Gamma_l|')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    subplot(2,4,8)
    plot(handles.Freq/1e9,ang(handles.Reflect));
    title('\angle\Gamma_l (deg)')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    
% --- Executes on button press in ErrBoxObj.
function ErrBoxObj_Callback(hObject, eventdata, handles)%#ok

    figure('name','Results: S-Parameters of Error Box A and B','position',[50,150,1100,500])
    %S11-mag
    subplot(2,3,1)
    plot(handles.Freq/1e9,abs([squeeze(handles.SA(1,1,:)),squeeze(handles.SB(1,1,:))]));
    title('|S_{11}|')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %S11-ang
    subplot(2,3,4)
    plot(handles.Freq/1e9,ang([squeeze(handles.SA(1,1,:)),squeeze(handles.SB(1,1,:))]));
    title('\angle S_{11} (deg)')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    ylim([-180,180])
    %S12-mag
    subplot(2,3,2)
    plot(handles.Freq/1e9,abs([squeeze(handles.SA(1,2,:)),squeeze(handles.SB(1,2,:))]));
    title('|S_{12}|')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %S12-ang
    subplot(2,3,5)
    plot(handles.Freq/1e9,ang([squeeze(handles.SA(1,2,:)),squeeze(handles.SB(1,2,:))]));
    title('\angle S_{12} (deg)')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    ylim([-180,180])
    %S22-mag
    subplot(2,3,3)
    plot(handles.Freq/1e9,abs([squeeze(handles.SA(2,2,:)),squeeze(handles.SB(2,2,:))]));
    title('|S_{22}|')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    %S22-ange
    subplot(2,3,6)
    plot(handles.Freq/1e9,ang([squeeze(handles.SA(2,2,:)),squeeze(handles.SB(2,2,:))]));
    title('\angle S_{22} (deg)')
    legend({'A','B'},'location','best')
    xlim([handles.Freq(1)/1e9,handles.Freq(end)/1e9])
    xlabel('Frequency (GHz)');
    ylim([-180,180])
  
% --- Executes on button press in ExportObj.
function ExportObj_Callback(hObject, eventdata, handles)%#ok

    try
        ExportDir=uigetdir(handles.ExportDir,'Select path to export');
    catch
        ExportDir=uigetdir(handles.CalKitDir,'Select path to export');
    end
    if ExportDir
        writeSP([ExportDir, filesep, 'MTRL-SA.s2p'], handles.SA, handles.Freq);
        AppendMsg(handles.DispWinObj,['Exported to: ',ExportDir, filesep,'MTRL-SA.s2p'])
        writeSP([ExportDir,[filesep 'MTRL-SB.s2p']], handles.SB, handles.Freq);
        AppendMsg(handles.DispWinObj,['Exported to: ',ExportDir, filesep, 'MTRL-SB.s2p'])
        writeGamma([ExportDir, filesep, 'MTRL-Gamma.txt'], handles.Gamma1, handles.Freq);
        AppendMsg(handles.DispWinObj,['Exported to: ',ExportDir, filesep, 'MTRL-Gamma.txt'])
        handles.ExportDir=ExportDir;
        AppendMsg(handles.DispWinObj,'Done.')
        guidata(hObject, handles);
    end
    
% --- Executes on button press in RefShiftObj.
function RefShiftObj_Callback(hObject, eventdata, handles)%#ok

    prompt = {'RP shift for Port 1 (unit:mm)','RP shift for Port 2 (unit:mm)'};
    dlg_title = '';
    num_lines = 1;
    defaultans = {num2str(handles.la),num2str(handles.lb)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if ~isempty(answer)
        la=str2double(answer{1});
        lb=str2double(answer{2});
        if isnan(la) || isnan(lb)
            errordlg('Please input vaild numbers.','Error');
        else
            handles.la=str2double(answer{1});
            handles.lb=str2double(answer{2});
            AppendMsg(handles.DispWinObj,['Shift of reference planes changed to P1: ',answer{1},' mm and P2: ',answer{2}, ' mm'])
            guidata(hObject, handles);
        end
    end
    
% --- Executes on button press in DeEmObj.
function DeEmObj_Callback(hObject, eventdata, handles)%#ok

    [filelist,DUTDir]=uigetfile({'*.S2P','*.s2p'},'Choose DUT files','MultiSelect','on',handles.CalKitDir);
    if DUTDir
        OutputFolder=['MTRL_',datestr(now,'yyyymmdd')];
        if ~exist([DUTDir,OutputFolder],'dir')
            mkdir([DUTDir,OutputFolder])
        end
        if ~iscell(filelist)
            filelist={filelist};
        end
        NOF=numel(filelist); 
        H=[0,1;
             1,0];
        for i=1:NOF
            S_obj=read(rfdata.data, [DUTDir,filelist{i}]);
            DUT=S_obj.S_Parameters(:,:,1:handles.DROP:end);
            Freq=S_obj.Freq(1:handles.DROP:end);
            ns=numel(Freq);
            if ns~=handles.ns
                error('The DUT and CalKit must have the same amount of frequency points.')
            end
            TRLDUT=zeros(size(DUT));
            for f=1:ns
                a=exp(-handles.Gamma1(f)*handles.la/1e3); % shift of reference plane
                b=exp(-handles.Gamma2(f)*handles.lb/1e3); % shift of reference plane
                X=S2R(handles.SA(:,:,f))*[a,0;0,a^(-1)];
                Y=[b,0;0,b^(-1)]*S2R(H*handles.SB(:,:,f)*H);
                TRLDUT(:,:,f)=R2S(X\S2R(DUT(:,:,f))/Y);
            end
            writeSP([DUTDir,OutputFolder, filesep, 'MTRL-',filelist{i}], TRLDUT, Freq)
            AppendMsg(handles.DispWinObj,['MTRL file created: ',DUTDir,OutputFolder, filesep, 'MTRL-',filelist{i}])
        end       
        AppendMsg(handles.DispWinObj,'Done.')
    end
 

function DisbaleCalResult(handles,reason)
    set(handles.CalKitParaObj,'enable','off')
    set(handles.ErrBoxObj,'enable','off')
    set(handles.ExportObj,'enable','off')
    set(handles.DeEmObj,'enable','off')
    AppendMsg(handles.DispWinObj,['Calibration is violated due to ',reason,'.'])
