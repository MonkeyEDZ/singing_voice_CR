function [ x0 ] = LPCw( f_audio,paso,over,fs)
%LPCw - LPC ventaneado para obtener mayor precisión en cada instante
% primera versión 10/01/18
%   INPUT:
%           f_audio = señal completa a analizar
%           paso = tamaño de ventana de análisis en ms
%           over = solapamiento en porcentaje
%           fs = frecuencia de sampleo
%
%   OUPUT:
%           x0 = salida de a lapsos seleccionados según paso y overlap
paso=fix(paso*fs/1000); % paso en samples
psample=fix(paso/(100/over)); % overlap de paso 
lf=length(f_audio); % cantidad de ventanas de análisis
wp=blackmanharris(paso);
% wp=kaiser(paso,7);
af=paso:psample:lf;
k=1;
x0=f_audio(1:af(k)).*wp;
for k=2:length(af)
   x0(:,k)=f_audio(af(k-1)-psample+1:af(k-1)+(paso-psample),1).*wp;   
end

end

