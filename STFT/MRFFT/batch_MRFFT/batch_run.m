waveDir = 'e:/';    %wave路径
dataDir = 'e:/'     %data输出路径
frameSize = 1024;   %窗长
isEmphasis = 0;     %是否预加重

waveFiles = dir([waveDir, '*.wav']);
waveNum = length(waveFiles);
for iter = 1:waveNum
    waveName = waveFiles(iter).name;
    wavePath = [waveDir, waveName];
    dataPath = [dataDir, waveName(1:end-4),'.dat'];
    MRFFT(wavePath, dataPath, frameSize, isEmphasis);
end