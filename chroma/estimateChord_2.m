function [ CHORDF,chordSUM,fchord,I,CHORDFG] = estimateChord_2(analysis,proc,matrix)
%UNTITLED Summary of this function goes here
    % input arguments:
    %   analysis = valores del tipo de analisis de CHROMA seleccionado
    %   proc = procedimiento elegifo de análisis
    %           * d - "dinámico" - POR DEFECTO
    %           * e - "estático"
    %   matrix = configuración de matriz de acordes (normal/pondS/pondC)
    %
    % output arguments:
    %   CHORDF = vector final de acordes con ubicación temporal
    %   chordSUM = vector columna con sumas de valores
    %   fchord = producto interno entre analysis y matriz de acordes  
    %   I = Índice de acorde máximo seleccionado en método dinámcio 
    %   CHORDFG = obtención de acorde global 

%% se usa matriz por defecto ya guardada de acordes mayores y menores
if strcmp(matrix,'pondS')
    t_mdir = 't_matrixP.mat'; 
elseif strcmp(matrix,'pondC')
    t_mdir = 't_matrixC.mat'; 
else
    t_mdir = 't_matrix.mat'; 
end

load(t_mdir);
    
chroma_names = ['C  ';'C# ';'D  ';'D# ';'E  ';'F  ';'F# ';'G  ';...
        'G# ';'A  ';'A# ';'B  '; 'Cm ';'C#m';'Dm ';'D#m';'Em ';'Fm ';...
        'F#m';'Gm ';'G#m';'Am ';'A#m';'Bm '];

% CONVIENE PENSAR UN TIPO DE ACORDE 'N' PARA VALORES MUY BAJOS ?
    
%% normalizacion de variables
normC = sum(abs(analysis)); % norma del analisis seleccionado ABS
normTm = sum(abs(tm))';     % acordes menores
normTM = sum(abs(tM))';     % acordes mayores
% normas conjunta con analisis
normsm = normTm * normC;    
normsM = normTM * normC;    
    
% assignin ('base','analysis',analysis);

if proc == 'e' ; % PROCEDIMIENTO ESTATICO
    % 		busqueda de maximos valores para establecer vector de acordes a comparar con CHORDlabel
        % todo este proceso debe ser revisado para adapatarlo al analicis de un solo estado inicial
        % usando una ventana mas larga se evita la busqueda y multiplicacion de muchos eventos
        % otra opcion es solo hacer la multiplicacion de matriz con analisis y quedarme con el primer ( o los primeros) 
        % valor para definirlo como CHORDF

    % producto  interno con cada vector de tipo acordes SIN NORMALIZAR
    % CHEQUEAR MULTIPLICACION!!!! 
    fchord = [(tm'* analysis);(tM'* analysis)];
    % fchord = [(analysis'*tm);(analysis'*tM)];
    % fchord = [(analysis'*tm)./normsM;(analysis'*tM)./normsm];  

    % %matriz final de similitud
    [mf,nf] = size(fchord);

        i=1;j=1;
        for j=1:nf
            for i=1:mf
                if fchord(i,j) == max(fchord(:,j))
                    Rchord(i,j)=1;
                    CHORD(j,:) = chroma_names(i,:);
                else
                    Rchord(i,j)=0;
                end
                %Rchord(i,j)= fchord(i,j) - max(fchord(:,j))+1;
                i=i+1;
            end
        end
    
    % %tabla temporal de ubicacion de acordes
        CL=fix(length(CHORDlabel)/(nf+1));
        i=1;
        for i=1:nf
            %CHORDanal(i) = CHORDlabel(i+(i-1)*CL);
            CHORDanal(i) = sum(CHORDlabel(1+(i-1)*CL:i*CL)); % solo i impares ???
             if CHORDanal(i)== 1;
                    CHORDF(i,:) = CHORD(i,:);
             else 
                    CHORDF(i,:) = '   ';
             end
        %         CHORDF(i+(i-1)*CL:i*CL) = CHORDsum{'   '};
        end
    
else % PROCEDIMIENTO DINAMICO
    % obtencion de acorde maximo en base a todas las columnas
    % uso de suma de todas las columnas

% producto interno con cada vector de tipo acordes
    fchord = [(tM'* analysis)./normsM;(tm'* analysis)./normsm];
%     assignin ('base','fchord',fchord);
    %análisis en cada frame bajo evaluación
    chordSUM = fchord;
%normalizado de análisis
    [McS,I] = max(chordSUM);
    for i=1:length(McS)
    chordSUM(:,i) = chordSUM(:,i)/McS(i);
    CHORDF(i,:) = chroma_names(I(i),:);
    end
%obtención de valor global
    chordGLOBAL = sum(fchord,2);
%normalizado de análisis
    chordGLOBAL = chordGLOBAL./max(chordGLOBAL);
    [~,IG] = max(chordGLOBAL);
    CHORDFG = chroma_names(IG,:);
end
