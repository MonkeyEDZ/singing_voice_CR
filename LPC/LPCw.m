function [ x0 ] = LPCw( f_audio,paso,over,fs)
%LPCw - LPC ventaneado para obtener mayor precisi�n en cada instante
% primera versi�n 10/01/18
%   INPUT:
%           f_audio = se�al completa a analizar
%           paso = tama�o de ventana de an�lisis en ms
%           over = solapamiento en porcentaje
%           fs = frecuencia de sampleo
%
%   OUPUT:
%           x0 = salida de a lapsos seleccionados seg�n paso y overlap
paso=fix(paso*fs/1000); % paso en samples
psample=fix(paso/(100/over)); % overlap de paso 
lf=length(f_audio); % cantidad de ventanas de an�lisis
wp=blackmanharris(paso);
% wp=kaiser(paso,7);
af=paso:psample:lf;
k=1;
x0=f_audio(1:af(k)).*wp;
for k=2:length(af)
   x0(:,k)=f_audio(af(k-1)-psample+1:af(k-1)+(paso-psample),1).*wp;   
end

end

