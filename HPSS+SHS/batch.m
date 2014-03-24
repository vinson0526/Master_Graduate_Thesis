path = 'E:/ZZZZZ/HPSS/H/';
file = dir(path);
for iter = 1 : length(file)
    if(file(iter).isdir == 0)
        SHSV2(strcat(path, file(iter).name));
    end
end
