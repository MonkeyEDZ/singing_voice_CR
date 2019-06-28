function [ Analysis ] = completeANAL( fullRange,addAnal,kf )
%completeANAL - uni�n de an�lisis de todas las frecuencias y adicionales 
%  INPUT
%       fullRange = An�lisis en todo el espectro de frecuencias
%       addAnal = An�lisis adicional
%       kf = ponderaci�n de an�lisis adicional
%
%   OUTPUT
%       Analysis = Resultado final 
%

Analysis = fullRange + kf*addAnal;

end

