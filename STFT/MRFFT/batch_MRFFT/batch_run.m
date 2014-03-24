waveDir = 'e:/';    %wave·��
dataDir = 'e:/'     %data���·��
frameSize = 1024;   %����
isEmphasis = 0;     %�Ƿ�Ԥ����

waveFiles = dir([waveDir, '*.wav']);
waveNum = length(waveFiles);
for iter = 1:waveNum
    waveName = waveFiles(iter).name;
    wavePath = [waveDir, waveName];
    dataPath = [dataDir, waveName(1:end-4),'.dat'];
    MRFFT(wavePath, dataPath, frameSize, isEmphasis);
end