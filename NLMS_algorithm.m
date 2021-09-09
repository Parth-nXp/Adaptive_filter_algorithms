close all;
clc;

noise_SNR = 20; % variance of the noise added in the channel
epsilon_NLMS = 0.00001; % value of the epsiolon for NLMS algorithm
mu_NLMS = 0.1; % value of the mu for NLMS algorithm


channel_taps = 4; % number of weights in the FIR Filter
filter_weights = [1; 0.5; -1; 2]; % actual value of weight of FIR FIlter


iteration = 300; % total number of iterations done
txSymbol_log = zeros(iteration,1); % defining the transmitted symbols
NLMS_error_vector = zeros(iteration,1); % defining the NLMS error vector
u_i = zeros(1,channel_taps); % input vector
rng(0,'philox'); % sert seed for random no. generator
initial_weight_guess = randn(channel_taps,1);  % initial guess for w_NLMS
w_NLMS = initial_weight_guess;  % defining the value of w_LMS
desired_vector = zeros(iteration,1); % defining the desired system
updated_vector = zeros(iteration,1); % defining the updated vector which will get updated after each iteration
MSE_NLMS = zeros(iteration, 1);  % defining the Mean square error vector for the NLMS algorithm
RMSE_NLMS = zeros(iteration,1); % defining the Root mean square error vector for the NLMS algorithm 

for dummy_var = 1:iteration
    rng(dummy_var+1,'philox'); % sert seed for random no. generator
    newTxSymbol = 2*(randn > 0)-1; % BPSK symbols
    txSymbol_log(dummy_var) = newTxSymbol;
    u_i = [newTxSymbol u_i(1:end-1)]; % generate regressor/input signal (u_i - a row vector of size 1xM)
    d_i = awgn(u_i*filter_weights, noise_SNR); % generate noisy version of channel output as received symbol
    desired_vector(dummy_var) = d_i; % updating the desired vector with d_i
    updated_vector(dummy_var) = u_i*w_NLMS; % updating the updated vector after each iteration of adaptive filter
    % NLMS update   
    e_i_NLMS = (d_i -u_i*w_NLMS); % finding error between desired output and filter output to update adaptive filter
    w_NLMS = w_NLMS + (mu_NLMS/(epsilon_NLMS + (u_i*u_i')))*u_i'*e_i_NLMS;  % updating the adaptive filter after finding the error using NLMS algorithm
    % calculation of the parameter
    NLMS_error_vector(dummy_var) = e_i_NLMS; % updating the error vector
    cost_function(dummy_var)= abs(e_i_NLMS); % finding the cost function or euclidean norm
    MSE_NLMS = mean(cost_function,1); % updating the mean square error vector after each iteration
    RMSE_NLMS = sqrt(MSE_NLMS); % updating the root mean square error vector after each iteration
end

euclidean_norm = norm(NLMS_error_vector,2);
manhattan_norm = norm(NLMS_error_vector,1);
p_norm = norm(NLMS_error_vector,17);
maximum_norm = norm(NLMS_error_vector,inf);
figure;
plot([1:dummy_var], MSE_NLMS(1:dummy_var), 'Linewidth', 1);
hold on
plot([1:dummy_var], RMSE_NLMS(1:dummy_var), 'Linewidth', 1);
xlabel('iteration')
ylabel('MSE , RMSE');
title('NLMS: MSE and RMSE vs iteration');
legend('MSE','RMSE')


figure;
stem(filter_weights,  'b', 'MarkerSize', 8,  'Linewidth', 1); hold on;
stem(w_NLMS, 'r', 'MarkerSize', 6,  'Linewidth', 1); hold on;
legend('ground truth (c)', 'w-nlms');