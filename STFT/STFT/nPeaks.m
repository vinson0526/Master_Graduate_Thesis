function [P, L] = nPeaks(waveName, distence, nNum, PFile, Lfile)

%read wave
[x, fs] =audioread(waveName);
x = x(:,2);
[S, F, T] =  spectrogram(x, hanning(640), 320, 1024, fs);
S = abs(S);
%S = S(1:512,:);

%get nNum max values
P = zeros(nNum, length(T));
L = zeros(nNum, length(T));

for iter = 1 : length(T)
    [p, l] = findpeaks(S(:,iter), 'MINPEAKDISTANCE',distence,'SORTSTR','descend','NPEAKS',nNum);
    if ~isempty(p) && length(p) == nNum
        P(:,iter) = p;
        L(:,iter) = l;
    else%deal with peaks not enough to nNum
        if ~isempty(p)
            for iter2 = 1 : length(p)
                 P(iter2,iter) = p(iter2);
                 L(iter2,iter) = l(iter2);
            end
        end
    end
    for iter3 = 1:nNum
        if L(iter3, iter) ~= 0
            L(iter3, iter) = F(L(iter3, iter));
        end
    end
end

%normalize L
L = bsxfun(@rdivide, L, fs / 2);
P = P';
L = L';

save(PFile, 'nNum', 'P', '-ascii')
save(Lfile, 'nNum', 'L', '-ascii')

end
