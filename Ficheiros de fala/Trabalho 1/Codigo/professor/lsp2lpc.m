function ar=lsp2lpc(ls)
[nf,p]=size(ls);
p1=p+1;
p2 = p1*2;
ar=zeros(nf,p1);
for k=1:nf
    le=exp(ls(k,:)*pi*2i);
    lf=[1 le -1 conj(fliplr(le))];
    y=real(poly(lf(1:2:p2)));
    x=real(poly(lf(2:2:p2)));
    ar(k,:)=(x(1:p1)+y(1:p1))/2;
end
%ar=ar(2:end);