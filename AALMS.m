format compact;
clc;
close all;
clear all;

channel_taps = 16; % number of channel taps present in the FIR filter
desired_noise_SNR = 0; % gaussian noise present in the desired output data
filter_weights = rand(channel_taps,1); % initializing normalized random values for the channel taps of FIR filter
weight_update = rand(channel_taps,1); % inital guess of the filter weights choosen to be all zero vector
step_size = 0.1; % step size or step length
alpha =2; % alpha parameter

wait_bar = waitbar(0,'Starting processing');
mu_AALMS = step_size; % step length of the MCC update method
experiment= 1000; % ensemble-average independent runs
iteration = 5000; % total number of iterations done

% selected parameters
mean_square_deviation_main = zeros(iteration,1); % Mean Square Deviation
mean_square_error_main = zeros(iteration,1); % Mean Square Error
excess_mean_square_error_main = zeros(iteration,1); % Excess Mean Square Error

for dummy_var_2 = 1:experiment
    wait_bar_percentage = dummy_var_2/experiment *100;
    wait_bar = waitbar(dummy_var_2/experiment, wait_bar, strcat('Percentage complete.....',string(floor(wait_bar_percentage)),'%'));
    u_i = zeros(1,channel_taps); % input vector
    mean_square_deviation = zeros(iteration,1); % Mean Square Deviation
    mean_square_error = zeros(iteration,1); % Mean Square Error
    excess_mean_square_error = zeros(iteration,1); % Excess Mean Square Error
    w_AALMS = weight_update; % setting the weight update vector equal to the initial guess which is all zero vector

    for dummy_var = 1:iteration
        new_tx_symbol = abs(normrnd(0,1)); % Gaussian random numbers with mean 0 and variance 1
        tx_symbol(dummy_var) = new_tx_symbol;
        u_i = [new_tx_symbol u_i(1:end-1)]; % generate regressor/input signal (u_i - a row vector of size 1xM)
        [d_i,desired_noise_variance] = awgn(u_i*filter_weights, desired_noise_SNR); % generate noisy version of channel output as received symbol
        e_i_AALMS = (d_i -u_i*w_AALMS); % finding error between desired output and filter output to update adaptive filter
        w_AALMS = w_AALMS + (mu_AALMS/alpha) * (u_i'*(d_i.^alpha ./ (u_i*w_AALMS).^alpha) - u_i');  % updating the adaptive filter after finding the error using AALMS algorithm
        
        %calculation of the parameter
        mean_square_deviation(dummy_var) = norm(w_AALMS-filter_weights)^2; % mean square deviation calculation
        excess_mean_square_error(dummy_var) = norm(e_i_AALMS)^2; % Excess Mean Square Error calculation
        mean_square_error(dummy_var) = excess_mean_square_error(dummy_var)+ desired_noise_variance; % Mean Square Error Calculation
    end

    mean_square_deviation = mean_square_deviation/max(mean_square_deviation);
    excess_mean_square_error = excess_mean_square_error/max(excess_mean_square_error);
    mean_square_error = mean_square_error/max(mean_square_error);

    mean_square_deviation_main = mean_square_deviation_main + mean_square_deviation;
    mean_square_error_main = mean_square_error_main + mean_square_error;
    excess_mean_square_error_main = excess_mean_square_error_main + excess_mean_square_error;
end



mean_square_deviation = mean_square_deviation_main/experiment;
mean_square_error = mean_square_error_main/experiment;
excess_mean_square_error = excess_mean_square_error_main/experiment;



% Plot for Mean Square Devivation Curve
figure;
plot(10*log10(mean_square_deviation),'linewidth',1);
xlabel('iteration')
ylabel('Mean Square Deviation (dB)');
legend('AALMS')


% Plot for Excess Mean Square Error Curve
figure;
plot(10*log10(excess_mean_square_error),'linewidth',1);
xlabel('iteration')
ylabel('Excess Mean Square Error (dB)');
legend('AALMS')


% Plot for Mean Square Error Curve
figure;
plot(10*log10(mean_square_error),'linewidth',1);
xlabel('iteration')
ylabel('Mean Square Error (dB)');
legend('AALMS')

close(wait_bar);
