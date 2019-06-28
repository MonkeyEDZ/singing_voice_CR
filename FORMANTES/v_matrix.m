%% pre diseño de matrices de vocales / formantes
% datos extraídos de # Características Acústicas de las vocales de Español
% Rioplatenese" - L. Aronson, H.L. Rufiner, H. Furmanski & P. Estienne

% pueden agregarse más filas para vocales de distintos idiomas

%           F0  F1  F2   F3   F4
vf_masc = [127 830 1350 2450 3665;  %a
            125 430 2120 2628 3610; %e
            130 290 2295 2915 3645; %i
            124 510 860 2480 3485;  %o
            124 335 720 2380 3355]; %u
        
%           F1  F2   F3  F4        
bwf_masc = [105 106 142 197; %a
            75 106 140 180; %e
            63 103 174 124; %i
            83 105 156 170;  %o
            80 112 208 150]; %u

%         F0  F1  F2   F3   F4        
vf_fem = [205 330 1553 2890 3930; %a
          205 330 2500 3130 4150; %e
          207 330 2765 3740 4366; %i
          204 546 934 2966 3854;  %o
          204 382 740 2760 3380]; %u

%          F1  F2  F3  F4     
bwf_fem = [110 160 210 350;  %a
            80 156 190 350;  %e
            70 130 178 350;  %i
            97 130 185 350;  %o
            74 150 210 350]; %u

save v_matrix.mat
