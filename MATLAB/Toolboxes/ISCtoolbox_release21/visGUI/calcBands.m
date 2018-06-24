function band = calcBands(data,h,col)
if nargin == 3
    h=gcf;
else
    figure
    col = 'b';
end
for k = 1:size(data,1)
    subplot(5,1,k);hold on;
    for m = 1:size(data,3)
        fdata=fftshift(abs(fft(data(k,:,m),512)));
        fdata = fdata(257:end).^2;
        f = linspace(0,1/(3.4*2),length(fdata));
        fdatadB = 20*log10(fdata);
        
        Q=find(cumsum(fdata)./max(cumsum(fdata))>=0.025 & cumsum(fdata)./max(cumsum(fdata))<=0.975);
        if ~isempty(Q)
            band{k}(m,1:2) = [f(Q(1)) f(Q(end))];
            plot(f,fdata,col);
        end
    end
end
hold off;title('Frequency, Hz')