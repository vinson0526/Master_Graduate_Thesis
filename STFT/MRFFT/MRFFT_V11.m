%读取wave文件，设置一小帧的长度
wav_Name = 'e:\\test.wav';
[x,fs] =audioread(wav_Name);
if fs == 16000
    N = 128;
else
    N = 64;
end

%M:点数,M2点数的一半
M = 16 * N;
M2 = M / 2;

%设置高中低频率线
level_1 = floor(double(630) / fs * M);
level_2 = floor(double(1720) / fs * M);
level_3 = floor(double(3700) / fs * M);

%设置窗函数参数
hamming_A0 = 0.53836;
hamming_A1 = -0.46164 / 2;


%获取总共的点数，计算需要的帧数，创建存储频谱的矩阵
[x_Row,x_Column] = size(x);
frame_Num = ceil(double(x_Row) / N);
F_Temp = zeros(M,frame_Num); %存储傅立叶变换后的矩阵
%F = zeros(M2,frame_Num);

%获取小帧的FFT，存储在F里
x1 = x(:,1);
if x_Column == 2
    x1 = x(:,2);
end

%预加重
%x1=filter([1 -0.9495],1,x1);
for iter = 1:frame_Num - 1
    F_Temp(:,iter) = fft(x1(1 + (iter - 1)*N : iter*N),M);
end
F_Temp(:,frame_Num) = fft(x1(1 + (frame_Num - 1)*N : x_Row),M);

F = F_Temp(1:M2,:); %保留有用的点
%第一步变换完成
[F_Row,F_Column] = size(F);

%分成四块矩阵分别处理
F1 = F(1:level_1,:);            %低频
F2 = F(level_1 + 1:level_2,:);  %中低频
F3 = F(level_2 + 1:level_3,:);  %中高频
F4 = F(level_3 + 1:M2,:);       %高频

%不同分辨率的工作，高频最大时间分辨率，低频最大频率分辨率
%F4
%构造初等变换矩阵
[F4_Row,F4_Column] = size(F4);
trans_Matrix_F4 = zeros(F4_Row,F4_Row);
for iter = 1:F4_Row
    trans_Matrix_F4(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)/M);
end
trans_Matrix_F4 = trans_Matrix_F4 * F4;  %位移N
%与F4_0对齐
trans_Matrix_F4(:,1) = [];
trans_Matrix_F4(:,F4_Column) = 0;
%生成未加窗的矩阵
trans_Matrix_F4 = trans_Matrix_F4 + F4;
%窗
window = zeros(F4_Row,F4_Row);
for iter = 1:F4_Row
    window(iter,iter) = hamming_A0;
end
for iter = 1:F4_Row - M/2/N
    window(iter,iter + M/2/N) = hamming_A1;
    window(iter + M/2/N,iter) = hamming_A1;
end
%加窗
trans_Matrix_F4 = abs(window * trans_Matrix_F4);

%F3
%构造初等变换矩阵
[F3_Row,F3_Column] = size(F3);
trans_Matrix_F3_0 = zeros(F3_Row,F3_Row);
trans_Matrix_F3_1 = zeros(F3_Row,F3_Row);
trans_Matrix_F3_2 = zeros(F3_Row,F3_Row);
trans_Matrix_F3_3 = zeros(F3_Row,F3_Row);
for iter = 1:F3_Row
    trans_Matrix_F3_0(iter,iter) = 1;
    trans_Matrix_F3_1(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)/M);
    trans_Matrix_F3_2(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*2/M);
    trans_Matrix_F3_3(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*3/M);
end
trans_Matrix_F3_0 = trans_Matrix_F3_0 * F3; %原始
trans_Matrix_F3_1 = trans_Matrix_F3_1 * F3; %位移N
trans_Matrix_F3_2 = trans_Matrix_F3_2 * F3; %位移2N
trans_Matrix_F3_3 = trans_Matrix_F3_3 * F3; %位移3N
%与F3_1对齐
trans_Matrix_F3_0(:,F3_Column) = [];
trans_Matrix_F3_0 = [zeros(F3_Row,1),trans_Matrix_F3_0];

trans_Matrix_F3_2(:,1) = [];
trans_Matrix_F3_2(:,F3_Column) = 0;

trans_Matrix_F3_3(:,1:2) = [];
trans_Matrix_F3_3(:,F3_Column -1 : F3_Column) = 0;

%生成未加窗的矩阵
trans_Matrix_F3 = trans_Matrix_F3_0 + trans_Matrix_F3_1 + trans_Matrix_F3_2 + trans_Matrix_F3_3;
%窗
window = zeros(F3_Row,F3_Row);
for iter = 1:F3_Row
    window(iter,iter) = hamming_A0;
end
for iter = 1:F3_Row - M/4/N
    window(iter,iter + M/4/N) = hamming_A1;
    window(iter + M/4/N,iter) = hamming_A1;
end
%加窗
trans_Matrix_F3 = abs(window * trans_Matrix_F3);

