%调用nPeaks.m文件
%使用时修改第5行，第11行路径，共修改3处路径
clear
clc
Files = dir(fullfile('H:\\data\\unlabel\\wav\\','*.wav'));
LengthFiles = length(Files);
for i=1:LengthFiles;
    temp=regexp(Files(i).name,'.','split');
    t= strrep(Files(i).name,'.wav','');
    fprintf('%s\n',t);
    y=nPeaks(strcat('H:\data\unlabel\wav\',Files(i).name),5,10,strcat('H:\data\unlabel\P\',t),strcat('H:\data\unlabel\L\',t));
end
fprintf('%d',LengthFiles);