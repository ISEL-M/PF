function [energy, pitch, g, ak] = Info(x, wa, ws, p, pi, pf, tresh)
    pitch = [];
    energy = [];
    g = [];
%     gl = [];
    ak = [];
    w = wa;
    for start_x = 1 : ws : length(x)
        close all
        end_x = start_x + wa -1;
        if end_x > length(x)
            break
        end
        
        aux1 = x(start_x:end_x);
%         figure("Name", "Sound");
%         subplot(311); plot(aux1); title("Signal Original");
        
        aux1 =  aux1 - mean(x);
%         subplot(312); plot(aux1); title("Sem Média");
        
        aux = aux1 .* hamming(wa);
%         subplot(313); plot(aux); title("Hamming");

        [x2, x3, e] = myautocorr(aux, length(aux1), pf);
        energy = [energy e];
        
       
        
        if e > 0.001
            [vosiado, val] = isVosiado(x3, pi, pf, tresh);
            pitch = [pitch val(1)];
        else
            pitch = [pitch 0];
        end
        
        
        if pitch(end)~=0
            aux = aux(2:end)-0.95*aux(1:end-1);
            [x2,x3,E] = myautocorr(aux, length(aux), pf);
        end
        
        
        for i = 2 : length(pitch)-1
            if pitch(i-1)~=0 && pitch(i+1)~=0 && pitch(i)==0
                pitch(i)= (pitch(i+1)+pitch(i-1))/2;
            end
            if pitch(i-1)==0 && pitch(i+1)==0 && pitch(i)~=0
                pitch(i)= (pitch(i+1)+pitch(i-1))/2;
            end
        end
        pitch = round(pitch);
        
        
        t = toeplitz(x3(1:p));
        t2 = inv(t);
        
        a = -t2 * x3(2:p+1);
        ak = [ak [a]];


        new_g = x2(1);
        for i = 1 : p
            new_g = new_g + a(i)*x2(i+1);
        end
        new_g = sqrt(new_g);
        g = [g new_g];
        
        
%         if pitch(end)~=0
%             new_gl = new_g * sqrt(pitch(end)/wa);
%             gl = [gl new_gl];
%         else
%             gl = [gl new_g];
%         end
        
        dirac = zeros(512);
        dirac(1) = 1;
        
        y = filter(g(end),[1 a'],dirac);
        [y2, y3, e] = myautocorr(y, length(y), pf);

        Y = abs(fft(y3,512));
        Y = Y(1:end/2);
        Y_db = db (Y);

        X = abs(fft(x3,512));
        X = X(1:end/2);
        X_db = db(X);
        
%         if start_x >=1000
%             figure('Name',"Periodograma e Autocorrelação");
%             subplot(211);plot(X_db); hold; plot(Y_db);
%             title("Periodogramas");
%             xlabel("f [KHz]"); ylabel("Periodograma [dB]");
%             legend("sinal de Entrada", "resposta do filtro");
%             
%             subplot(212); plot(x3); hold; plot(y3);
%             title("Autocorrelação");
%             xlabel(" t[ms]"); ylabel("r(k)");
%             legend("sinal de Entrada", "resposta do filtro");
%             Y=Y;
%         end

        
    end
end

