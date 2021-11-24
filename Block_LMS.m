format compact;
clc;
close all;
clear all;


noise_SNR = 20; % variance of the noise added in the channel
mu_LMS = 0.085; % value of the mu for LMS algorithm
channel_taps = 4; % number of weights in the FIR Filter
filter_weights = [1; 0.5; -1; 2]; % actual value of weight of FIR FIlter

iteration = 500; % total number of iterations done
tx_symbol_log = zeros(iteration,1); % defining the transmitted symbols
LMS_error_vector= zeros(iteration,1); % defining the LMS error vector
u_i = zeros(1,channel_taps); % input vector
rng(0,'philox'); % fixing the random value
initial_weight_guess = randn(channel_taps,1); % initial guess for w_LMS
w_LMS_initial = initial_weight_guess; % defining the value of w_LMS
dummy_matrix = zeros(4,iteration);
block_length = 10;
e_i = zeros(iteration, 1);
U_i = zeros(block_length, channel_taps);
D_i = zeros(block_length,1);

for dummy_var = 1:iteration
    rng(dummy_var+1,'philox'); % sert seed for random no. generator
    new_tx_symbol = 2*(randn > 0)-1; % BPSK symbols
    tx_symbol(dummy_var) = new_tx_symbol; 
    if rem(dummy_var, block_length) ~= 0
        u_i = [new_tx_symbol u_i(1:end-1)]; % generate regressor/input signal (u_i - a row vector of size 1xM)
        U_i = [u_i ; U_i(1:end-1,:)];
        d_i = awgn(u_i*filter_weights, noise_SNR); % generate noisy version of channel output as received symbo
        D_i = [d_i ; D_i(1:end-1,:)];
     else
         y_i = w_LMS_initial'*U_i';
         e_i = D_i - y_i';
         phi_mat = U_i.* e_i;
         sum_phi_mat = sum(phi_mat,1);
         w_LMS_initial = w_LMS_initial + mu_LMS.* sum_phi_mat';
    end
end

stem(filter_weights)
hold on
stem(w_LMS_initial)
