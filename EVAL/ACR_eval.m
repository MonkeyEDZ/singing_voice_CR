function [eval] = ACR_eval(I,GT)
    % EVALUACI�N DE ALGORITMO PARA CADA AN�LISIS
    % version 1.0 26/6/17
    % utilizacion de vectores de indices de acordes
    % c�lculo de similitud de matrices considerando groung truth/referencia
        
    % input arguments:
    % I = acordes de resultado seg�n an�lisis (�NDICES)
    % GT = acorde anotado / referencia 
    
    % output arguments:
    % eval = [P,R,F] == matriz con par�metros de evaluaci�n


chroma_names = ['C  ';'C# ';'D  ';'D# ';'E  ';'F  ';'F# ';'G  ';...
    'G# ';'A  ';'A# ';'B  '; 'Cm ';'C#m';'Dm ';'D#m';'Em ';'Fm ';...
    'F#m';'Gm ';'G#m';'Am ';'A#m';'Bm '];

%GT = 10;
%I = [8 10 9 10 10 10];
% paso de acorde a �ndice de acorde seg�n chroma_names
GT_s=strfind(cellstr(chroma_names),cellstr(GT));
GT_s=cell2mat(cellfun(@sum,GT_s,'UniformOutput',false));
GT_I=find(GT_s,1);
GT=ones(1,length(I))*GT_I; % en este caso suponemos acorde constante en el audio
[C,order] = confusionmat(GT,I);
I_GT=find(order==GT(1));
%c�lculo de TRUE POSITIVE
TP=C(I_GT,I_GT);
%c�lculo de FALSE POSITIVE
FP=sum(C(:,I_GT))-TP;
%c�lculo de FALSE NEGATIVE
FN=sum(C(I_GT,:))-TP;
% C�lculo de par�metros de evaluaci�n
P = TP/(TP+FP);     % P = PRECISION
R = TP/(TP+FN);     % R = RECALL
F = 2*P*R/(P + R);  % F = F MEASURE
if TP ==0
    P=0;R=0;F=0;
end
eval = [P,R,F];
end