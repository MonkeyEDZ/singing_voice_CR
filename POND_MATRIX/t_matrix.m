% ESCRITURA DE t_matrix.mat
% cambiando los componentes pueden obtenerse distintos tipos de acordes
% tres tipos de matrices
%   normal = matriz de acordes simples (1 0)
%   ponderada simple = ponderada considerando imporatncia positiva del
%       acorde (relación fundamental/tercera/quinta)
%   ponderada completa = ponderada considerando interválica y notas
%       extrañas al acorde

clear
clc

% M = MATRIZ DE ACORDES MAYORES
fund = 1; % fundamental
third = 3; % tercera
fifth = 6; % quinta
j=1;
for i=1:12
% M(i)=[j-1,j+3,j+6];
M(1,i)=j-fund;
M(2,i)=j+third;
M(3,i)=j+fifth;
j=j+1;
end
% m = MATRIZ DE ACORDES menores
fund = 1; % fundamental
third = 2; % tercera
fifth = 6; % quinta
j=1;
for i=1:12
m(1,i)=j-fund;
m(2,i)=j+third;
m(3,i)=j+fifth;
j=j+1;
end
% A = MATRIZ DE ACORDES AUMENTADOS
fund = 1; % fundamental
third = 3; % tercera
fifth = 7; % quinta
j=1;
for i=1:12
A(1,i)=j-fund;
A(2,i)=j+third;
A(3,i)=j+fifth;
j=j+1;
end
% D = MATRIZ DE ACORDES DISMINUIDOS
fund = 1; % fundamental
third = 2; % tercera
fifth = 5; % quinta
j=1;
for i=1:12
D(1,i)=j-fund;
D(2,i)=j+third;
D(3,i)=j+fifth;
j=j+1;
end
%% ACOTACION DE CHROMA
for i=1:12
    for j=1:3
       if M(j,i) > 11
           M(j,i) = M(j,i) - 12;
       end
       if m(j,i) > 11
           m(j,i) = m(j,i) - 12;
       end
       if A(j,i) > 11
           A(j,i) = A(j,i) - 12;
       end
       if D(j,i) > 11
           D(j,i) = D(j,i) - 12;
       end
       j=j+1;
    end
end
%% PASO A MATRIX 12 X 12
i=1;j=1;

for i =1:12
    for j=1:3
            tM(M(j,i)+1,i) = 1;
            tm(m(j,i)+1,i) = 1;
            %tA y tD podrían reducirse ya que tienen información duplicada
            tA(A(j,i)+1,i) = 1; 
            tD(D(j,i)+1,i) = 1;
    end
end
t_mdir = 't_matrix.mat';
save(t_mdir,'tm','tM');
t_mdir = 't_matrix_full.mat';
save(t_mdir,'tm','tM','tA','tD');


k=7; %factor de ponderación
for i =1:12
    for j=1:3
            tM(M(j,i)+1,i) = k*1-j;
            tm(m(j,i)+1,i) = k*1-j;
            %tA y tD podrían reducirse ya que tienen información duplicada
            tA(A(j,i)+1,i) = k*1-j; 
            tD(D(j,i)+1,i) = k*1-j;
    end
end
t_mdir = 't_matrixP.mat';
save(t_mdir,'tm','tM');
t_mdir = 't_matrix_fullP.mat';
save(t_mdir,'tm','tM','tA','tD');

k=7; %factor de ponderación
SepM=3; % factor de pond. negativo de 7 Maj
% dejo misma ponderación de septima para acordes mayores y menores??
Tdes=2; % factor de pond. negativo de 3a "desafinada"
for i =1:12    
        for j=1:3
            tM(M(j,i)+1,i) = k*1-j;
            tm(m(j,i)+1,i) = k*1-j;
            if j==1
                if M(j,i)==0 
                    tM(M(j,i)+12,i) = -SepM;                
                    tm(m(j,i)+12,i) = -SepM;
                else
                    tM(M(j,i),i) = -SepM;
                    tm(m(j,i),i) = -SepM;
                end
            elseif j==2
                if M(j,i)==0 
                    tM(M(j,i)+12,i) = -Tdes;
                    tm(m(j,i)+2,i) = -Tdes;
                 elseif m(j,i)==0
                    tm(m(j,i)+2,i) = -Tdes;
                    tM(M(j,i),i) = -Tdes;
                else
                    tM(M(j,i),i) = -Tdes;
                    tm(m(j,i)+2,i) = -Tdes;
                end              
            end
            %tA y tD podrían reducirse ya que tienen información duplicada
            tA(A(j,i)+1,i) = k*1-j; 
            tD(D(j,i)+1,i) = k*1-j;
        end    
end
tm(1,:)=tm(1,:)+tm(13,:);
tm=tm(1:12,:);

t_mdir = 't_matrixC.mat';
save(t_mdir,'tm','tM');
t_mdir = 't_matrix_fullC.mat';
save(t_mdir,'tm','tM','tA','tD');
