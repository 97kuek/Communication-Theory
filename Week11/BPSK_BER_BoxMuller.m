clear; close all; clc;

%% 各種パラメータ
N_bits = 1e6; % 送信ビット数
SNR_dB = 0:1:15; % 評価するSNRの範囲
sim_ber = zeros(1, length(SNR_dB)); % シミュレーションBER格納用

%% BPSK変調
data = randi([0 1], 1, N_bits); % ランダムな0,1ビット列
s_t = 2 * data - 1; % 0 -> -1, 1 -> +1
S = 1; % 信号電力

%% SNRループによるBER評価
for k = 1:length(SNR_dB)

    % SNRの計算
    SNR_linear = 10^(SNR_dB(k) / 10);
    N = S / SNR_linear; % N=S/SNR
    sigma_n = sqrt(N); % 雑音電力を標準偏差σに変換
    
    % Box-Muller法による雑音生成
    u1 = rand(1, N_bits);
    u2 = rand(1, N_bits);
    z = sqrt(-2 * log(u1)) .* cos(2 * pi * u2);
    n_t = sigma_n * z; % 雑音波形の生成
    
    % 受信と復調(雑音付加と判定)
    r_t = s_t + n_t; % 加法性雑音
    r_data = r_t > 0; % 弁別レベル
    
    % ビット誤り率(BER)の計算
    error_cnt = sum(data ~= r_data); % 送信データと復調データを比較
    sim_ber(k) = error_cnt / N_bits; % ビット誤り率を求める
end

%% 理論値計算
snr_lin_range = 10.^(SNR_dB / 10);
P_e = 0.5 * erfc(sqrt(snr_lin_range / 2));

%% 波形描画
figure;
semilogy(SNR_dB, P_e, 'LineWidth', 1.0); hold on;
semilogy(SNR_dB, sim_ber, 'ko', 'MarkerSize', 7, 'LineWidth', 1.0);
grid on;
xlabel('SNR [dB]','Interpreter','latex');
ylabel('Bit Error Rate ($P_e$)','Interpreter','latex');
legend({'Theory: $P_e = \frac{1}{2}\mathrm{erfc}\left(\sqrt{\frac{SNR}{2}}\right)$', 'Simulation'}, ...
       'Interpreter', 'latex');
axis([0 15 1e-6 1]);