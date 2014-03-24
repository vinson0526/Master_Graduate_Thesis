path = 'E:/wave/';
file = dir(strcat('E:/wave/', '*.wav'));
for iter = 1 : length(file)
    SHSV1(strcat(path, file(iter).name));
end
