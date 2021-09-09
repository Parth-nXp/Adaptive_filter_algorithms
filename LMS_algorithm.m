format compact;
clc;
close all;
clear all;


noise_SNR = 20; % variance of the noise added in the channel
mu_LMS = 0.085; % value of the mu for LMS algorithm
channel_taps = 4; % number of weights in the FIR Filter
filter_weights = [1; 0.5; -1; 2]; % actual value of weight of FIR FIlter

iteration = 300; % total number of iterations done
tx_symbol_log = zeros(iteration,1); % defining the transmitted symbols
LMS_error_vector= zeros(iteration,1); % defining the LMS error vector
u_i = zeros(1,channel_taps); % input vector
rng(0,'philox'); % fixing the random value
initial_weight_guess = randn(channel_taps,1); % initial guess for w_LMS
w_LMS = initial_weight_guess; % defining the value of w_LMS
desired_vector = zeros(iteration,1); % defining the desired system
updated_vector = zeros(iteration,1); % defining the updated vector which will get updated after each iteration
MSE_LMS = zeros(iteration, 1);  % definin the Mean square error vector for the LMS algorithm
RMSE_LMS = zeros(iteration,1); % defining the Root mean square error vector for the LMS algorithm 

for dummy_var = 1:iteration
    rng(dummy_var+1,'philox'); % sert seed for random no. generator
    new_tx_symbol = 2*(randn > 0)-1; % BPSK symbols
    tx_symbol(dummy_var) = new_tx_symbol; 
    u_i = [new_tx_symbol u_i(1:end-1)]; % generate regressor/input signal (u_i - a row vector of size 1xM)
    d_i = awgn(u_i*filter_weights, noise_SNR); % generate noisy version of channel output as received symbol
    desired_vector(dummy_var) = d_i; % updating the desired vector with d_i
    updated_vector(dummy_var) = u_i*w_LMS; % updating the updated vector after each iteration of adaptive filter
    % LMS update 
    e_i_LMS = (d_i -u_i*w_LMS); % finding error between desired output and filter output to update adaptive filter
    w_LMS = w_LMS + mu_LMS * u_i'*e_i_LMS; % updating the adaptive filter after finding the error using LMS algorithm
    %\calculation of the parameter
    LMS_error_vector(dummy_var) = e_i_LMS; % updating the error vector
    cost_function(dummy_var)= abs(e_i_LMS); % finding the cost function or euclidean norm
    MSE_LMS = mean(cost_function,1); % updating the mean square error vector after each iteration
    RMSE_LMS = sqrt(MSE_LMS); % updating the root mean square error vector after each iteration
end


euclidean_norm = norm(LMS_error_vector,2);
manhattan_norm = norm(LMS_error_vector,1);
p_norm = norm(LMS_error_vector,17);
maximum_norm = norm(LMS_error_vector,inf);
figure;
plot([1:dummy_var], MSE_LMS(1:dummy_var), 'Linewidth', 1);
hold on
plot([1:dummy_var], RMSE_LMS(1:dummy_var), 'Linewidth', 1);
xlabel('iteration')
ylabel('MSE , RMSE');
title('LMS: MSE and RMSE vs iteration');
legend('MSE','RMSE')


% figure;
% plot([1:dummy_var], euclidean_norm(1:dummy_var), 'Linewidth', 1);
% xlabel('iteration');
% ylabel('derr');
% title('LMS: derr vs iterations');
% 
figure;
stem(filter_weights,  'b', 'MarkerSize', 8,  'Linewidth', 1); hold on;
stem(w_LMS, 'r', 'MarkerSize', 6,  'Linewidth', 1); hold on;
legend('ground truth (c)', 'w-lms');