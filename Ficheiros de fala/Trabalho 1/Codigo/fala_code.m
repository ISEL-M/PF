clear all
close all
clc

wa = 256;
ws = 160;
pi = 20;
pf = 146;
p = 10;
treshhold = .45;
R_g=5;
R_pitch=7;

[y,Fs] = audioread('sound/car_nor.wav');

[energy, pitch, g, ak] = Info(y, wa, ws, p, pi, pf, treshhold);

sl = Vocoder(pitch, g, ak, ws, wa, p);



[td_g, tq_g] = Quantify(2, R_g);

bits = Code(g, pitch, ak, R_g, R_pitch, td_g);

saveFile(bits)


function saveFile(data)
    data_byte = [];
    for i = 1:8:length(data)
        max_i = i+7;
        if max_i>length(data)
            max_i = length(data);
        end
        byte = data(i:max_i);
        data_byte = [data_byte bi2de(byte)];
    end
    
    fileID = fopen('mp3.2.bin','w');
    fwrite(fileID, data_byte);
    fclose(fileID);
end

function [td, tq] = Quantify(max, R)
    delta = max/(2^R);
    td = (delta/2):delta:(max-delta);
    tq = delta:delta:max;
end