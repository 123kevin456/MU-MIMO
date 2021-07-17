%%%%%%%%%%%%%%%%%%%%%    ���ڶ��û�MIMOϵͳ���ŵ���ת��ʽ    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     multi_user_MIMO_sim2.m    %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    date:2021��7��17��  �޸�:����󽫾�   %%%%%%%%%%

%%%%%%%%%%%%%%%%%������˵��
%%%%�Ա��ŵ���ת�͹����ŵ���ת�����������

clear all;

%%% mode = 0;  %��ʾ�ŵ���ת��������ZFԤ����
%%% mode = 1; %��ʾ�����ŵ���ת��������MMSEԤ����

%%%%%%************   �������� ************%%%%%%%%%
N_frame=10; %֡��
N_packet=20000; %����
b=2; % Number of bits per QPSK symbol
NT=4; %��վ����������
N_user=20;  %%%�ܵ��û���
N_act_user=4;  %%ѡ����û���
I=eye(N_act_user,NT);
N_pbits = N_frame*NT*b; % ÿ�����ı�����
N_tbits = N_pbits*N_packet; % �ܱ�����
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
            
            %%%%%%%%%%%%����modeֵѡ�����ŵ���ת���ǹ����ŵ���ת
            %%%%%��ʽһ
            temp_W = H_used'*inv(H_used*H_used' + (mode==1)*sigma*I);
            
            %%%%%��ʽ��
            %if mode == 0
            %temp_W = H_used'*inv(H_used*H_used');
            %else
            %temp_W=H_used'*inv(H_used*H_used'+sigma2*I);
            %end
            
            beta = sqrt(NT/trace(temp_W*temp_W'));  %%��ʽ��12.17�� beta��Ϊ����Ԥ�����ܷ��书�ʲ���ĳ���
            W = beta*temp_W; % ����˵�Ԥ�������
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
%%%%%��ͼ
semilogy(SNRdBs,BER(1,:),'-ro',SNRdBs,BER(2,:),'-b+');
grid on;
xlabel('SNR[dB]');
ylabel('BER');
legend('�ŵ���ת(NB = NTx = 4���û�����20/ѡ���û�����4)','�����ŵ���ת��Tx:4,�û�����20/ѡ���û���:4');

%%%%%����
%%%%ԭ���е�QPSK_mapper,QPSK_slicer,QPSK_demapper���в���ȷ���޸ĳ��Լ�д�ģ�������ȷ
%%%%2021��7��17��



