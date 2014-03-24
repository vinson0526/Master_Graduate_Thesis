j=1024;
jj=j/2;
n=1;
[x,fs]=audioread('1.wav');
m=size(x,1)/jj;
H=fft(x,j);

while n < ceil(m)- 2
    B=x(n*jj+1:n*jj+j);
    C=fft(B);
    H=[H,C];
    n=n+1;
end

B=x((ceil(m)- 1)*jj+1:size(x,1));
C=fft(B,j);
H=[H,C];

H = abs(H);
H = H';

save('test','H','-ascii')