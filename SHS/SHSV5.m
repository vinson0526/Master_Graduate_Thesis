function [ out ] = SHSV5( wave_name, out_file)
%%%
%寻找最大值，然后以最大值为起始点
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
viterbi_judge_field = 6;	%试验确定具体值
vertibi_judge_prob = 0.3;	%试验确定具体值

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

%得到一个半音区间内的最大值，peak_in_semi中存储的是半音区间中能量谱的最大值，peak_local中存储的是最大值的频率点
peak_in_semi = zeros(semi_number, length(T));
peak_local = zeros(semi_number, length(T));
for t = 1 : length(T)
    for iter = 1 : semi_number
        [peak_in_semi(iter, t), l]= max(S_energy(semi_rigion(iter).begin : semi_rigion(iter).end, t),[], 1);
        peak_local(iter, t) = semi_rigion(iter).begin + l - 1;
    end
end

%SHS,
%candidate_pitch中存储的是在语音区间中每一个半音区间最大的shs值,candidate_local存储的是在语音区间中每一个半音区间最大值的频点
candidate_pitch = zeros(semi_number_voice, length(T));
%candidate_local = peak_local(1 : semi_number_voice, :);
for t = 1 : length(T)
    for iter = 1 : semi_number_voice
        for order = 1 : order_number
            if 12 * (order - 1) + iter <= semi_number
                candidate_pitch(iter, t) = candidate_pitch(iter, t) + (harmonic_ratio ^ (order - 1)) * peak_in_semi(12 * (order - 1) + iter, t);
            end
        end
    end
end

%对所有频点进行频率纠正,freq_true中存储的是纠正后的频率
freq_true = zeros(semi_number_voice, length(T));
for t = 1 : length(T)
    for iter = 1 : semi_number_voice
        alpha = 20 * log10(S(peak_local(iter, t) - 1, t));
        beta = 20 * log10(S(peak_local(iter, t) - 1, t));
        gamma = 20 * log10(S(peak_local(iter, t) + 1, t));
        delta = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
        if beta > alpha && beta > gamma
            freq_true(iter, t) = F(peak_local(iter, t)) + delta * fs / point_number;
        else
            freq_true(iter, t) = F(peak_local(iter, t));
        end
        freq_true(iter, t) = 69 + 12 * log2(freq_true(iter, t)/440);
    end
end

%开始译码
%probability_ori存储的是所有点的归一化概率值
probability_ori = zeros(semi_number_voice, length(T));
for t = 1 : length(T)
    z = max(candidate_pitch(:,t));
    probability_ori(:,t) = candidate_pitch(:,t) ./ z;
end

%存储当前点概率值，和它的前一帧以及后一帧的频点
viterbi(semi_number_voice, length(T)) = struct('prob',[],'last',[],'next',[]);

has_found = zeros(length(T), 1);
while(true)
	has_found_count = 0;
	for iter = 1 : length(T)
		if has_found(iter) == 1
			has_found_count = has_found_count + 1;
		end
	end
	if has_found_count = length(T)
		break;
	end
	%寻找全局最大值点
	iter_max_value = 0;
	iter_max_local = [0,0];	%第一维是半音点，第二维是时间点
	for t = 1 : length(T)
		if has_found(t) == 0
			[t_max_value, t_max_local] = max(candidate_pitch(:,t),[],1);	%第三个参数不确定，待实验
			if t_max_value > iter_max_value
				iter_max_value = t_max_value;
				iter_max_local(1) = t_max_local;
				iter_max_local(2) = t;
			end
		end
	end
	
	has_found(iter_max_local(2)) = 1;	%将已经得到值得点设为1
	
	%更改viterbi前后关系
	for iter = 1 : semi_number_voice
		viterbi(iter, iter_max_local(2)).prob = probability_ori(iter, iter_max_local(2));
		if iter_max_local(2) ~= 1
			viterbi(iter, iter_max_local(2) - 1).next = iter_max_local(1);
		end
		if iter_max_local(2) ~= length(T)
			viterbi(iter, iter_max_local(2) + 1).last = iter_max_local(1);
		end
	end
	
	%分别进行左译码和右译码
	%终止标记
	right_stop = 0;
	left_stop = 0;
	%向右译码
	for t = iter_max_local(2) + 1 : length(T)
		if has_found(t) == 1
			right_stop = t - 1;
			break;
		end
		
		%终止判断
		%前一时刻最大的
		last_max = [viterbi(1, t - 1).prob, 1];
		for f = 2 : semi_number_voice
			if last_max < viterbi(f, t - 1).prob
				last_max(1) = viterbi(f, t - 1).prob;
				last_max(2) = f;
			end
		end
		
		%获取判定边界
		temp_low_bound = last_max(2) - viterbi_judge_field;
		if temp_low_bound < 1
			temp_low_bound = 1;
		end
		
		temp_high_bound = last_max(2) + viterbi_judge_field;
		if temp_high_bound > semi_number_voice
			temp_high_bound = semi_number_voice;
		end
		%判定是否可以继续
		temp_local_max = max(probability_ori(temp_low_bound : temp_high_bound,t));
		temp_all_max = max(probability_ori(:,t));
		if temp_local_max / temp_all_max < vertibi_judge_prob
			break;
		end
		
		
		this_frame = zeros(semi_number_voice, 1);
		for f = 1 : semi_number_voice
			temp = zeros(semi_number_voice, 1);
			for iter = 1 : semi_number_voice
				temp(iter) = probability_ori(iter, t - 1) * probability_ori(f, t) * distance_penalty(freq_true(f, t) - freq_true(iter, t - 1));
			end
			[this_frame(f), viterbi(f, t).last] = max(temp, [], 1);
		end
		this_frame = this_frame ./ max(this_frame);
		for iter2 = 1 : semi_number_voice
			viterbi(iter2, t).prob = this_frame(iter2);
		end
		
	end
	%向左译码
end




















%获取当前帧的每个频率的概率
for t = length(T) - 1 : -1 : 1
    this_frame = zeros(semi_number_voice, 1);
    for f = 1 : semi_number_voice
        temp = zeros(semi_number_voice, 1);
        for iter = 1 : semi_number_voice
            temp(iter) = probability_ori(iter, t + 1) * probability_ori(f, t) * distance_penalty(freq_true(f, t) - freq_true(iter, t + 1));
        end
        [this_frame(f), viterbi(f, t).next] = max(temp, [], 1);
    end
    this_frame = this_frame ./ max(this_frame);
    for iter2 = 1 : semi_number_voice
        viterbi(iter2, t).prob = this_frame(iter2);
    end
end


last_frame = zeros(semi_number_voice, 1);
for iter = 1 : semi_number_voice
    last_frame(iter) = viterbi(iter, 1).prob;
end
local = zeros(length(T), 1);
[~, local(1)] = max(last_frame, [], 1);

for iter = 2 : length(T)
    local(iter) = viterbi(local(iter - 1), iter - 1).next;
end

out = zeros(length(T), 1);
for iter = 1 : length(T)
    out(iter) = freq_true(local(iter), iter);
end

%写入文件
%dlmwrite(out_file, out,'delimiter', '\t', 'precision', 5);
end


%两个频率之间的转移概率
function [penalty] = distance_penalty(distance)
delta = 5;
penalty = (1 / (sqrt(2 *pi) * delta)) .* exp(- (distance .^ 2) / (delta .^ 2)); 
end