%F2
%构造初等变换矩阵
[F2_Row,F2_Column] = size(F2);
trans_Matrix_F2_0 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_1 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_2 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_3 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_4 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_5 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_6 = zeros(F2_Row,F2_Row);
trans_Matrix_F2_7 = zeros(F2_Row,F2_Row);
for iter = 1:F2_Row
    trans_Matrix_F2_0(iter,iter) = 1;
    trans_Matrix_F2_1(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)/M);
    trans_Matrix_F2_2(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*2/M);
    trans_Matrix_F2_3(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*3/M);
    trans_Matrix_F2_4(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*4/M);
    trans_Matrix_F2_5(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*5/M);
    trans_Matrix_F2_6(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*6/M);
    trans_Matrix_F2_7(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*7/M);
end
trans_Matrix_F2_0 = trans_Matrix_F2_0 * F2; %原始
trans_Matrix_F2_1 = trans_Matrix_F2_1 * F2; %位移N
trans_Matrix_F2_2 = trans_Matrix_F2_2 * F2; %位移2N
trans_Matrix_F2_3 = trans_Matrix_F2_3 * F2; %位移3N
trans_Matrix_F2_4 = trans_Matrix_F2_4 * F2; %位移4N
trans_Matrix_F2_5 = trans_Matrix_F2_5 * F2; %位移5N
trans_Matrix_F2_6 = trans_Matrix_F2_6 * F2; %位移6N
trans_Matrix_F2_7 = trans_Matrix_F2_7 * F2; %位移7N
%与F2_3对齐
trans_Matrix_F2_0(:,F2_Column - 2 : F2_Column) = [];
trans_Matrix_F2_0 = [zeros(F2_Row,3),trans_Matrix_F2_0];

trans_Matrix_F2_1(:,F2_Column - 1 : F2_Column) = [];
trans_Matrix_F2_1 = [zeros(F2_Row,2),trans_Matrix_F2_1];

trans_Matrix_F2_2(:,F2_Column) = [];
trans_Matrix_F2_2 = [zeros(F2_Row,1),trans_Matrix_F2_2];

trans_Matrix_F2_4(:,1) = [];
trans_Matrix_F2_4(:,F2_Column) = 0;

trans_Matrix_F2_5(:,1:2) = [];
trans_Matrix_F2_5(:,F2_Column - 1 : F2_Column) = 0;

trans_Matrix_F2_6(:,1:3) = [];
trans_Matrix_F2_6(:,F2_Column - 2 : F2_Column) = 0;

trans_Matrix_F2_7(:,1:4) = [];
trans_Matrix_F2_7(:,F2_Column - 3 : F2_Column) = 0;

%生成未加窗的矩阵
trans_Matrix_F2 = trans_Matrix_F2_0 + trans_Matrix_F2_1 + trans_Matrix_F2_2 + trans_Matrix_F2_3 + trans_Matrix_F2_4 + trans_Matrix_F2_5 + trans_Matrix_F2_6 + trans_Matrix_F2_7;
%窗
window = zeros(F2_Row,F2_Row);
for iter = 1:F2_Row
    window(iter,iter) = hamming_A0;
end
for iter = 1:F2_Row - M/8/N
    window(iter,iter + M/8/N) = hamming_A1;
    window(iter + M/8/N,iter) = hamming_A1;
end
%加窗
trans_Matrix_F2 = abs(window * trans_Matrix_F2);

%F1
%构造初等变换矩阵
[F1_Row,F1_Column] = size(F1);
trans_Matrix_F1_0 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_1 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_2 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_3 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_4 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_5 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_6 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_7 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_8 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_9 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_10 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_11 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_12 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_13 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_14 = zeros(F1_Row,F1_Row);
trans_Matrix_F1_15 = zeros(F1_Row,F1_Row);
for iter = 1:F1_Row
    trans_Matrix_F1_0(iter,iter) = 1;
    trans_Matrix_F1_1(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)/M);
    trans_Matrix_F1_2(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*2/M);
    trans_Matrix_F1_3(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*3/M);
    trans_Matrix_F1_4(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*4/M);
    trans_Matrix_F1_5(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*5/M);
    trans_Matrix_F1_6(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*6/M);
    trans_Matrix_F1_7(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*7/M);
    trans_Matrix_F1_8(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*8/M);
    trans_Matrix_F1_9(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*9/M);
    trans_Matrix_F1_10(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*10/M);
    trans_Matrix_F1_11(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*11/M);
    trans_Matrix_F1_12(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*12/M);
    trans_Matrix_F1_13(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*13/M);
    trans_Matrix_F1_14(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*14/M);
    trans_Matrix_F1_15(iter,iter) = exp(-1i*2*pi*(iter-1)*(N-1)*15/M);
