clear; close all; clc;

%% パラメータ
a = 0.5; b = 0.5; M = 2;
target_ber = 1e-3; 
EbNo_dB = 0:0.1:35;
gamma_plot = 10.^(EbNo_dB / 10);

%% BER理論式
calc_rayleigh = @(g) a * (1 - 1./sqrt(1 + 1./(b*g))); % 1ブランチ
calc_selection = @(g) calculation_loop(g, a, b, M); % Mブランチ

ber_func_rayleigh = @(db) calc_rayleigh(10.^(db/10)) - target_ber;
ber_func_sel = @(db) calc_selection(10.^(db/10)) - target_ber;

%% 所要CNRとゲインの算出
options = optimset('Display','off');
req_cnr_rayleigh = fzero(ber_func_rayleigh, [10 50], options);
req_cnr_sel      = fzero(ber_func_sel, [5 40], options);
diversity_gain = req_cnr_rayleigh - req_cnr_sel; % ダイバーシチ利得

%% コマンドウィンドウ出力
fprintf('BER = %.0e における所要CNR:\n', target_ber);
fprintf('ダイバーシチなし (M=1): %.2f dB\n', req_cnr_rayleigh);
fprintf('ダイバーシチあり (M=%d): %.2f dB\n', M, req_cnr_sel);
fprintf('ダイバーシチ利得: %.2f dB\n', diversity_gain);

%% グラフ描画用データの計算
ber_rayleigh_plot = calc_rayleigh(gamma_plot);
ber_sel_plot = zeros(size(gamma_plot));
for i = 1:length(gamma_plot)
    ber_sel_plot(i) = calc_selection(gamma_plot(i));
end

%% グラフ描画
figure('Name', 'Diversity Effect Analysis', 'Color', 'w');
p1 = semilogy(EbNo_dB, ber_rayleigh_plot, 'LineWidth', 1.0); hold on;
p2 = semilogy(EbNo_dB, ber_sel_plot, 'LineWidth', 1.0);
grid on;
xlabel('CNR [dB]');
ylabel('BER');
ylim([1e-4 1]);
xlim([0 30]);
legend([p1, p2], 'M=1', ['M=' num2str(M)], 'Location', 'NorthEast');
hold off;

%% 選択合成ダイバーシチの理論式
function pe = calculation_loop(Gamma, a, b, M)
    pe = zeros(size(Gamma));
    for i = 1:numel(Gamma)
        g = Gamma(i);
        sum_val = 0;
        for l = 0:(M-1)
            term1 = (-1)^l;
            term2 = nchoosek(M-1, l);
            term3 = 1 / (l + 1);
            inside_sqrt = 1 + (l + 1) / (b * g);
            term4 = 1 - 1 / sqrt(inside_sqrt);
            sum_val = sum_val + (term1 * term2 * term3 * term4);
        end
        pe(i) = a * M * sum_val;
    end
end