function bit_seq = QPSK_demapper(x)
% QPSK_table = [1 1j -1j -1]/sqrt(2);  %%%原书代码
QPSK_table = [1+1j  -1+1j 1-1j -1-1j]/sqrt(2);   %%%我自己修改的
Nx=length(x);  
for i=1:Nx
    x_temp(2*(i-1)+1:2*i,1)=dec2bin(find(QPSK_table==x(i))-1,2);
end
for i=1:Nx*2
    bit_seq(i)=bin2dec(x_temp(i));
end