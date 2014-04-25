wav_path = 'E:/ZZZZZ/wave/';
out_path1 = 'E:/ZZZZZ/SHSV3/';
out_path2 = 'E:/ZZZZZ/SHSV4/';
out_path3 = 'E:/test/SHSV5/';
file = dir(strcat(wav_path, '*.wav'));
for iter = 1 : length(file)
    iter
    out_file = file(iter).name(1:length(file(iter).name) - 4);
    out_file = strcat(out_file, '.pv');
    SHSV3(strcat(wav_path, file(iter).name), strcat(out_path1, out_file));
    SHSV4(strcat(wav_path, file(iter).name), strcat(out_path2, out_file));
    %SHSV5(strcat(wav_path, file(iter).name), strcat(out_path3, out_file));
end
