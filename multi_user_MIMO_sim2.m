%%%%%%%%%%%%%%%%%%%%%    用于多用户MIMO系统的信道反转方式    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     multi_user_MIMO_sim2.m    %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    date:2021年7月17日  修改:飞蓬大将军   %%%%%%%%%%

%%%%%%%%%%%%%%%%%程序功能说明
%%%%对比信道反转和规则化信道反转的误码率情况

clear all;

%%% mode = 0;  %表示信道反转，即采用ZF预均衡
%%% mode = 1; %表示规则化信道反转，即采用MMSE预均衡

%%%%%%************   参数设置 ************%%%%%%%%%
N_frame=10; %帧数
N_packet=20000; %包数
b=2; % Number of bits per QPSK symbol
NT=4; %基站发射天线数
N_user=20;  %%%总的用户数
N_act_user=4;  %%选择的用户数
I=eye(N_act_user,NT);
N_pbits = N_frame*NT*b; % 每个包的比特数
N_tbits = N_pbits*N_packet; % 总比特数
% SNRdBs = 100;
SNRdBs = 0:2:20;
sq2=sqrt(2);
BER = zeros(2,length(SNRdBs));
for mode = 0:1
    for i_SNR=1:length(SNRdBs)
        SNRdB=SNRdBs(i_SNR);
        N_ebits = 0;
        sigma2 = NT*0.5*10^(-SNRdB/10);
        sigma = sqrt(sigma2);
        %     rand('seed',1);
        %     randn('seed',1);
        for i_packet=1:N_packet
            msg_bit = randi([0,1],1,N_pbits); % Bit generation
            %%%%%%%%%%%%%******************   Transmitter *************%%%%%%%%%%%%%%%%%%
            symbol = QPSK_mapper(msg_bit).';
            x = reshape(symbol,NT,N_frame);
            for i_user=1:N_user
                H(i_user,:) = (randn(1,NT)+1j*randn(1,NT))/sq2;
                Channel_norm(i_user)=norm(H(i_user,:));
            end
            [Ch_norm,Index]=sort(Channel_norm,'descend');
            %H_used=[H(Index(1),:); H(Index(2),:); H(Index(3),:); H(Index(4),:)];
            H_used = H(Index(1:N_act_user),:);
            
            %%%%%%%%%%%%根据mode值选择是信道反转还是规则化信道反转
            %%%%%方式一
            temp_W = H_used'*inv(H_used*H_used' + (mode==1)*sigma*I);
            
            %%%%%方式二
            %if mode == 0
            %temp_W = H_used'*inv(H_used*H_used');
            %else
            %temp_W=H_used'*inv(H_used*H_used'+sigma2*I);
            %end
            
            beta = sqrt(NT/trace(temp_W*temp_W'));  %%公式（12.17） beta是为满足预均衡总发射功率不变的常数
            W = beta*temp_W; % 发射端的预均衡矩阵
            Tx_signal = W*x;
            
            %%%%%%%%%%%%%****************** Channel and Noise ******************%%%%%%%%%%%%%
            Rx_signal = H_used*Tx_signal + sigma*(randn(N_act_user,N_frame)+1j*randn(N_act_user,N_frame));
            
            %%%%%%%%%%%%%%****************** Receiver ******************%%%%%%%%%%%%%%%%%%%%%
            x_hat = Rx_signal/beta; % Eq.(12.18)
            symbol_hat = reshape(x_hat,NT*N_frame,1);
            symbol_sliced = QPSK_slicer(symbol_hat);
            demapped = QPSK_demapper(symbol_sliced);
            N_ebits = N_ebits + sum(msg_bit~=demapped);
            %         if mod(i_packet,1000)==0
            %             fprintf('packet : %d passed\n',i_packet);
            %         end
        end
        BER(mode+1,i_SNR) = N_ebits/N_tbits;
    end
end
%%%%%画图
semilogy(SNRdBs,BER(1,:),'-ro',SNRdBs,BER(2,:),'-b+');
grid on;
xlabel('SNR[dB]');
ylabel('BER');
legend('信道反转(NB = NTx = 4，用户数：20/选择用户数：4)','规则化信道反转（Tx:4,用户数：20/选择用户数:4');

%%%%%结论
%%%%原书中的QPSK_mapper,QPSK_slicer,QPSK_demapper运行不正确，修改成自己写的，运行正确
%%%%2021年7月17日



