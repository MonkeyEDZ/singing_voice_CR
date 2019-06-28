function [ h ] = genFPF( pf,mfW,bT,generar,offset,afinacion )
%gen FPF - Generación de Formant Pitch Filterbank según mfW
%   Generación según formantes detectadas previamente por LPC_formants
% INPUT:
%       pf = primer formante considerada (1/2)
%       mfW = vector de formantesW resultantes
%       bT = rango de búsqueda de notas asociadas
%       generar = generación de filtros (on/off)
%       offset = análisis de semitonos completos o sólo estándar (full/off)
%       afinación = ubicación de LA4 (default 440)
% 
% OUTPUT:
%       h = matriz de coeficientes de filtro ellip
%
%% opciones de algoritmo
if strcmp(offset,'full')==1
    semitoneOffsets = [0, -0.25, -1/3, -0.5, -2/3, -0.75];
    nameSuffixes = {''; '_minusQuarter'; '_minusThird'; '_minusHalf'; '_minusTwoThird'; '_minusThreeQuarters'};
else
    % si se quiere versión sólo para semitonos en freq estándar
    semitoneOffsets = 0;
    nameSuffixes = {''};
end

if strcmp(bT,'quarT')==1
    bT=1.0293; % cuarto de tono
elseif strcmp(bT,'triT')==1
    bT=1.0393;  % tercio de tono
else
    bT=1.0545; % semitono
end

%% algoritmo
for k=1:length(semitoneOffsets)
   % NO formantes ==> pasabanda con banda de paso muy atenuada (-20dB)
   nameSuffix = nameSuffixes{k};
         h1(120)=struct('a',[],'b',[]);
        if k==1
            load MIDI_FB_ellip_pitch_60_96_22050_Q25.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end
        elseif k == 2
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusQuarter.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end            
        elseif k == 3
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusThird.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end  
        elseif k == 4
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusHalf.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end  
        elseif k == 5
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusTwoThird.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end  
        elseif k == 6
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusThreeQuarters.mat
            for mf=1:120;
                h1(mf).a=h(mf).a*10;
                h1(mf).b=h(mf).b*10;
            end  
        else
            error('Wrong shift parameter!')
        end  
        
        h=h1;
        save(strcat(pwd,'\FORMANTES\',['MIDI_FormantsW_pitch_60_96_22050_Q25',nameSuffix]),'h','-V6');
        
    for fw=pf:4 % cantidad de formantsW posibles
        midi = (1:128);                     % midi notes
        % computing frequencies of midi notes
        midi_freq = 2.^((midi-69+semitoneOffsets(k))/12)*afinacion;  
        % reducción a formantes W
        midi_fW=midi_freq(midi_freq>(mfW(fw)/bT));
        midi_fW=midi_fW(midi_fW<(mfW(fw)*bT));
        mfwi=0; % blanqueo de variable
        [~,mfwi]=ismember(midi_fW,midi_freq);
        midi_freq(1:min(mfwi)-1)=0;
        midi_freq(max(mfwi)+1:end)=0;
        midi_freqW(fw,:)=midi_freq;
        
       
    midi_freq = 2.^((midi-69+semitoneOffsets(k))/12)*afinacion;  
    %ploteo de filtros de formantes    
    if strcmp(generar,'on')==1
        h(120)=struct('a',[],'b',[]);
        disp(['Generating Filterbank: ',nameSuffix]);

        if max(mfwi)<60
            fs = 882;   %resampling pitches 21-59
        elseif max(mfwi)<95
            fs = 4410;  %resampling pitches 60-95
        else
            fs = 22050; %pitches 96-120
        end

        nyq = fs/2;
        midi_min = min(mfwi);
        midi_max = max(mfwi);
        Q = 25; stop = 2; Rp = 1; Rs = 50;
        pass_rel = 1/(2*Q);
        stop_rel = pass_rel*stop;

        % mfW ==> pasabanda original
               
        kf=mfwi(1);
            pitch = midi_freq(kf);
            Wp = [pitch-pass_rel*pitch pitch+pass_rel*pitch]/nyq;
            Ws = [pitch-stop_rel*pitch pitch+stop_rel*pitch]/nyq;
            [n,Wn]=ellipord(Wp,Ws,Rp,Rs);
            [h(kf).b,h(kf).a]=ellip(n,Rp,Rs,Wn);   

        if length(mfwi)>1;
            kf=mfwi(2);
            pitch = midi_freq(kf);
            Wp = [pitch-pass_rel*pitch pitch+pass_rel*pitch]/nyq;
            Ws = [pitch-stop_rel*pitch pitch+stop_rel*pitch]/nyq;
            [n,Wn]=ellipord(Wp,Ws,Rp,Rs);
            [h(kf).b,h(kf).a]=ellip(n,Rp,Rs,Wn);  
            
        end

        num = midi_max-midi_min+1;

        h_fvtool = cell(2*num,1);
        for i = 1:num
            h_fvtool{2*i-1}=h(midi_min+i-1).b;
            h_fvtool{2*i}=h(midi_min+i-1).a;
        end
        fvtool(h_fvtool{:});

        save(strcat(pwd,'\FORMANTES\',['MIDI_FormantsW_pitch_60_96_22050_Q25',nameSuffix]),'h','-V6');

    else
      %En vez de generar filtros, usar los ya existentes y buscar las frecuencias necesarias 
        h1(120)=struct('a',[],'b',[]);
        if k==1
            load MIDI_FB_ellip_pitch_60_96_22050_Q25.mat
            h1(1,mfwi)=h(mfwi);
        elseif k == 2
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusQuarter.mat
            h1(1,mfwi)=h(mfwi);
        elseif k == 3
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusThird.mat
            h1(1,mfwi)=h(mfwi);
        elseif k == 4
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusHalf.mat
            h1(1,mfwi)=h(mfwi);
        elseif k == 5
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusTwoThird.mat
            h1(1,mfwi)=h(mfwi);
        elseif k == 6
            load MIDI_FB_ellip_pitch_60_96_22050_Q25_minusThreeQuarters.mat
            h1(1,mfwi)=h(mfwi);
        else
            error('Wrong shift parameter!')
        end  
        
        h=h1;
        save(strcat(pwd,'\FORMANTES\',['MIDI_FormantsW_pitch_60_96_22050_Q25',nameSuffix]),'h','-V6');
     end
        
    end   

    
end

end

