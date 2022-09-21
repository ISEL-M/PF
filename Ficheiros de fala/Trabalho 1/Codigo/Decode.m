function [g, pitch, ak] = Decode(bits, tq_g)
    R_g=5;
    R_pitch=7;
    R_ak=34;
    
    g = [];
    pitch = [];
    ak = [];

     for i = 1 : 46:length(bits)
        start_pitch = i + R_g;
        start_ak = start_pitch + R_pitch;
        end_ak = start_ak + R_ak;


        g_bits = bits(i:start_pitch-1);
        pitch_bits = bits(start_pitch:start_ak-1);
        ak_bits = bits(start_ak:end_ak-1);

        %G
        g_idx = bi2de(g_bits);
        %new_g = quantiz(g_idx, tq_g);
        new_g = tq_g(g_idx+1);
        g = [g new_g];

        %pitch
        new_pitch = bi2de(pitch_bits);
        new_pitch = new_pitch + 19;
        pitch = [pitch new_pitch];

        %ak
        lsp = decode_lsp(ak_bits);
        new_ak = lsp2lpc(lsp);
        ak = [ak [new_ak(2:end)]'];
     end
    pitch(pitch==19) = 0;
end

