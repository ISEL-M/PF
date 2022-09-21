function [x2, x3, e] = myautocorr(x, w, kl)
    
    x2 = zeros(kl,1);
    for k = 1 : kl
        for n = k : w
            x2(k) = x2(k) + (x(n)*x(n-k + 1));
        end
    end
    x3 = x2/x2(1);
    e = x2(1);
    
end

