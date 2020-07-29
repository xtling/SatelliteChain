% Figure 4
% Version By Zheng Gao
% Updated on 29 Jul., 2020
clc; clear all;
%% Definitions of Input Parameters
precision = 2^12;           % length of each round of simulation
N = 6;                      % confirmations required for securing a block
round_max = 7000;           % the maximum number of rounds per simulation           
i_delta = [1];            
                            % the ratio of nodes received the block of last round
beta_t = 0:0.1:0.6;
beta_t_theo = 0:0.001:0.6;
                            % the fraction of the adversarial terrestrial miners
beta_s = 0:0.05:0.15;                
                            % the fraction of the adversarial satellites
p = [0.95];                     
                            % successful transmission probability of satellite links in the average sense

%% Parameters for Storing Results
legend_beta_t = {};
for ii = 1:length(beta_t)
    legend_beta_t = [legend_beta_t; ['\beta_t=', num2str(beta_t(ii))]];
end
legend_beta_s = {};
for ii = 1:length(beta_s)
    legend_beta_s = [legend_beta_s; ['\beta_s=', num2str(beta_s(ii))]];
end
legend_p = {};
for ii = 1:length(p)
    legend_p = [legend_p; ['p=', num2str(p(ii))]];
end

thro_pow_h = zeros(length(beta_s),length(beta_t),length(p));
theo_rate_h = zeros(length(beta_s),length(beta_t),length(p));
sim_rate_h = zeros(length(beta_s),length(beta_t),length(p));
                            % the growth rate of benign chain for PoW and the theoretical and
                            % simulated value of growth rate of benign chain for our protocol
theo_prob_success_attack = zeros(length(beta_s),length(beta_t),length(p));
sim_prob_success_attack = zeros(length(beta_s),length(beta_t),length(p));
                            % Theoretical and simulated values of the probability of double spending attack
                          
%% Simulation part
for ind_beta_s = 1:length(beta_s)
    for ind_beta_t = 1:length(beta_t)
        for ind_p = 1:length(p)
            for ind_i_delta = 1:length(i_delta)
            % Current round of simulation
            disp(['start simulating: p=', num2str(p(ind_p)),...
                ' beta_s=', num2str(beta_s(ind_beta_s)),...
                ' i_delta=', num2str(i_delta(ind_i_delta)),...
                ' beta_t=', num2str(beta_t(ind_beta_t))]);
            
            % Pre-process parameters
            beta_s_val = beta_s(ind_beta_s);
            beta_t_val = beta_t(ind_beta_t);
            p_val = p(ind_p);
            i_delta_val = i_delta(ind_i_delta);
            rate_h = zeros(1, precision);           % rate of h-chain
            rate_f = zeros(1, precision);           % rate of f-chain
            cnt_success_attack = 0;                 % count of successful attacks
                                   
            % Let us roll out!
            for ii = 1:precision
                benign_block_height = zeros(1, round_max+ 2);
                malicious_block_height = 1;
                is_success = false;
                round_count = 2;
                while true 
                    round_count = round_count + 1;
                    is_successful_transmitted = (rand < p_val);
                    is_benign_miners = (rand > beta_t_val);
                    is_benign_satellites = (rand > beta_s_val);
                    is_receive_last_block = (rand < i_delta_val);
                    
                    is_benign_win = is_benign_satellites * is_successful_transmitted * is_benign_miners;
                                                                            % it is too hard to be a good man
                    is_malicious_win = is_successful_transmitted * ~is_benign_satellites + is_benign_satellites * (~is_benign_miners) * is_successful_transmitted;
                    
                    if is_benign_win == 1                                   % good man wins
                        if is_receive_last_block == 0                        
                            benign_block_height(round_count) = benign_block_height(round_count-2) +1;
                        else
                            if benign_block_height(round_count-1) == benign_block_height(round_count-2)                                
                                benign_block_height(round_count) = benign_block_height(round_count-2) + 1;
                            else 
                                benign_block_height(round_count) = benign_block_height(round_count-1) + 1;
                            end
                        end                                                                         
                    elseif is_malicious_win == 1                             % bad man wins  
                        benign_block_height(round_count) = benign_block_height(round_count-1);
                        malicious_block_height = malicious_block_height + 1;
                    else                                                    % good man wins, but doesn't receive the oracle
                        benign_block_height(round_count) = benign_block_height(round_count-1);                   
                    end
                    
                    if benign_block_height(round_count) > N-1 &&...
                        is_success == false &&... 
                        benign_block_height(round_count) < malicious_block_height                      
                            cnt_success_attack = cnt_success_attack + 1;
                            is_success = true;
                    elseif round_count >= round_max + 2
                            break;
                    end                
                end                                
                if mod(ii,1000)==0
                    disp(['    - progress: [', num2str(ii), '/', num2str(precision), ']']); 
                end
                rate_h(ii) = benign_block_height(round_max+2) / round_max;
                rate_f(ii) = malicious_block_height / round_max;
                
                thro_judge = rate_f(ii) / ( rate_f(ii) + rate_h(ii));                
                if thro_judge >= 1/2 || beta_t_val >= 1/2
                    rate_h(ii) = 0;             % bad man controls the blockchain
                end
            end
            
            % Calculate the theoretical results 
            h_val = p_val * (1- beta_s_val) * (1- beta_t_val);
            theo_rate_h_val = h_val / (1+ h_val* (1- i_delta_val));           
            f_val = p_val * beta_s_val + p_val * beta_t_val* (1- beta_s_val);
            beta = f_val / (f_val+ theo_rate_h_val);
            
            if beta >= 1/2
                theo_rate_h_val = 0;            % bad man controls the blockchain
            end
            
            theo_success_attack_rate = 1;
            if beta >= 1/2
                theo_success_attack_rate = 1;
            else
                for nn = 0:N
                    theo_success_attack_rate = theo_success_attack_rate - ...
                        nchoosek(nn + N -1, nn) * ...
                        (beta^nn * (1-beta)^N -  beta^N * (1-beta)^nn);
                end
            end
                                          
            % Storing the result for the current round of simulation
             
            theo_rate_h(ind_beta_s,ind_beta_t,ind_p) = theo_rate_h_val;
            sim_rate_h(ind_beta_s,ind_beta_t,ind_p) = mean(rate_h);
            
            theo_rate_f(ind_beta_s,ind_beta_t,ind_p) = f_val;
            sim_rate_f(ind_beta_s,ind_beta_t,ind_p) = mean(rate_f);
            
            theo_prob_success_attack(ind_beta_s,ind_beta_t,ind_p) = theo_success_attack_rate;
            sim_prob_success_attack(ind_beta_s,ind_beta_t,ind_p) = cnt_success_attack / precision;
            end         
        end
    end
