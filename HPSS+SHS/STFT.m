files = dir(fullfile('E:\\\ZZZZZ\\\wave\\','*.wav'));
LengthFiles = length(files);

for i=1:LengthFiles;
	[x, fs] = audioread(['E:\\ZZZZZ\\wave\\', files(i).name]);
	[S, F, T] = spectrogram(x,hanning(640), 320, 1024, fs);
	S = abs(S);
	S = S';
    k = size(F,1);
	
	t = strrep(files(i).name,'.wav','');
	dlmwrite(['E:\\ZZZZZ\\STFT\\', t] , S,'delimiter', '\t', 'precision', 5);
end