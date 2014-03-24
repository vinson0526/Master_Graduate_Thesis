clear all
H = load('testh');
H = H';
j = 1024;
jj = j / 2;
[H_row, H_colomn] = size(H);
x = zeros(jj * H_colomn + jj, 1);
temp = ifft(H(:,1),j);
x(1:j) = temp(1:j);
temp = temp(jj + 1:j);

for iter = 2 : H_colomn - 1
    temp2 = ifft(H(:,iter), j);
    x((iter - 1) * jj + 1 : iter * jj) = (temp + temp2(1:jj))./2;
    temp = temp2(jj + 1:j);
end

temp2 = ifft(H(:, H_colomn),j);
temp2(1:jj) = (temp2(1:jj) + temp)./2;
x(jj * (H_colomn - 1) + 1 : jj * H_colomn + jj) = temp2(1:j);