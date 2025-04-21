freq = [0.01 0.1 0.5 1.00 2.00 3.00 5.00 6.00 8.00 10.00 20.00]';

resp = [5-0.09i; 4.99-0.94i; 1.78-7.18i; -1.81+0.28i; -0.13+0.11i; 
    -0.02+0.01i; -0-0.02i; -0-0.02i; 0-0.02i; 0-0.01i; 0-0.01i];

magnitude = 20*log10(abs(resp));

phase = angle(resp);

% figure(1) 
% semilogx(freq, magnitude, 'o');
% title('Magnitude Reponse of System')
% xlabel('\omega (rad/sec)')
% ylabel('Magnitude (dB)')
% 
% figure(2)
% semilogx(freq, 180*phase/pi, 'o');
% title('Phase Reponse of System')
% xlabel('\omega (rad/sec)')
% ylabel('Phase (degrees)')
% 

% Sampling time (0 for continuous-time system)
Ts = 0;

% Create frequency response data object
frd_data = idfrd(resp, freq, Ts);

for n = 1:4
    sys = tfest(frd_data, n);

    % model at the same freq resp
    [mag_model, phase_model] = bode(sys, freq);
    resp_model = squeeze(mag_model) .* exp(1j * deg2rad(squeeze(phase_model)));

    % calculate rate of fit
    fit_percent = 100 * (1 - norm(resp - resp_model) / norm(resp - mean(resp)));
    fprintf('Order-%d Fit: %.2f%%\n', n, fit_percent);

    % % plot
    % figure(n);
    % bode(frd_data, sys)
    % legend('Original', sprintf('Order-%d Model', n))
    % title(sprintf('Bode Plot for Order-%d Model', n))
    % 
    % figure(n+4)
    % rlocus(sys)
    % title('Root Locus of the System')
    % 
    % figure(n+8)
    % nyquist(sys)
    % title('Nyquist Plot of the System')
end

best_sys = tfest(frd_data, 3);  % Example with 3rd-order
figure(3)
bode(frd_data, best_sys)
margin(best_sys)
legend('Original', sprintf('Order-%d Model', 3))
title(sprintf('Bode Plot for Order-%d Model', 3))

figure(4)
rlocus(best_sys)
title('Root Locus of the System')

figure(5)
nyquist(best_sys)
title('Nyquist Plot of the System')


G = tf(best_sys);  % 把 idtf 轉成 tf 類別

pole(G)

% K1 = 0.01; K2 = 500;

figure(6)
sys_c0 = feedback(G, 1);   % unity feedback closed-loop system
step(sys_c0)
title('origin - Closed-loop Step Response')


K_list = [50, 60, 70, 80, 90, 100];
for i = 1:length(K_list)
    K = K_list(i);
% Closed Loop
    sys_c = feedback(K * G, 1); % unity feedback closed-loop system
    figure(6+i)
    step(sys_c)
    title(sprintf('K= %.4f - Closed-loop Step Response', K))

    figure(6+i+length(K_list))
    sprintf('K= %.4f', K)
    pole(sys_c)
    rlocus(sys_c)
    title(sprintf('K= %.4f - Root Locus of the System', K))
    
    figure(6+i+length(K_list)*2)
    nyquist(sys_c)
    title(sprintf('K= %.4f - Nyquist Plot of the System', K))

    figure(6+i+length(K_list)*3)
    bode(sys_c)
    margin(sys_c)
    legend(sprintf('K= %.4f -', K), sprintf('Order-%d Model', 3))
    title(sprintf('Bode Plot for Order-%d Model', 3))
    
end

