function [ f_pitch,f_CP,f_CLP,f_CENS,f_CRP,f_CRPSmoothed,f_CENSSmoothed,featureRateSmoothed ] = chroma_analysis_2(f_audio,sideinfo,BPM,WB,n,winSamp,downSamp,featureDens)
    % busqueda de chroma en carpeta por defecto 
    % version 2 de chroma_analysis 1/11/16
    % utilizado para análisis global
    % utilizacion de prametros de GUI
    % input arguments:
    %   f_audio = vector de audio wav
    %   sideinfo = vector de información de wav
    %   BPM = BPM aproximado de la cancion
    %   WB = subdivision del rate en beats o fracciones para mayor informacion temporal
    %   n = factor de compresion de intesidad log en veces
    %   winSamp = largo de ventana de suavizado
    %   downSamp = down-sampling
    % output arguments:
    %diferentes tipos de analisis
    %   f_pitch
    %   f_CP
    %   f_CLP
    %   f_CENS
    %   f_CRP
    %   f_CRP Smoothed
    %   f_CENS Smoothed
    %
    % filename = '29840__herbertboland__pianomood35_1.wav';
    % [f_audio,sideinfo] = wav_to_audio('', 'data_WAV/', filename);
    
    shiftFB = estimateTuning(f_audio);
%     paramPitch.pitchRange = [21:69]; % modificacion para bajas frecuencias
%     shiftFB = estimateTuning(f_audio,pitchRange);
    
    rate = 60 / BPM; % rate
%     winq = WB; % winq = subdivision del rate para mayor informacion temporal
    winL = 22050 * rate/WB;
    
%     paramPitch.winLenSTMSP = 4410;
    paramPitch.winLenSTMSP = winL;
    paramPitch.shiftFB = shiftFB;
    paramPitch.visualize = 0;
%    featureDens = 1.1;
    [f_pitch,sideinfo] = ...
        audio_to_pitch_via_FB_2(f_audio,paramPitch,sideinfo,featureDens);

    paramCP.applyLogCompr = 0;
    paramCP.visualize = 0;
    paramCP.inputFeatureRate = sideinfo.pitch.featureRate;
    [f_CP,sideinfo] = pitch_to_chroma(f_pitch,paramCP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 10^n;
%     paramCLP.factorLogCompr = 100;  % n: compresion de amplitud en veces
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [f_CLP,sideinfo] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

%     paramCENS.winLenSmooth = 21;   % w : ventana de suavizado temporal
%     paramCENS.downsampSmooth = 5;  % d : downsampling --> recorte espectral
    paramCENS.winLenSmooth = winSamp;   % w : ventana de suavizado temporal
    paramCENS.downsampSmooth = downSamp;  % d : downsampling --> recorte espectral
    paramCENS.visualize = 0;
    paramCENS.inputFeatureRate = sideinfo.pitch.featureRate;
    [f_CENS,sideinfo] = pitch_to_CENS(f_pitch,paramCENS,sideinfo);
    % suavizado de CENS
    paramSmooth.winLenSmooth = winSamp;  % w : ventana de suavizado temporal
    paramSmooth.downsampSmooth = downSamp; % d : downsampling --> recorte espectral
    paramSmooth.inputFeatureRate = sideinfo.CENS.featureRate;
    [f_CENSSmoothed, featureRateSmoothed] = ...
        smoothDownsampleFeature(f_CENS,paramSmooth);
    parameterVis.featureRate = featureRateSmoothed;
    parameterVis.title = 'CENS Smoothed';
%     visualizeCRP(f_CENSSmoothed,parameterVis);
    
    
    paramCRP.coeffsToKeep = 55:120; % n = upper coefficients to keep
    paramCRP.visualize = 0;
    paramCRP.factorLogCompr = 10^n;
    paramCRP.inputFeatureRate = sideinfo.pitch.featureRate;
    [f_CRP,sideinfo] = pitch_to_CRP(f_pitch,paramCRP,sideinfo);
    %suavizado de CRP
    paramSmooth.winLenSmooth = winSamp;  % w : ventana de suavizado temporal
    paramSmooth.downsampSmooth = downSamp; % d : downsampling --> recorte espectral
    paramSmooth.inputFeatureRate = sideinfo.CRP.featureRate;
    [f_CRPSmoothed, featureRateSmoothed] = ...
        smoothDownsampleFeature(f_CRP,paramSmooth);
    parameterVis.featureRate = featureRateSmoothed;
    parameterVis.title = 'CRP Smoothed';
%      visualizeCRP(f_CRPSmoothed,parameterVis);
    

end

