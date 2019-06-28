function varargout = SV_CR(varargin)
% SV_CR MATLAB code for SV_CR.fig
%      SV_CR, by itself, creates a new SV_CR or raises the existing
%      singleton*.
%
%      H = SV_CR returns the handle to a new SV_CR or the handle to
%      the existing singleton*.
%
%      SV_CR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SV_CR.M with the given input arguments.
%
%      SV_CR('Property','Value',...) creates a new SV_CR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SV_CR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SV_CR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SV_CR

% Last Modified by GUIDE v2.5 28-Jun-2019 11:50:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SV_CR_OpeningFcn, ...
                   'gui_OutputFcn',  @SV_CR_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SV_CR is made visible.
function SV_CR_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for SV_CR
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SV_CR wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = SV_CR_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LOAD.
function LOAD_Callback(hObject, eventdata, handles)
%% selección de archivos multiples
% clear f_audio sideinfo

global fileselect; global filename
global f_audio
global Fs
global sideinfo
global time
global f

[filename,pathname,filterindex] = uigetfile({'*.wav','Audio files'},'Selección de archivos','MultiSelect', 'on');
P = strfind(pathname,'\'); pathname = pathname(1:P(length(P))); f=1;


%borrado de archivo de resultados previo
delete fileselect.xlsx

%consulta si son varios archivos o uno solo
if iscell(filename)==0
    fileselect=filename;
    set(handles.textFILE,'string',filename)
    filename=1;
end

f=length(filename);
if iscell(filename)==1 %repite consulta si son varios archivos o uno solo
   fileselect=char(filename(f));
end
[f_audio,sideinfo] = wav_to_audio(pathname, '/', fileselect);

% asignacion de variables a entorno MATLAB
assignin ('base','f_audio',f_audio);
assignin('base','sideinfo',sideinfo);
% ploteo de audio
axes(handles.axes_wave)
Fs = sideinfo.wav.fs;
time = (1:length(f_audio))/Fs;
plot(time,f_audio)
ylabel('Amplitude');
xlabel('time [s]');
axis([0 max(time) -1 1])

function editTH_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editTH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editBPM_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editBPM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function textFILE_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in EXEC.
function EXEC_Callback(hObject, eventdata, handles)
tic
% clear CF_CP CF_CLP CF_CRP CF_CRPS CF_CENS CF_CENSS CHORDF analysis


global f_audio
global Fs
global sideinfo
global dBav

global CHORDF
global analysis
global fchord
global filename
global pathname
global fileselect

% global CF_CP
% global CF_CLP
% global CF_CENS
% global CF_CRP
% global CF_CRPS
% global CF_CENSS
global f

global eval_CP
global eval_CLP
global eval_CRP
global eval_CENS
global eval_CRPS
global eval_CENSS

%% parámetros de análisis establecidos
% análisis global
TH = str2double(get(handles.editTH,'string'));
BPM = str2double(get(handles.editBPM,'string'));
n = str2double(get(handles.editn,'string'));
WB = str2double(get(handles.editWB,'string'));
winSamp = str2double(get(handles.editw,'string'));
downSamp = str2double(get(handles.editDS,'string'));
featureDens = str2double(get(handles.editfD,'string'));

if get(handles.toggleBF,'Value')==1 %selección de análisis on/off
    fB='on'; else fB='off'; 
end 
wS = winSamp; dS = downSamp ; fD = featureDens ; midiMin = 21;
midiMax = str2double(get(handles.e_mM,'string'));
kbf = str2double(get(handles.e_kbf,'string')); %ponderación de Bajas Frecuencias

if get(handles.toggleVOZ,'Value')==1 %selección de análisis on/off
    fv='on'; else fv='off'; 
end 
wSv = winSamp; dSv = downSamp ; fDv = featureDens ; midiMinv = 21;
midiMaxv = str2double(get(handles.e_mMv,'string'));
%ponderación de formantes (valores negativos reducen las formantes)
kvf = str2double(get(handles.e_kvf,'string'));

%parámetros LPC voz
minf=str2double(get(handles.e_minf,'string')); 
bwf=str2double(get(handles.e_bwf,'string')); 
np=str2double(get(handles.e_np,'string')); 
paso=str2double(get(handles.e_paso,'string')); 
over=str2double(get(handles.e_over,'string'));
vocal=get(handles.e_vocal,'string');
% sexo = 'masc';
if get(handles.radiob_M,'Value')==1
    sexo='masc';    
else
   sexo='fem';
end

%parámetros banco de Formantes
pf=str2double(get(handles.e_pf,'string')); 
afinacion=str2double(get(handles.e_afinac,'string'));
% frecuencia de LA4 (por defecto 440 Hz)
% conviene modificar el LA 440 como referencia para la voz??
if get(handles.check_gFPF,'Value')==1 %selección de análisis on/off
    generar='on'; else generar='off'; 
end 
if get(handles.check_offset,'Value')==1 %selección de análisis on/off
    offset='full'; else offset='off'; 
end

bTv=get(handles.popup_bT,'Value');
switch bTv
    case 1
        bT='semiT';
    case 2
        bT='triT';
    case 3
        bT='quarT';
    otherwise
end

% parámetros de selección de análisis de resultado
if strcmp(fB,'on')==1
    if strcmp(fv,'on')==1
        AS = 'completo';
    else
        AS = 'bass';
    end
elseif strcmp(fB,'on')==1
        AS = 'voz';
else
        AS = 'global';
end
if strcmp(AS,'completo')
    fv='on';fB='on';
end

%ponderación de post-formantes respecto a bajos
ktf=str2double(get(handles.e_ktf,'string')); 

% configuración de matriz de análisis de acordes (normal/pondS/pondC)
matrixv=get(handles.popup_matrix,'Value');
switch matrixv
    case 1
        matrix='normal';
    case 2
        matrix='pondS';
    case 3
        matrix='pondC';
    otherwise
end

% seleccion de BD 
BD = 'GEN'; % GEN - génerica
%BD = 'MAPS'; % MAPS - BD MAPS

for f=1:length(filename)
    if iscell(filename)==1 %repite consulta si son varios archivos o uno solo
       fileselect=char(filename(f));
    end
    [f_audio,sideinfo] = wav_to_audio(pathname, '/', fileselect);
    %% Analysis global  
    [~,f_CP_g,f_CLP_g,f_CENS_g,f_CRP_g,f_CRPSmoothed_g,f_CENSSmoothed_g,featureRateSmoothed_g ]=...
        chroma_analysis_2(f_audio,sideinfo,BPM,WB,n,winSamp,downSamp,featureDens);    
    calc_mode='d'; % d para "dinámico" / e para "estático"
    if calc_mode=='e';
         [CHORDlabel,CHORDindex, dBav] = dBwave( f_audio,Fs,TH,BPM ); % sólo para método estátito
    end
    anCHORD_g = {f_CP_g;f_CLP_g;f_CENS_g;f_CRP_g;f_CRPSmoothed_g;f_CENSSmoothed_g};
    %% Analysis Baja Frecuencia 
    if strcmp(fB,'on')
        [fB_CP,fB_CLP,fB_CENS,fB_CRP,fB_CRPSmoothed,fB_CENSSmoothed,featureRateSmoothed_B ]=...
            chroma_analysis_3(f_audio,sideinfo,midiMin,midiMax,BPM,WB,n,wS,dS,fD,'Baja Frecuencia');
    % Unión con análisis global - NUEVA VERSIÓN 
            f_CP_B = completeANAL(f_CP_g,fB_CP,kbf);
            f_CLP_B = completeANAL(f_CLP_g,fB_CLP,kbf);
            f_CENS_B = completeANAL(f_CENS_g,fB_CENS,kbf);
            f_CRP_B = completeANAL(f_CRP_g,fB_CRP,kbf);
            f_CRPSmoothed_B = completeANAL(f_CRPSmoothed_g,fB_CRPSmoothed,kbf);
            f_CENSSmoothed_B = completeANAL(f_CENSSmoothed_g,fB_CENSSmoothed,kbf);
            anCHORD_B = {f_CP_B;f_CLP_B;f_CENS_B;f_CRP_B;f_CRPSmoothed_B;f_CENSSmoothed_B};
    end
    %% Analysis en frecuencia para voz - uso de formantesW
    if strcmp(fv,'on')
        [mfWv,stdfWv,formantsW] = LPC_formants( f_audio,sideinfo.wav.fs,...
            np,minf,bwf,paso,over,generar,vocal,sexo); 
%         assignin('base','mfWv',mfWv)
%         assignin('base','formantsW',formantsW)     
        [ h ] = genFPF( pf,mfWv,bT,generar,offset,afinacion ); 
        [fv_CP,fv_CLP,fv_CENS,fv_CRP,fv_CRPSmoothed,fv_CENSSmoothed,featureRateSmoothed_v ]=...
            chroma_analysis_4(f_audio,sideinfo,midiMinv,midiMaxv,BPM,WB,n,wSv,dSv,fDv,'Formantes');
    % Unión con análisis global (SIN ANÁLISIS BAJOS)
            f_CP_v = completeANAL(f_CP_g,fv_CP,kvf);
            f_CLP_v = completeANAL(f_CLP_g,fv_CLP,kvf);
            f_CENS_v = completeANAL(f_CENS_g,fv_CENS,kvf);
            f_CRP_v = completeANAL(f_CRP_g,fv_CRP,kvf);
            f_CRPSmoothed_v = completeANAL(f_CRPSmoothed_g,fv_CRPSmoothed,kvf);
            f_CENSSmoothed_v = completeANAL(f_CENSSmoothed_g,fv_CENSSmoothed,kvf);
            anCHORD_v = {f_CP_v;f_CLP_v;f_CENS_v;f_CRP_v;f_CRPSmoothed_v;f_CENSSmoothed_v};
        %asignación de formantes a GUI
        set(handles.e_f1,'String',num2str(mfWv(1),3)); 
        set(handles.e_f2,'String',num2str(mfWv(2),4)); 
        set(handles.e_f3,'String',num2str(mfWv(3),4)); 
        set(handles.e_f4,'String',num2str(mfWv(4),4));                  
    end
    %% sumatoria completa de tres análisis
    if strcmp(fB,'on') && strcmp(fv,'on');   
            f_CP_t = completeANAL(f_CP_B,f_CP_v,ktf);
            f_CLP_t = completeANAL(f_CLP_B,f_CLP_v,ktf);
            f_CENS_t = completeANAL(f_CENS_B,f_CENS_v,ktf);
            f_CRP_t = completeANAL(f_CRP_B,f_CRP_v,ktf);
            f_CRPSmoothed_t = completeANAL(f_CRPSmoothed_B,f_CRPSmoothed_v,ktf);
            f_CENSSmoothed_t = completeANAL(f_CENSSmoothed_B,f_CENSSmoothed_v,ktf);
            anCHORD_t = {f_CP_t;f_CLP_t;f_CENS_t;f_CRP_t;f_CRPSmoothed_t;f_CENSSmoothed_t};
    end
%% estimateChord
    % selecciono tipos de análisis a realizar
    if strcmp(AS,'global')
        anCHORD=anCHORD_g;
        if get(handles.check_CHROMA,'Value')==1;
        ASfig=figure;
        ASfig.Name=strcat('CHROMA','-',fileselect); ASfig.NumberTitle='off';
        parameterVis.featureRate = featureRateSmoothed_g;
        parameterVis.title = 'Análisis GLOBAL Inicial';
        visualizeCRP(f_CRPSmoothed_g,parameterVis);
        end
    elseif strcmp(AS,'bass')
        anCHORD=anCHORD_B;       
        if get(handles.check_CHROMA,'Value')==1;
            ASfig=figure;
            ASfig.Name=strcat('CHROMA','-',fileselect); ASfig.NumberTitle='off';
            subplot(1,3,1);
            parameterVis.featureRate = featureRateSmoothed_g;
            parameterVis.title = 'Análisis GLOBAL Inicial';
            visualizeCRP(f_CRPSmoothed_g,parameterVis);
            subplot(1,3,2);
            parameterVis.featureRate = featureRateSmoothed_B;
            parameterVis.title = 'Baja Frecuencia';
            visualizeCRP(fB_CRPSmoothed,parameterVis);    
            subplot(1,3,3);
            parameterVis.featureRate = featureRateSmoothed_B;
            parameterVis.title = 'Análisis GLOBAL + BAJOS';
            visualizeCRP(f_CRPSmoothed_B,parameterVis);     
        end
    elseif strcmp(AS,'voz')
        anCHORD=anCHORD_v;       
        if get(handles.check_CHROMA,'Value')==1;
            ASfig=figure;
            ASfig.Name=strcat('CHROMA','-',fileselect); ASfig.NumberTitle='off';
            subplot(1,3,1);
            parameterVis.featureRate = featureRateSmoothed_g;
            parameterVis.title = 'Análisis GLOBAL Inicial';
            visualizeCRP(f_CRPSmoothed_g,parameterVis);
            subplot(1,3,2);
            parameterVis.featureRate = featureRateSmoothed_v;
            parameterVis.title = 'Formantes';
            visualizeCRP(fv_CRPSmoothed,parameterVis);            
            subplot(1,3,3);
            parameterVis.featureRate = featureRateSmoothed_v;
            parameterVis.title = 'Análisis GLOBAL + VOZ';
            visualizeCRP(f_CRPSmoothed_v,parameterVis);    
        end
    else strcmp(AS,'completo')
        anCHORD=anCHORD_t;        
        if get(handles.check_CHROMA,'Value')==1;
            ASfig=figure;
            ASfig.Name=strcat('CHROMA','-',fileselect); ASfig.NumberTitle='off';
            subplot(2,2,1);
            parameterVis.featureRate = featureRateSmoothed_g;
            parameterVis.title = 'Análisis GLOBAL Inicial';
            visualizeCRP(f_CRPSmoothed_g,parameterVis);
            subplot(2,2,2);
            parameterVis.featureRate = featureRateSmoothed_B;
            parameterVis.title = 'Análisis GLOBAL + BAJOS';
            visualizeCRP(f_CRPSmoothed_B,parameterVis);        
            subplot(2,2,3);
            parameterVis.featureRate = featureRateSmoothed_v;
            parameterVis.title = 'Análisis GLOBAL + VOZ';
            visualizeCRP(f_CRPSmoothed_v,parameterVis);        
            subplot(2,2,4);           
            parameterVis.featureRate = featureRateSmoothed_v;
            parameterVis.title = 'Análisis completo';
            visualizeCRP(f_CRPSmoothed_t,parameterVis);
%             figure
%             visualizeCRP(f_CENS_t,parameterVis); %SOLO PARA TESIS
        end
    end
    %%
     clear CF_CP CF_CLP CF_CRP CF_CRPS CF_CENS CF_CENSS 
     for i=1:length(anCHORD)
        analysis = cell2mat(anCHORD(i,1));
         [CHORDF,cS,fchord,I,CHORDFG] = estimateChord_2(analysis,calc_mode,matrix);
%           assignin('base','CHORDF',CHORDF) %cellstr
          if i==1;
              CF_CP(:,:,f)=char(CHORDF);
              chordSUM_CP(:,:,f)=cS(:,:);
              I_CP(:,:,f)=I;
              CFG_CP(:,:,f)=char(CHORDFG);
          elseif i==2;             
              CF_CLP(:,:,f)=char(CHORDF);
              chordSUM_CLP(:,:,f)=cS(:,:);
              I_CLP(:,:,f)=I;
              CFG_CLP(:,:,f)=char(CHORDFG);
          elseif i==3;
              CF_CENS(:,:,f)=char(CHORDF);
              chordSUM_CENS(:,:,f)=cS(:,:);
              I_CENS(:,:,f)=I;  
              CFG_CENS(:,:,f)=char(CHORDFG);
                if get(handles.check_CHORD,'Value')==1
                    CHfig=figure;
                    CHfig.Name=strcat('CHROMA','-',fileselect,'(',matrix,')'); CHfig.NumberTitle='off';
                    subplot(1,3,1);           
                    parameterVis.featureRate = featureRateSmoothed_g;
                    parameterVis.title = 'CENS';
                    parameterVis.chord = 'chord';
        %             parameter.imagerange = [0 1];
                    visualizeCRP(chordSUM_CENS(:,:,f),parameterVis);     
                end
          elseif i==4;
              CF_CRP(:,:,f)=char(CHORDF);
              chordSUM_CRP(:,:,f)=cS(:,:);
              I_CRP(:,:,f)=I;
              CFG_CRP(:,:,f)=char(CHORDFG);
          elseif i==5;
              CF_CRPS(:,:,f)=char(CHORDF);
              chordSUM_CRPS(:,:,f)=cS(:,:);
              I_CRPS(:,:,f)=I;
              CFG_CRPS(:,:,f)=char(CHORDFG);
                if get(handles.check_CHORD,'Value')==1
                    subplot(1,3,2);           
                    parameterVis.featureRate = featureRateSmoothed_g;
                    parameterVis.title = 'CRP Smoothed';
                    parameterVis.chord = 'chord';
                    visualizeCRP(chordSUM_CRPS(:,:,f),parameterVis);
                end
          else 
              CF_CENSS(:,:,f)=char(CHORDF);
              chordSUM_CENSS(:,:,f)=cS(:,:);
              I_CENSS(:,:,f)=I;
              CFG_CENSS(:,:,f)=char(CHORDFG);
              if get(handles.check_CHORD,'Value')==1
                    subplot(1,3,3);           
                    parameterVis.featureRate = featureRateSmoothed_g;
                    parameterVis.title = 'CENS Smoothed';
                    parameterVis.chord = 'chord';
        %             parameter.imagerange = [0 1];
                    visualizeCRP(chordSUM_CENSS(:,:,f),parameterVis);
              end
            
          end
     end       
    ha = axes('Position',[-0.1 -0.01 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','FontSize',14,'Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 0.98,'Resultados de anális de acordes')
   
setappdata(handles.figure1,'CF_CP',CF_CP)
setappdata(handles.figure1,'CF_CLP',CF_CLP)
setappdata(handles.figure1,'CF_CRP',CF_CRP)
setappdata(handles.figure1,'CF_CRPS',CF_CRPS)
setappdata(handles.figure1,'CF_CENS',CF_CENS)
setappdata(handles.figure1,'CF_CENSS',CF_CENSS)

setappdata(handles.figure1,'CFG_CP',CFG_CP)
setappdata(handles.figure1,'CFG_CLP',CFG_CLP)
setappdata(handles.figure1,'CFG_CRP',CFG_CRP)
setappdata(handles.figure1,'CFG_CRPS',CFG_CRPS)
setappdata(handles.figure1,'CFG_CENS',CFG_CENS)
setappdata(handles.figure1,'CFG_CENSS',CFG_CENSS)

%% analisis estadistico

%vector chroma promediado a largo del análisis
CPm=mean(chordSUM_CP(:,:,f),2);
CLPm=mean(chordSUM_CLP(:,:,f),2);
CENSm=mean(chordSUM_CENS(:,:,f),2);
CRPm=mean(chordSUM_CRP(:,:,f),2);
CRPSm=mean(chordSUM_CRPS(:,:,f),2);
CENSSm=mean(chordSUM_CENSS(:,:,f),2);

%Curtosis
CPc=kurtosis(CPm,0)-3;
CLPc=kurtosis(CLPm,0)-3;
CENSc=kurtosis(CENSm,0)-3;
CRPc=kurtosis(CRPm,0)-3;
CRPSc=kurtosis(CRPSm,0)-3
CENSSc=kurtosis(CENSSm,0)-3;

%Curtosis
CPdes=std(CPm);
CLPdes=std(CLPm);
CENSdes=std(CENSm);
CRPdes=std(CRPm);
CRPSdes=std(CRPSm);
CENSSdes=std(CENSSm);

%% evaluacion de P,R,F para BD MAPS
% GT = groundtruth
if strcmp(BD,'MAPS');
    [GT] = GTmaps (fileselect);
else
    %obtencion de GT desde GUI
    GT=get(handles.edit_GT,'string');
end
% assignin('base','GT',GT);
% evaluación según parámetros P,R,F para cada análisis
eval_CP(:,f) = ACR_eval(I_CP(:,:,f),GT);
eval_CLP(:,f) = ACR_eval(I_CLP(:,:,f),GT);
eval_CENS(:,f) = ACR_eval(I_CENS(:,:,f),GT);
eval_CRP(:,f) = ACR_eval(I_CRP(:,:,f),GT);
eval_CRPS(:,f) = ACR_eval(I_CRPS(:,:,f),GT);
eval_CENSS(:,f) = ACR_eval(I_CENSS(:,:,f),GT);

set(handles.edit_P,'String',num2str(eval_CRPS(1,f),3)); 
set(handles.edit_R,'String',num2str(eval_CRPS(2,f),3)); 
set(handles.edit_F,'String',num2str(eval_CRPS(3,f),3)); 
 
%% ploteo de resultado en GUI
axes(handles.axes_chords)
cellplot(cellstr(char(CF_CRPS(:,:,f)))')
set(handles.t_CFG,'String',CFG_CRPS);
% cellplot(cellstr(CHORDF)')

%% grabar matriz de valores - paso de valores a tabla excel por analisis
%      fileselect=cellstr(fileselect);
%      save fileselect.mat chordSUM;
if get(handles.check_EXCEL,'Value')==1
    if strcmp(BD,'MAPS');
        xlswrite('fileselect.xlsx',CF_CP(:,:,f)',fileselect(25:30),'C25');
        xlswrite('fileselect.xlsx',CF_CLP(:,:,f)',fileselect(25:30),'C51');
        xlswrite('fileselect.xlsx',CF_CENS(:,:,f)',fileselect(25:30),'C77');
        xlswrite('fileselect.xlsx',CF_CRP(:,:,f)',fileselect(25:30),'C103');
        xlswrite('fileselect.xlsx',CF_CRPS(:,:,f)',fileselect(25:30),'C129');
        xlswrite('fileselect.xlsx',CF_CENSS(:,:,f)',fileselect(25:30),'C155');
    %valores acorde por frame
        xlswrite('fileselect.xlsx',chordSUM_CP(:,:,f),fileselect(25:30),'C1');
        xlswrite('fileselect.xlsx',chordSUM_CLP(:,:,f),fileselect(25:30),'C27');
        xlswrite('fileselect.xlsx',chordSUM_CENS(:,:,f),fileselect(25:30),'C53');
        xlswrite('fileselect.xlsx',chordSUM_CRP(:,:,f),fileselect(25:30),'C79');
        xlswrite('fileselect.xlsx',chordSUM_CRPS(:,:,f),fileselect(25:30),'C105');
        xlswrite('fileselect.xlsx',chordSUM_CENSS(:,:,f),fileselect(25:30),'C131');
    %evaluación de cada análisis
        xlswrite('fileselect.xlsx',eval_CP(:,f),fileselect(25:30),'B1');
        xlswrite('fileselect.xlsx',eval_CLP(:,f),fileselect(25:30),'B27');
        xlswrite('fileselect.xlsx',eval_CENS(:,f),fileselect(25:30),'B53');
        xlswrite('fileselect.xlsx',eval_CRP(:,f),fileselect(25:30),'B79');
        xlswrite('fileselect.xlsx',eval_CRPS(:,f),fileselect(25:30),'B105');
        xlswrite('fileselect.xlsx',eval_CENSS(:,f),fileselect(25:30),'B131'); 
    else
    %acorde por frame
        xlswrite('fileselect.xlsx',cellstr(char(CF_CP(:,:,f)))',fileselect,'D1');
        xlswrite('fileselect.xlsx',cellstr(char(CF_CLP(:,:,f)))',fileselect,'D27');
        xlswrite('fileselect.xlsx',cellstr(char(CF_CENS(:,:,f)))',fileselect,'D53');
        xlswrite('fileselect.xlsx',cellstr(char(CF_CRP(:,:,f)))',fileselect,'D79');
        xlswrite('fileselect.xlsx',cellstr(char(CF_CRPS(:,:,f)))',fileselect,'D105');
        xlswrite('fileselect.xlsx',cellstr(char(CF_CENSS(:,:,f)))',fileselect,'D131');

    %valores acorde por frame
        xlswrite('fileselect.xlsx',chordSUM_CP(:,:,f),fileselect,'D2');
        xlswrite('fileselect.xlsx',chordSUM_CLP(:,:,f),fileselect,'D28');
        xlswrite('fileselect.xlsx',chordSUM_CENS(:,:,f),fileselect,'D54');
        xlswrite('fileselect.xlsx',chordSUM_CRP(:,:,f),fileselect,'D80');
        xlswrite('fileselect.xlsx',chordSUM_CRPS(:,:,f),fileselect,'D106');
        xlswrite('fileselect.xlsx',chordSUM_CENSS(:,:,f),fileselect,'D132');

    %titulos de analisis
        xlswrite('fileselect.xlsx',cellstr('CP'),fileselect,'C1');
        xlswrite('fileselect.xlsx',cellstr('CLP'),fileselect,'C27');
        xlswrite('fileselect.xlsx',cellstr('CENS'),fileselect,'C53');    
        xlswrite('fileselect.xlsx',cellstr('CRP'),fileselect,'C79');
        xlswrite('fileselect.xlsx',cellstr('CRP Smoothed'),fileselect,'C105');
        xlswrite('fileselect.xlsx',cellstr('CENS Smoothed'),fileselect,'C131');
        %escritura de la tabla con columnas considerando análisis completo
    %     chordT=CHORDFG(:,:,f);
    %     chordT=table(chordT(:,1),chordT(:,2),chordT(:,3),chordT(:,4),...
    %         chordT(:,5),chordT(:,6),'VariableNames',{'f_CP' 'f_CLP' 'f_CENS'...
    %         'f_CRP' 'f_CRPSmoothed' 'f_CENSSmoothed'});
    %     xlswrite('fileselect.xlsx',CF(:,:,1,f)',fileselect(25:30),'A25');
    %    xlswrite('fileselect.xlsx',CHORDFG(:,:,1,f),fileselect(25:30),'A1');
    end

%parámetros usados
        xlswrite('fileselect.xlsx',cellstr(char('parámetros')),fileselect,'A1');
        xlswrite('fileselect.xlsx',cellstr(char('matrix',matrix))',fileselect,'A2');
        xlswrite('fileselect.xlsx',cellstr(char('k pond',num2str(ktf)))',fileselect,'A3');
        
    if get(handles.toggleBF,'Value')==1
        xlswrite('fileselect.xlsx',cellstr(char('MIDI MAX BAJOS',num2str(midiMax)))',fileselect,'A4');
        xlswrite('fileselect.xlsx',cellstr(char('k bajos',num2str(kbf)))',fileselect,'A5');
    end
    if get(handles.toggleVOZ,'Value')==1
        xlswrite('fileselect.xlsx',cellstr(char('MIDI MAX VOZ',num2str(midiMaxv)))',fileselect,'A6');
        xlswrite('fileselect.xlsx',cellstr(char('k voz',num2str(kvf)))',fileselect,'A7');
        xlswrite('fileselect.xlsx',cellstr(char('LPC f min',num2str(minf)))',fileselect,'A8');
        xlswrite('fileselect.xlsx',cellstr(char('LPC BW',num2str(bwf)))',fileselect,'A9');
        xlswrite('fileselect.xlsx',cellstr(char('LPC polos',num2str(np)))',fileselect,'A10');
        xlswrite('fileselect.xlsx',cellstr(char('LPC paso',num2str(paso)))',fileselect,'A11');
        xlswrite('fileselect.xlsx',cellstr(char('LPC overlap',num2str(over)))',fileselect,'A12');
        xlswrite('fileselect.xlsx',cellstr(char('1° formante',num2str(pf)))',fileselect,'A13');
        xlswrite('fileselect.xlsx',cellstr(char('LA4',num2str(afinacion)))',fileselect,'A14');
        xlswrite('fileselect.xlsx',cellstr(char('SEXO',sexo))',fileselect,'A15');
        xlswrite('fileselect.xlsx',cellstr(char('VOCAL',vocal))',fileselect,'A16');
        xlswrite('fileselect.xlsx',cellstr(char('F1',num2str(mfWv(1))))',fileselect,'A17');
        xlswrite('fileselect.xlsx',cellstr(char('F2',num2str(mfWv(2))))',fileselect,'A18');
        xlswrite('fileselect.xlsx',cellstr(char('F3',num2str(mfWv(3))))',fileselect,'A19');
        xlswrite('fileselect.xlsx',cellstr(char('F4',num2str(mfWv(4))))',fileselect,'A20');
    end

% CRP Smoothed
%analisis estadístico
    xlswrite('fileselect.xlsx',cellstr(char('ANÁLISIS CRPS')),fileselect,'A22');
    xlswrite('fileselect.xlsx',cellstr(char('CHORD GLOBAL',CFG_CRPS))',fileselect,'A23');
    xlswrite('fileselect.xlsx',cellstr(char('Curtosis',num2str(CRPSc)))',fileselect,'A24');
    xlswrite('fileselect.xlsx',cellstr(char('Desv Estándar',num2str(CRPSdes)))',fileselect,'A25');
%evaluacion PRF   
    xlswrite('fileselect.xlsx',cellstr(char('Precision',num2str(eval_CRPS(1),f)))',fileselect,'A26');
    xlswrite('fileselect.xlsx',cellstr(char('Recall',num2str(eval_CRPS(2),f)))',fileselect,'A27');
    xlswrite('fileselect.xlsx',cellstr(char('F-Measure',num2str(eval_CRPS(3),f)))',fileselect,'A28');

% CENS
%analisis estadístico
    xlswrite('fileselect.xlsx',cellstr(char('ANÁLISIS CENS')),fileselect,'A30');
    xlswrite('fileselect.xlsx',cellstr(char('CHORD GLOBAL',CFG_CENS))',fileselect,'A31');
    xlswrite('fileselect.xlsx',cellstr(char('Curtosis',num2str(CENSc)))',fileselect,'A32');
    xlswrite('fileselect.xlsx',cellstr(char('Desv Estándar',num2str(CENSdes)))',fileselect,'A33');
%evaluacion PRF   
    xlswrite('fileselect.xlsx',cellstr(char('Precision',num2str(eval_CENS(1),f)))',fileselect,'A34');
    xlswrite('fileselect.xlsx',cellstr(char('Recall',num2str(eval_CENS(2),f)))',fileselect,'A35');
    xlswrite('fileselect.xlsx',cellstr(char('F-Measure',num2str(eval_CENS(3),f)))',fileselect,'A36');
    
% CENS Smoothed
%analisis estadístico
    xlswrite('fileselect.xlsx',cellstr(char('ANÁLISIS CENS S')),fileselect,'A38');
    xlswrite('fileselect.xlsx',cellstr(char('CHORD GLOBAL',CFG_CENSS))',fileselect,'A39');
    xlswrite('fileselect.xlsx',cellstr(char('Curtosis',num2str(CENSSc)))',fileselect,'A40');
    xlswrite('fileselect.xlsx',cellstr(char('Desv Estándar',num2str(CENSSdes)))',fileselect,'A41');
%evaluacion PRF   
    xlswrite('fileselect.xlsx',cellstr(char('Precision',num2str(eval_CENSS(1),f)))',fileselect,'A42');
    xlswrite('fileselect.xlsx',cellstr(char('Recall',num2str(eval_CENSS(2),f)))',fileselect,'A43');
    xlswrite('fileselect.xlsx',cellstr(char('F-Measure',num2str(eval_CENSS(3),f)))',fileselect,'A44');    
end
end
fprintf('LISTO!')
toc

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% clear CF_CP CF_CLP CF_CRP CF_CRPS CF_CENS CF_CENSS CHORDF analysis

% global A
% global f
% CF_CRPS=getappdata(handles.figure1,'CF_CRPS',CF_CRPS);
% set(hObject,'Value',5)
% A = CF_CRPS(:,:,f);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

global f

CF_CP=getappdata(handles.figure1,'CF_CP');
CF_CLP=getappdata(handles.figure1,'CF_CLP');
CF_CRP=getappdata(handles.figure1,'CF_CRP');
CF_CRPS=getappdata(handles.figure1,'CF_CRPS');
CF_CENS=getappdata(handles.figure1,'CF_CENS');
CF_CENSS=getappdata(handles.figure1,'CF_CENSS');

CFG_CP=getappdata(handles.figure1,'CFG_CP');
CFG_CLP=getappdata(handles.figure1,'CFG_CLP');
CFG_CRP=getappdata(handles.figure1,'CFG_CRP');
CFG_CRPS=getappdata(handles.figure1,'CFG_CRPS');
CFG_CENS=getappdata(handles.figure1,'CFG_CENS');
CFG_CENSS=getappdata(handles.figure1,'CFG_CENSS');



global eval_CP
global eval_CLP
global eval_CRP
global eval_CENS
global eval_CRPS
global eval_CENSS

ploteo=get(handles.popupmenu1,'Value');
switch ploteo
    case 1
        A = cellstr(char(CF_CP(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CP(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CP(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CP(3,f),3));
        set(handles.t_CFG,'String',CFG_CP);
    case 2
        A = cellstr(char(CF_CLP(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CLP(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CLP(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CLP(3,f),3));
        set(handles.t_CFG,'String',CFG_CLP);
    case 3
        A = cellstr(char(CF_CENS(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CENS(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CENS(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CENS(3,f),3));         
        set(handles.t_CFG,'String',CFG_CENS);
    case 4
        A = cellstr(char(CF_CRP(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CRP(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CRP(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CRP(3,f),3));      
        set(handles.t_CFG,'String',CFG_CRP);
    case 5
        A = cellstr(char(CF_CRPS(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CRPS(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CRPS(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CRPS(3,f),3));         
        set(handles.t_CFG,'String',CFG_CRPS);
    case 6
        A = cellstr(char(CF_CENSS(:,:,f)));
        set(handles.edit_P,'String',num2str(eval_CENSS(1,f),3)); 
        set(handles.edit_R,'String',num2str(eval_CENSS(2,f),3)); 
        set(handles.edit_F,'String',num2str(eval_CENSS(3,f),3));         
        set(handles.t_CFG,'String',CFG_CENSS);
    otherwise
end

% ploteo de resultado en GUI
axes(handles.axes_chords)
cellplot((A)')
fprintf('RESULTADO')

function editn_Callback(hObject, eventdata, handles)

function editn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editWB_Callback(hObject, eventdata, handles)

function editWB_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editw_Callback(hObject, eventdata, handles)

function editw_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editDS_Callback(hObject, eventdata, handles)

function editDS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editfD_Callback(hObject, eventdata, handles)

function editfD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editk_Callback(hObject, eventdata, handles)

function editk_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function c_BF_Callback(hObject, eventdata, handles)

function c_VOZ_Callback(hObject, eventdata, handles)

function e_mMv_Callback(hObject, eventdata, handles)

function e_mMv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function e_kvf_Callback(hObject, eventdata, handles)

function e_kvf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkVOZ_Callback(hObject, eventdata, handles)

function e_mM_Callback(hObject, eventdata, handles)

function e_mM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_kbf_Callback(hObject, eventdata, handles)

function e_kbf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkBF_Callback(hObject, eventdata, handles)

function e_pf_Callback(hObject, eventdata, handles)

function e_pf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_afinac_Callback(hObject, eventdata, handles)

function e_afinac_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function check_gFPF_Callback(hObject, eventdata, handles)

function check_offset_Callback(hObject, eventdata, handles)

function popup_bT_Callback(hObject, eventdata, handles)

function popup_bT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_minf_Callback(hObject, eventdata, handles)

function e_minf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_np_Callback(hObject, eventdata, handles)

function e_np_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_bwf_Callback(hObject, eventdata, handles)

function e_bwf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_paso_Callback(hObject, eventdata, handles)

function e_paso_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_over_Callback(hObject, eventdata, handles)

function e_over_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popup_matrix_Callback(hObject, eventdata, handles)

function popup_matrix_CreateFcn(hObject, eventdata, handles)
set(hObject,'Value',3)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_vocal_Callback(hObject, eventdata, handles)

function e_vocal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_ktf_Callback(hObject, eventdata, handles)

function e_ktf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function check_CHROMA_Callback(hObject, eventdata, handles)

function check_CHORD_Callback(hObject, eventdata, handles)

function e_f1_Callback(hObject, eventdata, handles)

function e_f1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_f2_Callback(hObject, eventdata, handles)

function e_f2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_f3_Callback(hObject, eventdata, handles)

function e_f3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_f4_Callback(hObject, eventdata, handles)

function e_f4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uibutton_sexo_CreateFcn(hObject, eventdata, handles)

function edit_GT_Callback(hObject, eventdata, handles)

function edit_GT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_P_Callback(hObject, eventdata, handles)

function edit_P_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_R_Callback(hObject, eventdata, handles)

function edit_R_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F_Callback(hObject, eventdata, handles)

function edit_F_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_EXCEL.
function check_EXCEL_Callback(hObject, eventdata, handles)
% hObject    handle to check_EXCEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_EXCEL


% --- Executes on button press in toggleBF.
function toggleBF_Callback(hObject, eventdata, handles)
% hObject    handle to toggleBF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleBF


% --- Executes on button press in toggleVOZ.
function toggleVOZ_Callback(hObject, eventdata, handles)
% hObject    handle to toggleVOZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleVOZ


% --- Executes on button press in pushPLAY.
function pushPLAY_Callback(hObject, eventdata, handles)
% hObject    handle to pushPLAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global f_audio
global Fs
% escuchar=audioplayer(f_audio,Fs);
% play(escuchar)
soundsc(f_audio,Fs)
