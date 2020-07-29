clear all;
clc;
close all

%% input
load('Figure_6');
line_width = 2;
marker_size = 5;
plot([0 0],[0.4873 0.4873],'color','k','linewidth',line_width,'linestyle','--',...
    'marker','<','markersize',marker_size,'markerfacecolor','k');
hold on;
plot([0 0],[0.461 0.461],'color','b','linewidth',line_width,'linestyle','--',...
    'marker','d','markersize',marker_size,'markerfacecolor','b');
hold on;
plot([0 0],[0.432 0.432],'color','r','linewidth',line_width,'linestyle','--',...
    'marker','s','markersize',marker_size,'markerfacecolor','r');
hold on;
for pind = 1:length(p)
    % Plot Relative throughput
    color_list = ['k','b','r','c','g','y','m'];
    marker_list = ['<','d','s','s','x','p','v'];
    if pind == 1   % p = 0.8
        % Plot theratical results first
        for ind_t = 1:length(beta_t)            
            plot(i_delta, theo_rate_h(ind_t,:,pind),...
                'color',color_list(ind_t),'linewidth',line_width,'linestyle','--'); 
            hold on;
        end

        % Then, simulated results
        for ind_t = 1:length(beta_t)
            plot(i_delta, sim_rate_h(ind_t,:,pind),...
                'color',color_list(ind_t),'linewidth',line_width,...
                'marker',marker_list(ind_t),'markerfacecolor',color_list(ind_t),...
                'markersize',marker_size,'linestyle','none'); hold on;
        end
    else            % p = 0.95
        % Plot theratical results first
        for ind_t = 1:length(beta_t)
            plot(i_delta, theo_rate_h(ind_t,:,pind),...
                'color',color_list(ind_t),'linewidth',line_width,'linestyle','-'); 
            hold on;
        end

        % Then, simulated results
        for ind_t = 1:length(beta_t)
            plot(i_delta, sim_rate_h(ind_t,:,pind),...
                'color',color_list(ind_t),'linewidth',line_width,...
                'marker',marker_list(ind_t),'markerfacecolor',color_list(ind_t),...
                'markersize',marker_size,'linestyle','none'); hold on;
        end
    end
    xlabel('i_\Delta');
    ylabel('Normalized  Throughput');
    box on;
    grid on;
end
legend(legend_beta, 'location', 'southeast');
x = gcf;
Font_size = 16;

annotation(x,'textarrow',[0.4 0.48],...
    [0.58 0.475],'String',{'p = 0.99'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman','horizontalalignment','left');

annotation(x,'textarrow',[0.69 0.64],...
    [0.28 0.4],'String',{'p = 0.85'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman','horizontalalignment','left');

annotation('ellipse',[0.46 0.33 .04 .16]);
annotation('ellipse',[0.62 0.32 .04 .18]);
PrintFigToPaper('-dpdf', mfilename, 16, 'Times New Roman', 7, 1, 0);
