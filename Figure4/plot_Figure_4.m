clear all;
clc;
close all

%% input
load('Figure_4');
line_width = 2;
marker_size = 7;
plot([0 0],[0 0],'color','k','linewidth',line_width,'linestyle','--',...
    'marker','<','markersize',marker_size,'markerfacecolor','k');
hold on;
plot([0 0],[0 0],'color','b','linewidth',line_width,'linestyle','--',...
    'marker','o','markersize',marker_size,'markerfacecolor','b');
hold on;
plot([0 0],[0 0],'color','c','linewidth',line_width,'linestyle','--',...
    'marker','D','markersize',marker_size,'markerfacecolor','c');
hold on;
plot([0 0],[0 0],'color','r','linewidth',line_width,'linestyle','--',...
    'marker','s','markersize',marker_size,'markerfacecolor','r');
hold on;
for pind = 1:length(p)   
    color_list = ['k','b','c','r','g','y','m'];
    marker_list = ['<','o','D','s','x','p','v'];
    
    % Plot theratical results first       
    for ind_s = 1:length(beta_s)
        yyaxis left;
        plot(beta_t_theo,theo_rate_h(ind_s,:,pind),'linestyle','--',...
                'color',color_list(ind_s),'linewidth',line_width);
        yyaxis right;
        plot(beta_t_theo,theo_prob_success_attack(ind_s,:,pind),'linestyle','--',...
                'color',color_list(ind_s),'linewidth',line_width);
        ax = gca;
        ax.YColor = 'k';
        hold on;
    end
    
    % Then, simulated results
    for ind_s = 1:length(beta_s)
        yyaxis left;
        plot(beta_t,sim_rate_h(ind_s,:,pind),'color',color_list(ind_s),'marker',...
            marker_list(ind_s),'markerfacecolor',color_list(ind_s),'markersize',...
            marker_size,'linestyle','none');
        ylabel('Normalized  Throughput');
        yyaxis right;
        plot(beta_t,sim_prob_success_attack(ind_s,:,pind),'color',color_list(ind_s),'marker',...
            marker_list(ind_s),'markerfacecolor',color_list(ind_s),'markersize',...
            marker_size,'linestyle','none');
        ylabel('Confirmation Error Prob.');
        hold on;
    end
    
    legend(legend_beta_s, 'location', 'southwest');
    xlabel('\beta_t');
    box on;
    grid on;
      
end
    
    Font_size = 16;
    % Throughput
    annotation('textarrow',[0.357 0.13],[0.64 0.64],'String',{'Throughput'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman',...
    'horizontalalignment','left');
    % Security
    annotation('textarrow',[0.72 0.89],[0.7 0.7],'String',{'Security'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman','horizontalalignment','left');    
    annotation('ellipse',[0.34 0.63 .03 .16]);    
    annotation('ellipse',[0.54 0.68 .19 .04]);
    PrintFigToPaper('-dpdf', mfilename, 16, 'Times New Roman', 7, 1, 0);
