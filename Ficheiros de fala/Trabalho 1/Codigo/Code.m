function [bits] = Code(g, pitch, ak, R_g, R_pitch, td_g)

    max_g = max(g);
    
    bits=[];
    for i=1:length(g)
        %G
        idx = quantiz(g(i), td_g);
        g_bit = de2bi(idx, R_g);
        
        %pitch
        aux=pitch(i)-19;
        aux = max(aux,0);
        pitch_bit = de2bi(aux, R_pitch);
        
        %ak
        lsp = lpc2lsp([1 ak(:, i)']);
        ak_bit = code_lsp(lsp);
        
        bits = [bits g_bit];
        bits = [bits pitch_bit];
        bits = [bits ak_bit];
    end
end

