%% QPSK変調波形の生成
clear; clc; close all; % 初期設定

%% 各種パラメータ
SymbolRate = 1; % シンボルレート
Fc = 5; % 搬送波周波数 (Hz)
Fs = 1000; % サンプリング周波数 (Hz)
NumSymbols = 5; % 送信シンボル数
T_symbol = 1 / SymbolRate;
t_one_symbol = 0 : 1/Fs : T_symbol - 1/Fs;

%% 情報源の生成
BitStream = randi([0, 1], 2, NumSymbols); 

%% 変調処理(QPSK)
Signal = []; % 変調信号を格納する配列
TimeAxis = []; % 時間軸を格納する配列
for k = 1:NumSymbols
    % 情報源から2bit分取り出す
    b1 = BitStream(1, k);
    b0 = BitStream(2, k);   
    % "00"のときπ/4
    if (b1 == 0 && b0 == 0)
        phi = pi/4;
        bits_str = '00';
    % "01"のとき3π/4
    elseif (b1 == 0 && b0 == 1)
        phi = 3*pi/4;    % "01"
        bits_str = '01';
    % "10"のとき5π/4
    elseif (b1 == 1 && b0 == 1)
        phi = 5*pi/4;    % "11"
        bits_str = '11';
    % "11"のとき7π/4
    else
        phi = 7*pi/4;    % "10"
        bits_str = '10';
    end    
    fprintf('Symbol%d: data sequence="%s" -> phi=%f [rad]\n', k, bits_str, phi);
    current_signal = cos(2 * pi * Fc * t_one_symbol + phi); % 搬送波s(t)の生成
    Signal = [Signal, current_signal]; % 信号の結合
    current_time = t_one_symbol + (k-1)*T_symbol; % 時間軸の結合
    TimeAxis = [TimeAxis, current_time];
end

%% 波形描画
plot(TimeAxis, Signal, 'LineWidth', 1.0);
grid on;
xlabel('Time [Symbol]');
ylabel('s(t)');
title(['QPSK Modulation Waveform (Carrier Frequency: ' num2str(Fc) 'Hz)']);
ylim([-1.5 1.5]);
for k = 1:NumSymbols-1
    xline(k * T_symbol, 'LineWidth', 1.0);
end
xticks(0:NumSymbols);