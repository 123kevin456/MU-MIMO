function [QPSK_symbols] = QPSK_mapper(bitseq)
% QPSK_table = [1  1j -1j -1]/sqrt(2); %%%%原书附带代码

QPSK_table = [1+1j  -1+1j 1-1j -1-1j]/sqrt(2);   %%%我自己修改的
for i=1:length(bitseq)/2
   temp = bitseq(2*(i-1)+1)*2 +bitseq(2*(i-1)+2);
   QPSK_symbols(i) = QPSK_table(temp+1);
end