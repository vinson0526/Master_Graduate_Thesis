path = 'E:/wave/';
file = dir(strcat('E:/wave/', '*.wav'));
for iter = 1 : length(file)
    out_file = file.name(1:length(file.name) - 4);
    SHSV1(strcat(path, file(iter).name), strcat(path, out_file));
end
