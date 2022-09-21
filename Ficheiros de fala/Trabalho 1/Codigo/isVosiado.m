function [vosiado, val] = isVosiado(x, pi, pf, treshhold)
    start = 20; 
    val = 0;
    vosiado = false;

    aux = x(pi:pf);
    [max_val, idx] = maxk(aux,3);
    idx = min(idx);
    if aux(idx) >= treshhold
        vosiado = true;
        val = find(x == aux(idx));
    end
end