end
trans_Matrix_F1_0 = trans_Matrix_F1_0 * F1; %原始
trans_Matrix_F1_1 = trans_Matrix_F1_1 * F1; %位移N
trans_Matrix_F1_2 = trans_Matrix_F1_2 * F1; %位移2N
trans_Matrix_F1_3 = trans_Matrix_F1_3 * F1; %位移3N
trans_Matrix_F1_4 = trans_Matrix_F1_4 * F1; %位移4N
trans_Matrix_F1_5 = trans_Matrix_F1_5 * F1; %位移5N
trans_Matrix_F1_6 = trans_Matrix_F1_6 * F1; %位移6N
trans_Matrix_F1_7 = trans_Matrix_F1_7 * F1; %位移7N
trans_Matrix_F1_8 = trans_Matrix_F1_8 * F1; %位移8N
trans_Matrix_F1_9 = trans_Matrix_F1_9 * F1; %位移9N
trans_Matrix_F1_10 = trans_Matrix_F1_10 * F1; %位移10N
trans_Matrix_F1_11 = trans_Matrix_F1_11 * F1; %位移11N
trans_Matrix_F1_12 = trans_Matrix_F1_12 * F1; %位移12N
trans_Matrix_F1_13 = trans_Matrix_F1_13 * F1; %位移13N
trans_Matrix_F1_14 = trans_Matrix_F1_14 * F1; %位移14N
trans_Matrix_F1_15 = trans_Matrix_F1_15 * F1; %位移15N
%与F1_8对齐
trans_Matrix_F1_0(:,F1_Column - 6 : F1_Column) = [];
trans_Matrix_F1_0 = [zeros(F1_Row,7),trans_Matrix_F1_0];
trans_Matrix_F1_1(:,F1_Column - 5 : F1_Column) = [];
trans_Matrix_F1_1 = [zeros(F1_Row,6),trans_Matrix_F1_1];
trans_Matrix_F1_2(:,F1_Column - 4 : F1_Column) = [];
trans_Matrix_F1_2 = [zeros(F1_Row,5),trans_Matrix_F1_2];
trans_Matrix_F1_3(:,F1_Column - 3 : F1_Column) = [];
trans_Matrix_F1_3 = [zeros(F1_Row,4),trans_Matrix_F1_3];
trans_Matrix_F1_4(:,F1_Column - 2 : F1_Column) = [];
trans_Matrix_F1_4 = [zeros(F1_Row,3),trans_Matrix_F1_4];
trans_Matrix_F1_5(:,F1_Column - 1 : F1_Column) = [];
trans_Matrix_F1_5 = [zeros(F1_Row,2),trans_Matrix_F1_5];
trans_Matrix_F1_6(:,F1_Column) = [];
trans_Matrix_F1_6 = [zeros(F1_Row,1),trans_Matrix_F1_6];
trans_Matrix_F1_8(:,1) = [];
trans_Matrix_F1_8(:,F1_Column) = 0;
trans_Matrix_F1_9(:,1:2) = [];
trans_Matrix_F1_9(:,F1_Column - 1 : F1_Column) = 0;
trans_Matrix_F1_10(:,1:3) = [];
trans_Matrix_F1_10(:,F1_Column - 2 : F1_Column) = 0;
trans_Matrix_F1_11(:,1:4) = [];
trans_Matrix_F1_11(:,F1_Column - 3 : F1_Column) = 0;
trans_Matrix_F1_12(:,1:5) = [];
trans_Matrix_F1_12(:,F1_Column - 4 : F1_Column) = 0;
trans_Matrix_F1_13(:,1:6) = [];
trans_Matrix_F1_13(:,F1_Column - 5 : F1_Column) = 0;
trans_Matrix_F1_14(:,1:7) = [];
trans_Matrix_F1_14(:,F1_Column - 6 : F1_Column) = 0;
trans_Matrix_F1_15(:,1:8) = [];
trans_Matrix_F1_15(:,F1_Column - 7 : F1_Column) = 0;
trans_Matrix_F1 = trans_Matrix_F1_0 + trans_Matrix_F1_1 + trans_Matrix_F1_2 + trans_Matrix_F1_3 + trans_Matrix_F1_4 + trans_Matrix_F1_5 + trans_Matrix_F1_6 + trans_Matrix_F1_7 + trans_Matrix_F1_8 + trans_Matrix_F1_9 + trans_Matrix_F1_10 + trans_Matrix_F1_11 + trans_Matrix_F1_12 + trans_Matrix_F1_13 + trans_Matrix_F1_14 + trans_Matrix_F1_15;
%窗
window = zeros(F1_Row,F1_Row);
for iter = 1:F1_Row
    window(iter,iter) = hamming_A0;
end
for iter = 1:F1_Row - M/16/N
    window(iter,iter + M/16/N) = hamming_A1;
    window(iter + M/16/N,iter) = hamming_A1;
end
%加窗
trans_Matrix_F1 = abs(window * trans_Matrix_F1);

%绘图显示
mesh([trans_Matrix_F1;trans_Matrix_F2;trans_Matrix_F3;trans_Matrix_F4]);