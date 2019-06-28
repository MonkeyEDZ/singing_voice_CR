function [ Analysis ] = completeANAL( fullRange,addAnal,kf )
%completeANAL - unión de análisis de todas las frecuencias y adicionales 
%  INPUT
%       fullRange = Análisis en todo el espectro de frecuencias
%       addAnal = Análisis adicional
%       kf = ponderación de análisis adicional
%
%   OUTPUT
%       Analysis = Resultado final 
%

Analysis = fullRange + kf*addAnal;

end

