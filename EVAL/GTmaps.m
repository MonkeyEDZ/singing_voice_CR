function [ GT ] = GTmaps (fileselect)
%CALCULO DE ACORDE GROUND TRUTH - SEGUN BASE MAPS
% INPUT: fileselect - archivos seleccionado para análisis
% OUTPUT: GT - groundtruth para ese archivo según BD MAPS

%% CARGAR MATRIZ DE ACORDES BDMAPS
    [~,~,raw]=xlsread('UCHO_bdmaps.xlsx');
    %Obtención de nota root
if fileselect(30)== '_'; 
    GT_R=str2double(fileselect(29)); 
else
    GT_R=str2double(fileselect(29:30));
end

%% obtención de configuración de acorde
GT_F=fileselect(11:16); 

if strcmp(GT_F,'C0-4-7');
    GT=raw(GT_R+1,2);
elseif strcmp(GT_F,'C0-3-8');
    GT=raw(GT_R+1,3);
elseif strcmp(GT_F,'C0-5-9');
    GT=raw(GT_R+1,4);
elseif strcmp(GT_F,'C0-3-7');
    GT=raw(GT_R+1,6); 
elseif strcmp(GT_F,'C0-4-9');
    GT=raw(GT_R+1,7);
else strcmp(GT_F,'C0-5-8');
    GT=raw(GT_R+1,8);
end      

end

