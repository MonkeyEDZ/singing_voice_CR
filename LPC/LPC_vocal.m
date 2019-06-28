function [ mfWv,stdfWv ] = LPC_vocal( formantsW, vocal, sexo )
%LPC_vocal - función de filtrado de LPC según vocal seleccionada
%INPUT:
%   vocal = elección de vocal analizada (a,e,i,o,u)
%   formantsW = lista completa de formantes (Warped-LPC)
%   sexo = sexo mayoritario de cantantes
%
%OUTPUT:
%   mfWv = promedio de formantes filtrado por vocal
%   stdfWv= desviación estándar de formantes filtrado por vocal 

%% promediado con consideraciones de idioma (limitando rango de búsqueda)

% cargo matriz prediseñada
load v_matrix 

if strcmp(sexo ,'fem')
    v_f = vf_fem(:,2:5); % quito columna de F0
    v_bwf = bwf_fem;
else
    v_f = vf_masc(:,2:5); % quito columna de F0
    v_bwf = bwf_masc;
end

%establezco valores superiores e inferiores para promedio de formantes
v_fmax=v_f+v_bwf;
v_fmin=v_f-v_bwf;

%% filtrado según vocal seleccionada
if strcmp(vocal,'a')
    for f=1:4   
     vf_F=formantsW(:,f);
     fW=vf_F(vf_F<v_fmax(1,f) & vf_F>v_fmin(1,f));
     mfWv(f)=mean(fW);
     stdfWv(f)=std(fW);  
    end
elseif strcmp(vocal,'e')
    for f=1:4   
     vf_F=formantsW(:,f);
     fW=vf_F(vf_F<v_fmax(2,f) & vf_F>v_fmin(2,f));
     mfWv(f)=mean(fW);
     stdfWv(f)=std(fW);  
    end    
elseif strcmp(vocal,'i')
    for f=1:4   
     vf_F=formantsW(:,f);
     fW=vf_F(vf_F<v_fmax(3,f) & vf_F>v_fmin(3,f));
     mfWv(f)=mean(fW);
     stdfWv(f)=std(fW);  
    end
elseif strcmp(vocal,'o')
    for f=1:4   
     vf_F=formantsW(:,f);
     fW=vf_F(vf_F<v_fmax(4,f) & vf_F>v_fmin(4,f));
     mfWv(f)=mean(fW);
     stdfWv(f)=std(fW);  
    end
elseif strcmp(vocal,'u')
    for f=1:4   
     vf_F=formantsW(:,f);
     fW=vf_F(vf_F<v_fmax(5,f) & vf_F>v_fmin(5,f));
     mfWv(f)=mean(fW);
     stdfWv(f)=std(fW);  
    end       
else
    mfWv=mean(formantsW);
    stdfWv=std(formantsW);
end

end

