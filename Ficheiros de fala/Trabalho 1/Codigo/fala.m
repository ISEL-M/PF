clear all
close all
clc

wa = 256;
ws = 160;
mi = 1000;
pi = 20;
pf = 146;
p = 10;
treshhold = .4;
R_g=5;
R_pitch=7;

[y,Fs] = audioread('sound/car_nor.wav');


% y = y(mi:mi+wa);
% figure;
% plot(y);
% 
% 
% sound(y,Fs)
% [y2, e] = myautocorr(y, wa, kl);
% [vosiado, val] = isVosiado(y2,treshhold);
% figure;
% plot(y2);
% legend("y2","y3");
% sound(y2)



% figure('Name','Original Signal');
% plot(y);
[energy, pitch, g, ak] = Info(y, wa, ws, p, pi, pf, treshhold);
% figure('Name','Energy');
% plot(energy)
% figure('Name','Pitch');
% plot(pitch)
% 
% figure('Name',"G and G'");
% plot(g)
% hold;
% plot(gl)

sl = Vocoder(pitch, g, ak, ws, wa, p);
% sound(y);
% sound(sl);
% 
% figure;
% plot(y);
% hold;
% plot(sl);

[td_g, tq_g] = Quantify(max(g), R_g);

bits = Code(g, pitch, ak, R_g, R_pitch, td_g);
[g2, pitch2, ak2] = Decode(bits, tq_g);

sl = Vocoder(pitch2, g2, ak2, ws, wa, p);
% sound(y);
sound(sl);
% 
% figure;
% plot(y);
% hold;
% plot(sl);

function [td, tq] = Quantify(max, R)
        delta = max/(2^R);
        td = (delta/2):delta:(max-delta);
        tq = delta:delta:max;
end