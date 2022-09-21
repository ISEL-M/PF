function [sl] = Vocoder(pitch, g, ak, ws, wa, p)
    sizei = ws;
    size = ws;
    zi = zeros(1, p);
    sl = [];
    last = zeros(1, size);
    last_gl = 0;
    for i = 1:length(pitch)
        gl = 0;
        if pitch(i) == 0
            ruido = zeros(1, size);
            ruido = awgn(ruido, 50);
            
            if size~=sizei
                size = sizei;
            end
            
            gl = g(i)*sqrt(1/wa);
            
            s = ruido * gl;
        
            sl = [sl s];
        else
            pulsoGlotal = PulsoGlotal(pitch(i));
            
            repeat = ceil(size/pitch(i));
            
            actualSize = repeat * pitch(i);
            extra = actualSize - size;
            size = sizei - extra;
            
            for j = 1:repeat
                gl = g(i)*sqrt(pitch(i)/wa);
                gl = (last_gl * (repeat-j) + gl * j)/repeat;
                last_gl = gl;
                
                s = pulsoGlotal * gl;
                [last, zi] = filter(1, [1 ak(:, i)'], s, zi);
                sl = [sl last];
            end
        end
% 
%         [last, zi] = filter(gl, [1 ak(i)'], aux, zi);
    end
end

function [pulso] = PulsoGlotal(pitch)
    p = ceil(pitch*.66);
    pulso = zeros(1,pitch);
    for i = 1: p+1
        a = (2 * p - 1) * i  - (3 * i^2);
        b = p ^ 2 - 3 * i + 2;
        pulso(i) = a/b;
    end
end