end
%% Theoretical part
for ind_beta_s = 1:length(beta_s)
    for ind_beta_t = 1:length(beta_t_theo)
        for ind_p = 1:length(p)
            for ind_i_delta = 1:length(i_delta)
            % Current round of simulation
            disp(['start simulating: p=', num2str(p(ind_p)),...
                ' beta_s=', num2str(beta_s(ind_beta_s)),...
                ' i_delta=', num2str(i_delta(ind_i_delta)),...
                ' beta_t=', num2str(beta_t_theo(ind_beta_t))]);
            
            % Pre-process parameters
            beta_s_val = beta_s(ind_beta_s);
            beta_t_val = beta_t_theo(ind_beta_t);
            p_val = p(ind_p);
            i_delta_val = i_delta(ind_i_delta);
            
            % Calculate the theoretical results 
                h_val = p_val * (1- beta_s_val) * (1- beta_t_val);
                theo_rate_h_val = h_val / (1+ h_val* (1- i_delta_val));           
                f_val = p_val * beta_s_val + p_val * beta_t_val* (1- beta_s_val);
                beta = f_val / (f_val+ theo_rate_h_val);
            
                if beta >= 1/2
                    theo_rate_h_val = 0;            % bad man controls the blockchain
                end

                theo_success_attack_rate = 1;
                if beta >= 1/2
                    theo_success_attack_rate = 1;
                else
                    for nn = 0:N
                        theo_success_attack_rate = theo_success_attack_rate - ...
                            nchoosek(nn + N -1, nn) * ...
                            (beta^nn * (1-beta)^N -  beta^N * (1-beta)^nn);
                    end
                end
                                          
            % Storing the result for the current round of simulation            
            theo_rate_h(ind_beta_s,ind_beta_t,ind_p) = theo_rate_h_val;           
            theo_prob_success_attack(ind_beta_s,ind_beta_t,ind_p) = theo_success_attack_rate;                                           
            end         
        end
    end
end