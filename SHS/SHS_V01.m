waveName = 'fdps_4_03.wav';
[x, fs] =audioread(waveName);
%x = x(:,2);
[S, F, T] =  spectrogram(x, hanning(640), 320, 2048, fs);
S = abs(S);
S = S(14:644,:);
F = F(14:644);
SS = zeros(size(S));
for iter = 1:length(T)
    [p, l] = findpeaks(S(:,iter));
    for iter2 = 1:length(l)
        SS(l(iter2),iter) = p(iter2);
    end
end
SS = SS(1:150,:);
FF = F(1:150);
SSS = SS.*SS;
for iter = 1 : length(T)
    for iter2 = 1 : length(FF)
        for iter3 = 2 : 15
            if iter3 * (iter2 + 13)<= length(F)
                SSS(iter2,iter) = SSS(iter2,iter) + 0.9^iter3 * max(S(iter3 * (iter2 + 13) - 1:iter3 * (iter2 + 13) + 1));
            end
        end
    end
end

%%%
subplot(3,1,1)
mesh(T,F,S)
view(2)
subplot(3,1,2)
mesh(T,FF,SS)
view(2)
subplot(3,1,3)
mesh(T,FF,SSS)
view(2)
%%%
out = zeros(length(T),2);
for iter = 1 : length(T)
    [p, l] = findpeaks(SSS(:,iter), 'SORTSTR','descend','NPEAKS',1);
    out(iter,1) = T(iter);
    if l(1) ~= 1 && l(1) ~= length(T)
        alpha = 20* log10(S(l(1) - 1,iter));
        beta = 20* log10(S(l(1),iter));
        gamma = 20* log10(S(l(1) + 1,iter));
        delta = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
        freq = FF(l(1)) + delta * fs / 2048;
        if freq <= 0
            freq = FF(l(1));
        end
    else
        freq = FF(l(1));
    end
    out(iter,2) = 69 + 12*log2(freq/440);
end

out2 = out(:,2);

for iter = 2 : length(out2) - 1
    if ((out2(iter) - out2(iter - 1)) > 2 && (out2(iter) - out2(iter + 1)) > 2) || ((out2(iter) - out2(iter - 1)) < -2 && (out2(iter) - out2(iter + 1)) < -2)
        out2(iter) = (out2(iter - 1) + out2(iter + 1)) / 2;
    end
end
