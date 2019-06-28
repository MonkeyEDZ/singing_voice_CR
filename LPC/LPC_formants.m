function [ mfWv,stdfWv,formantsW ] = LPC_formants( f_audio,fs,n,minf,bwf,paso,over,visualizar,vocal,sexo )
%LPC_FORMANTS Búsqueda de formantes en archivo de audio previamente cargado
%16/2/18
%   INPUT:
%   f_audio = archivo de audio previamente cargado
%   fs = frecuencia de sampleo de audio (estandarizada en 22050)
%   n = cantidad de coeficientes del filtro buscados
%   minf = frecuencia mínima para búsqueda de formantes
%   bwf = ancho de banda mínimo necesario de separación entre formantes
%   paso = tamaño de ventana de análisis en ms
%   over = porcentaje de solapamiento de ventana
%   visualizar = elección de gráfico o no de formantes on/off 
%   vocal = elección de vocal analizada (a,e,i,o,u)
%   sexo = sexo mayoritario de cantantes
%
%OUTPUT:
%   formantsW = lista completa de formantes (Warped-LPC)
%   mfWv = promedio de formantes filtrado por vocal
%   stdfWv= desviación estándar de formantes filtrado por vocal 

% %   OUTPUT: (VIEJO !!)
% %   mfW = valor global de formantes obtenidas mediante Warped-LPC
% %   stdfW= desviación estándar de formantes obtenidas mediante Warped-LPC 
% %   mf = valor global de formantes obtenidas mediante LPC
% %   stdf= desviación estándar de formantes obtenidas mediante LPC 
% %   formants = lista completa de formantes (LPC simple)

% clear paso over formants formantsW est_x est_f dw dwf
%%  filtrado inicial y recorte de señal

% filtro pasa altos en 40 Hz - ¿¿reemplazar por pasa banda??
dhp = designfilt('highpassiir', 'StopbandFrequency', 5, 'PassbandFrequency', 40,...
    'StopbandAttenuation', 60, 'PassbandRipple', 0.5, 'SampleRate', fs, ...
    'DesignMethod', 'butter', 'MatchExactly', 'passband');
f_audio=filter(dhp,f_audio);

[x0]=LPCw(f_audio,paso,over,fs); % fórmula de ventaneo
% xp=0:1/fs:(length(x0)-1)/fs;

%% LPC y W-LPC

inst=size(x0,2);

for xs=1:inst 
    % por ahora uso versiòn clásica para formantsW
    % pensar en ponerlo como opcional
    [formants(xs,:),formantsW(xs,:)]=LPC_paso(n,x0(:,xs),fs,minf,bwf,'classic');    
end

%% calculo anexo formantes 
mf=mean(formants);
mfW=mean(formantsW);
stdf=std(formants);
stdfW=std(formantsW);

[ mfWv,stdfWv ] = LPC_vocal( formantsW, vocal, sexo );

%% visualización
if strcmp(visualizar,'on')==1
ft=0:size(x0,1)*(over/100)/fs:(fix(size(x0,1)*inst*(over/100))-1)/fs;
figure
for sp=1:4
    subplot(2,2,sp)
    plot(ft,formantsW(:,sp),'r'),hold on,plot(ft,formants(:,sp),'b'),
    plot(ft,ones(1,inst)*mfWv(sp),'g','LineStyle','-.'),
    plot(ft,ones(1,inst)*mfW(sp),'r','LineStyle','--'),
    plot(ft,ones(1,inst)*mf(sp),'b','LineStyle',':') 
    hold off
    xlabel('t[s]')
    ylabel('Frecuencia [Hz]')
        if sp ==1
          axis([0 ft(end) 0 (sp)*1500])
        else
          axis([0 ft(end) (sp-1.5)*1000 (sp+4)*1000])  
        end
    title(strcat('f',num2str(sp)))
    legend((strcat('formantsW','=',num2str(mfW(sp),'%-.0f'),'\sigma','=',num2str(stdfW(sp),'%-.0f')))...
        ,(strcat('formants','=',num2str(mf(sp),'%-.0f'),'\sigma','=',num2str(stdf(sp),'%-.0f')))...
        ,(strcat('vocal','=',num2str(mfWv(sp),'%-.0f'),'\sigma','=',num2str(stdfWv(sp),'%-.0f'))));

end
ha = axes('Position',[-0.1 -0.01 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','FontSize',14,'Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.98,strcat('Analysis de Formantes con LPC, W-LPC y W-LPC + vocal ',...
    '(paso=',num2str(paso),'ms - solapado=',num2str(over),'%)'))
end
end

