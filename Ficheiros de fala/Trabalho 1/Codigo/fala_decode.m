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

[td_g, tq_g] = Quantify(2, R_g);

bits = loadFile();
[g2, pitch2, ak2] = Decode(bits, tq_g);

sl = Vocoder(pitch2, g2, ak2, ws, wa, p);
sound(sl);


function [data] = loadFile()
    fileID = fopen('mp3.2.bin');
    data_byte = fread(fileID)';
    fclose(fileID);
    
    data = [];
    for i = 1:length(data_byte)
        byte = data_byte(i);
        if length(data_byte) == i
            
            byte = de2bi(byte,2);
        else
            byte = de2bi(byte,8);
        end
        data = [data, byte];
    end
end

function [td, tq] = Quantify(max, R)
        delta = max/(2^R);
        td = (delta/2):delta:(max-delta);
        tq = delta:delta:max;
end