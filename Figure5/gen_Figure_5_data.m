% Figure 5
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
                            % the fraction of the adversarial terrestrial miners
beta_t_theo = 0:0.001:0.6;
beta_s = [0];                
                            % the fraction of the adversarial satellites
p = [0.85 0.95 0.99 1];                     
                            % successful transmission probability of satellite links in the average sense
                            
beta_0 = beta_s + beta_t.*(1 - beta_s);
beta_0_theo = beta_s + beta_t_theo.*(1 - beta_s);
                            % beta
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

pow_rate_h = zeros(length(p),length(beta_0_theo),length(beta_s));
theo_rate_h = zeros(length(p),length(beta_0_theo),length(beta_s));
sim_rate_h = zeros(length(p),length(beta_0),length(beta_s));
                            % the growth rate of benign chain for PoW and
                            % the theoretical and simulated value of
                            % growth rate of benign chain for our protocol
                
pow_prob_success_attack = zeros(length(p),length(beta_0_theo),length(beta_s));
theo_prob_success_attack = zeros(length(p),length(beta_0_theo),length(beta_s));
sim_prob_success_attack = zeros(length(p),length(beta_0),length(beta_s));
                            % the probability of double spending attack of PoW and 
                            % theoretical and simulated values of the probability of double spending attack
                            % of our protocol
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
            h_val = p_val * (1- beta_s_val) * (1- beta_t_val);      % not consider the propagation delay                        
            f_val = p_val * beta_s_val + p_val * beta_t_val* (1- beta_s_val);            
            beta = f_val / (f_val+ h_val);
            theo_rate_h_val = h_val * (beta <=0.5) + 0 * (beta >0.5);
                        
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
            
            % PoW
            beta_pow = beta_t_val;            
            syms f_BTC;
            f_btc = solve(1- exp(-(1-beta_pow)* f_BTC) == beta_pow * f_BTC);
            thro_pow_val1 = 1 - exp(beta_pow - 1);  
            thro_pow_val2 = beta_pow * f_btc;
            
            if beta_pow >= 1/2
                thro_pow = 0;
            else               
                thro_pow = min([thro_pow_val1 thro_pow_val2]);
                if thro_pow_val2 == 0
                    thro_pow = thro_pow_val1;
                end               
            end
            
            pow_success_attack_rate = 1;
            if beta_pow >= 1/2
                pow_success_attack_rate = 1;
            else
                for nn = 0:N
                    pow_success_attack_rate = pow_success_attack_rate - ...
                        nchoosek(nn + N -1, nn) * ...
                        (beta_pow^nn * (1-beta_pow)^N -  beta_pow^N * (1-beta_pow)^nn);
                end
            end
                                          
            % Storing the result for the current round of simulation
            pow_rate_h(ind_p,ind_beta_t,ind_beta_s) = thro_pow;
            theo_rate_h(ind_p,ind_beta_t,ind_beta_s) = theo_rate_h_val;
                        
            pow_prob_success_attack(ind_p,ind_beta_t,ind_beta_s) = pow_success_attack_rate;
            theo_prob_success_attack(ind_p,ind_beta_t,ind_beta_s) = theo_success_attack_rate;
            end         
        end
    end
end
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
                if thro_judge >= (1/2 - 0.01) || beta_t_val >= 1/2
                    rate_h(ii) = 0;             % bad man controls the blockchain
                end
            end
                           
            % Storing the result for the current round of simulation
            sim_rate_h(ind_p,ind_beta_t,ind_beta_s) = mean(rate_h);                        
            sim_prob_success_attack(ind_p,ind_beta_t,ind_beta_s) = cnt_success_attack / precision;
            end         
        end
    end
end