function [ out ] = SHSV2( wave_name, out_file)
%%%
%最大值译码
%%%
point_number = 4096;
order_number = 12;
harmonic_ratio = 0.9;
semi_begin_ori = 40;
semi_end_ori = 105;
semi_end_voice = 81;
semi_begin = semi_begin_ori - 0.5;
semi_number = semi_end_ori - semi_begin_ori + 1;
semi_number_voice = semi_end_voice - semi_begin_ori + 1;

[x, fs] =audioread(wave_name);
%x = x(:,2);
[S, F, T] =  spectrogram(x, hanning(640), 320, point_number, fs);
S = abs(S);

%计算shs时的频率界限
%low_bound = floor(80 * point_number / fs);
%up_bound = ceil(5000 * point_number / fs);
%speech_bound = ceil(1000 * point_number / fs);

%能量谱
S_energy = S .^ 2;
%F_H_rigion = F;

%得到每一个半音对应的频率值，存储在semi_tone中
semi_tone = zeros(semi_number + 1,1);
for iter = 1:semi_number + 1
    semi_tone(iter) = solve(['69 + 12 * log2(x/440) = ',num2str(iter + semi_begin - 1)],'x');
end

%计算每一个半音的范围,存储在struct semi_rigion中，begin是起始频率点，end是结束频率点
semi_rigion(semi_number) = struct('begin',[],'end',[]);
semi_rigion_count = 1;
for iter = 1 : length(F)
    if semi_rigion_count <= (semi_number + 1)
        if F(iter) > semi_tone(semi_rigion_count)
            if semi_rigion_count ~= (semi_number + 1)
                semi_rigion(semi_rigion_count).begin = iter;
            end
            if semi_rigion_count ~= 1
                semi_rigion(semi_rigion_count - 1).end = iter;
            end
            semi_rigion_count = semi_rigion_count + 1;
        end
    end
end

%得到一个半音区间内的最大值
peak_in_semi = zeros(semi_number, length(T));
peak_local = zeros(semi_number, length(T));
for t = 1 : length(T)
    for iter = 1 : semi_number
        [peak_in_semi(iter, t), l]= max(S_energy(semi_rigion(iter).begin : semi_rigion(iter).end, t),[], 1);
        peak_local(iter, t) = semi_rigion(iter).begin + l - 1;
    end
end

%SHS
candidate_pitch = zeros(semi_number_voice, length(T));
for t = 1 : length(T)
    for iter = 1 : semi_number_voice
        for order = 1 : order_number
            if 12 * (order - 1) + iter <= semi_number
                candidate_pitch(iter, t) = candidate_pitch(iter, t) + (harmonic_ratio ^ (order - 1)) * peak_in_semi(12 * (order - 1) + iter, t);
            end
        end
    end
end

%得到候选里值最大的那一个
out_local = zeros(length(T), 1);
for t = 1 : length(T)
    if max(candidate_pitch(:,t)) == 0
        out_local(t) = 2;
    else
        [~, l] = findpeaks(candidate_pitch(:,t), 'SORTSTR','descend','NPEAKS',1);
        out_local(t) = peak_local(l,t);
    end
end

%频率纠正
out_ori = zeros(length(T), 1);
out = zeros(length(T), 1);
for t = 1 : length(T)
    alpha = 20 * log10(S(out_local(t) - 1, t));
    beta = 20 * log10(S(out_local(t), t));
    gamma = 20 * log10(S(out_local(t) + 1, t));
    delta = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
    if beta > alpha && beta > gamma
        out_ori(t) = F(out_local(t)) + delta * fs / point_number;
    else
        out_ori(t) = F(out_local(t));
    end
    out(t) = 69 + 12 * log2(out_ori(t)/440);
end

%平滑
for iter = 2 : length(out) - 1
    if ((out(iter) - out(iter - 1)) > 2 && (out(iter) - out(iter + 1)) > 2) || ((out(iter) - out(iter - 1)) < -2 && (out(iter) - out(iter + 1)) < -2)
        out(iter) = (out(iter - 1) + out(iter + 1)) / 2;
    end
end

%写入文件
dlmwrite(out_file, out,'delimiter', '\t', 'precision', 5);
end