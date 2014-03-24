wav_Name = 'e:\\test.wav';
n_Max = 20;
[x,fs] =audioread(wav_Name);
x = x(:,2);
[S F T] =  spectrogram(x,hanning(640), 320, 1024, fs);
S = abs(S);
%S = S(1:512,:);

P = zeros(n_Max, length(T));
L = zeros(n_Max, length(T));

for iter = 1 : length(T)
    [p, l] = findpeaks(S(:,iter), 'MINPEAKDISTANCE',5,'SORTSTR','descend','NPEAKS',n_Max);
    if ~isempty(p) && length(p) == n_Max
        P(:,iter) = p;
        L(:,iter) = l;
    else
        if isempty(p)
        else
            for iter2 = 1 : length(p)
                 P(iter2,iter) = p(iter2);
                 L(iter2,iter) = l(iter2);
            end
        end
    end
    for iter3 = 1:n_Max
        if L(iter3, iter) ~= 0
            L(iter3, iter) = F(L(iter3, iter));
        end
    end
end

L = bsxfun(@rdivide, L, fs / 2);

L = L';
P = P';

save('PFile', 'n_Max', 'P', '-ascii')
save('Lfile', 'n_Max', 'L', '-ascii')