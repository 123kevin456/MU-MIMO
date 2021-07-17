%%%%%%%%%%%%%%%%%%%%%    使用迫零检测的块对角化方法    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%    Block_diagonalization_sim1.m    %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    date:2021年7月17日  修改:飞蓬大将军   %%%%%%%%%%

%%%%%%%%%%%%%%%%%程序功能说明
%%%%(1)将QPSK_mapper,QPSK_slicer,QPSK_demapper修改成自己写的，运行正确
%%%%(2)User1使用的W1来源是V2，User2使用的W2来源是V1，假设有点强，因为用户是难以知道别的用户信道状态信息
clear all; 
clf
N_frame=10; 
N_packet=20000; % Number of frames/packet and Number of packets
b=2; % Number of bits per QPSK symbol
NT=4;  
NR=2; 
N_user=2;  
N_pbits = N_frame*NT*b; % Number of bits in a packet
N_tbits = N_pbits*N_packet; % Number of total bits
% SNRdBs = 50:2:60; 
SNRdBs = 0:2:30; 
sq2=sqrt(2);
for i_SNR=1:length(SNRdBs)
   SNRdB=SNRdBs(i_SNR); 
   N_ebits=0; 
%    rand('seed',1);
%    randn('seed',1);
   sigma2 = NT*0.5*10^(-SNRdB/10); 
   sigma = sqrt(sigma2);
   for i_packet=1:N_packet
      msg_bit = randi([0,1],1,N_pbits); % Bit generation
      symbol = QPSK_mapper(msg_bit).';
      x = reshape(symbol,NT,N_frame); 
      H1 = (randn(NR,NT)+1j*randn(NR,NT))/sq2;
      H2 = (randn(NR,NT)+1j*randn(NR,NT))/sq2;
      [U1,S1,V1] = svd(H1);
      W2 = V1(:,3:4);
      [U2,S2,V2] = svd(H2); 
      W1 = V2(:,3:4);     
      Tx_Data = W1*x(1:2,:) + W2*x(3:4,:);
      Rx1 = H1*Tx_Data + sigma*(randn(2,N_frame)+1j*randn(2,N_frame));
      Rx2 = H2*Tx_Data + sigma*(randn(2,N_frame)+1j*randn(2,N_frame));            
      W1_H1=H1*W1;
      EQ1 = W1_H1'*inv(W1_H1*W1_H1'); % Equalizer for the 1st user
      W2_H2=H2*W2;
      EQ2 = W2_H2'*inv(W2_H2*W2_H2'); % Equalizer for the 2nd user
      y = [EQ1*Rx1; EQ2*Rx2];
      symbol_hat = reshape(y,NT*N_frame,1);
      symbol_sliced = QPSK_slicer(symbol_hat);
      demapped = QPSK_demapper(symbol_sliced);
      N_ebits = N_ebits + sum(msg_bit~=demapped); 
   end
   BER(i_SNR) = N_ebits/N_tbits;
end
semilogy(SNRdBs,BER,'-o'), grid on
xlabel('SNR[dB]');
ylabel('BER');
legend('块对角化-ZF检测');

%%%%%%%%%%%%%%%%%   结论    %%%%%%%%%%%%%%%%%%%%
%完成了迫零检测的块对角化
%2021-7-17
