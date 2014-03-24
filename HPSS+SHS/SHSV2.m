function [ out ] = SHSV2( fileName )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
pointNum = 1024;

%[x, fs] =audioread(waveName);
%x = x(:,2);
%[S, F, T] =  spectrogram(x, hanning(640), 320, pointNum, fs);
S = load(fileName);
S = S';
fs = 16000;
F = linspace(0,8000,pointNum /2 + 1);
lowBound = floor(80 * pointNum / fs);
upBound = ceil(5000 * pointNum / fs);
speechBound = ceil(1000 * pointNum / fs);
S = S(lowBound:upBound,:);
F = F(lowBound:upBound);
SS = zeros(size(S));
for iter = 1:size(S,2)
    [p, l] = findpeaks(S(:,iter));
    for iter2 = 1:length(l)
        SS(l(iter2),iter) = p(iter2);
    end
end
SS = SS(1:speechBound,:);
FF = F(1:speechBound);
SSS = SS.*SS; %平方之后取峰值，然后加和没有平方的，这样做？？？
for iter = 1 : size(S,2)
    for iter2 = 1 : length(FF)
        for iter3 = 2 : 15
            if iter3 * (iter2 + lowBound - 1)<= length(F)
                SSS(iter2,iter) = SSS(iter2,iter) + 0.9^iter3 * max(S(iter3 * (iter2 + lowBound - 1) - 1:iter3 * (iter2 + lowBound - 1) + 1));
            end
        end
    end
end

%%%
% subplot(3,1,1)
% mesh(T,F,S)
% view(2)
% subplot(3,1,2)
% mesh(T,FF,SS)
% view(2)
% subplot(3,1,3)
% mesh(T,FF,SSS)
% view(2)
%%%
out = zeros(size(S, 2),1);
for iter = 1 : size(S,2)
    [~, l] = findpeaks(SSS(:,iter), 'SORTSTR','descend','NPEAKS',1);
    if l(1) ~= 1 && l(1) ~= size(S,2)
        alpha = 20* log10(S(l(1) - 1,iter));
        beta = 20* log10(S(l(1),iter));
        gamma = 20* log10(S(l(1) + 1,iter));
        delta = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
        freq = FF(l(1)) + delta * fs / pointNum;
    else
        freq = FF(l(1));
    end
    out(iter) = 69 + 12*log2(freq/440);
end

out2 = out;


%smooth 
for iter = 2 : length(out2) - 1
    if ((out2(iter) - out2(iter - 1)) > 2 && (out2(iter) - out2(iter + 1)) > 2) || ((out2(iter) - out2(iter - 1)) < -2 && (out2(iter) - out2(iter + 1)) < -2)
        out2(iter) = (out2(iter - 1) + out2(iter + 1)) / 2;
    end
end

%saveFile
splash = strfind(fileName, '/');
if isempty(splash)
    splash = strfind(fileName, '\');
end
outFile = ['track/',fileName(splash(length(splash)) + 1:length(fileName)), '.pv'];
dlmwrite(outFile, out2,'delimiter', '\t', 'precision', 5);
end

