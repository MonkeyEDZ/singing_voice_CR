function [ formants,formantsW,est_x,est_f,dw,dwf] = LPC_paso(n,x0,fs,minf,bwf,W)
%LPC - Función LPC calculada por intervalos cortos
% 
%INPUT:
%       n = cantidad de coeficientes del filtro buscados 
%       x0 = audio original post divisòn en pasos
%       fs = frecuencia de sampleo
%       minf = frecuencia mínima de análisis
%       bwf = ancho de banda mínimo para lpc
%       W = selecciòn de tipo de análisis W-LPC
%
%OUTPUT:
%       formants = formantes obtenidas por LPC clásico
%       est_x = archivo temporal completo (LPC)
%       est_f = archivo temporal sólo con formantes (LPC)
%       dw = archivo temporal completo (W-LPC)
%       dwf = archivo temporal sólo con formantes (W-LPC)
%
%FUNCIONES UTILIZADAS DE LA TOOLBOX 
% Spectral Warping of LPC resonance models : https://labrosa.ee.columbia.edu/matlab/polewarp/
% lpcfit lpcsynth warppoles
%
formants=zeros(1,4);
formantsW=zeros(1,4);

%% LPC
% n=5 % cambian coeficientes del filtro buscados

preemph = [1 0.63];
x1 = filter(1,preemph,x0);
% plot(x0(:,1),'r'),hold,plot(x1(:,1),'b');

A = lpc(x1,2+n*2);
rts = roots(A);

rts_v = rts(imag(rts)>=0);
r_angz=abs(rts_v);
angz = atan2(imag(rts_v),real(rts_v));
angz_fs=angz.*(fs/(2*pi));
[frqs,indices] = sort(angz_fs);
bw = -1/2*(fs/(2*pi))*log(abs(rts_v(indices)));

nn = 1;
for kk = 1:length(frqs)
    if (frqs(kk) > minf && bw(kk) <bwf)
        formants(nn) = frqs(kk);
        kkf(nn)=kk;
        nn = nn+1;
    end
end
formants=formants(1:4);

[~,i_formants] = ismember(formants(formants>0),frqs);
theta_f=angz(i_formants); %ángulo de formantes
r_f=r_angz(i_formants); %radio de formants
f_formants=r_f.*exp(1i*theta_f);
f_LPC=poly(f_formants);
%% warped LPC

nho=n*2; % Fit the original LPC model (high-order)

if strcmp(W,'classic')==1
    [a] = lpc(x1,2+nho*2); % uso versión con pre-emphasis  y análisis clásico
    % Warp the poles up a little
    % (warppoles modifies every frame - rows of a - at the same time)
    alpha = 0.47;
    [bhat, ahat]  = warppoles(a, alpha);
    % Resynthesize with the new LPC
    dw = filter(1,bhat(1,:),x0);
else
    [a,g,e] = lpcfit(x0,2+nho*2); % uso versión sin pre-emphasis
    % Warp the poles up
    alpha = 0.47;
    [bhat, ahat]  = warppoles(a, alpha);
    % Resynthesize with the new LPC
    dw = filter(bhat(1,:), 1, lpcsynth(ahat, g, e));
end

% % [a,g,e] = lpcfit(x0,2+n*2); % uso versión sin pre-emphasis
% [a] = lpc(x1,2+n*2); % uso versión con pre-emphasis  y análisis clásico
% 
% Warp the poles up (warppoles modifies every frame at the same time)
% alpha = 0.47;
% [bhat, ahat]  = warppoles(a, alpha);

% Resynthesize with the new LPC -(bhat is the same for all frames)
% % dw = filter(bhat(1,:), 1, lpcsynth(ahat, g, e));
% dw = filter(1,bhat(1,:),x0);

% formantes desde W-LPC
rts = roots(a(1,:));
rts_v = rts(imag(rts)>=0);
r_angz=abs(rts_v);
angz = atan2(imag(rts_v),real(rts_v));
angz_fs=angz.*(fs/(2*pi));
[frqs,indices] = sort(angz_fs);
bw = -1/2*(fs/(2*pi))*log(abs(rts_v(indices)));

nn = 1;
for kk = 1:length(frqs)
    if (frqs(kk) > 50 && bw(kk) <700)
        formantsW(nn) = frqs(kk);
        kkf(nn)=kk;
        nn = nn+1;
    end
end
formantsW=formantsW(1:4);

[~,i_formantsW] = ismember(formantsW,frqs);
theta_f=angz(i_formantsW); %ángulo de formantes
r_f=r_angz(i_formantsW); %radio de formants
f_formantsW=r_f.*exp(1i*theta_f);
f_WLPC=poly(f_formantsW);
%% LPC analisis
%CHEQUEAR SIN LOS VALORES CON POLOS O RAICES DEL FILTRO

%LPC completo
% a=[0 -A(2:end)]; 
b=1;
est_x = filter(b,A,x0);

% LPC plot(sólo formantes)
b=1;
% est_f = real(filter(b,f_LPC,f_audio)); %dejo sólo la parte real del filtro
est_f = filter(b,f_LPC,x0); 

% % WLPC plot(sólo formantes)
b=1;
% est_f = real(filter(b,f_LPC,f_audio)); %dejo sólo la parte real del filtro
dwf = filter(b,f_WLPC,x0); 


end

