%%%%%%%%%%%%%%%%%%%%%    脏纸编码和Tomlinson-Harashima预编码    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%    Dirty_or_TH_precoding_sim1.m    %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    date:2021年7月17日  修改:飞蓬大将军   %%%%%%%%%%

clear all;
% mode = 0; % Set to 0/1 for Dirty/TH precoding
N_frame=10; % Number of frames in a packet, 1 frame=4 symbols
N_packet=10000; % Number of packets
b=2; % Number of bits per QPSK symbol
NT=4; %基站发射天线数
N_user=10; %总用户数
N_act_user=4; %激活用户数
I=eye(N_act_user,NT);
N_pbits = N_frame*NT*b; % Number of bits in a packet
N_tbits = N_pbits*N_packet; % Number of total bits
SNRdBs=0:2:20;
sq2=sqrt(2);
BER = zeros(2,length(SNRdBs));
for mode = 0:1
    for i_SNR=1:length(SNRdBs)
        SNRdB = SNRdBs(i_SNR);
        N_ebits = 0;
        %    rand('seed',1);
        %    randn('seed',1);
        sigma2 = NT*0.5*10^(-SNRdB/10);
        sigma = sqrt(sigma2);
        %------------- Transmitter ----------------
        for i_packet=1:N_packet
            msg_bit = randi([0,1],1,N_pbits); % Bit generation
            symbol = QPSK_mapper(msg_bit).';
            x = reshape(symbol,NT,N_frame);
            H = (randn(N_user,NT)+1j*randn(N_user,NT))/sq2;
            %----- user selection ----------
            Combinations = nchoosek([1:N_user],N_act_user)';
            for i=1:size(Combinations,2)
                H_used = H(Combinations(:,i),:);
                [Q_temp, R_temp] = qr(H_used);
                %diagonal entries of R_temp are real
                minimum_l(i) = min(diag(R_temp));
            end
            [max_min_l,Index] = max(minimum_l);
            H_used = H(Combinations(:,Index),:);
            [Q_temp,R_temp] = qr(H_used');
            L=R_temp';
            Q=Q_temp';
            xp = x;
            if mode==0  % Dirty precoding
                for m=2:4
                    xp(m,:) = xp(m,:) - L(m,1:m-1)/L(m,m)*xp(1:m-1,:);
                end
            else  % TH precoding
                for m=2:4
                    xp(m,:) = modulo(xp(m,:)-L(m,1:m-1)/L(m,m)*xp(1:m-1,:),sq2);
                end
            end
            Tx_signal = Q'*xp; % DPC/TH encoder
            %------------ Channel and Noise ----------------
            Rx_signal = H_used*Tx_signal + ...
                sigma*(randn(N_act_user,N_frame)+1j*randn(N_act_user,N_frame));
            %------------ Receiver ----------------
            y = inv(diag(diag(L)))*Rx_signal;
            symbol_hat = reshape(y,NT*N_frame,1);
            if mode==1 % in the case of TH precoding
                symbol_hat = modulo(symbol_hat,sq2);
            end
            symbol_sliced = QPSK_slicer(symbol_hat);
            demapped = QPSK_demapper(symbol_sliced);
            N_ebits = N_ebits + sum(msg_bit~=demapped);
        end
        BER(mode+1,i_SNR) = N_ebits/N_tbits;
    end
end

semilogy(SNRdBs,BER(1,:),'-ro',SNRdBs,BER(2,:),'-b+');
grid on;
xlabel('SNR[dB]');
ylabel('BER');
legend('DPC','THP');