close all;
clear all;
clc;

%% input
load('Figure_5');
line_width = 2;
marker_size = 7;
legend_p = [legend_p; 'PoW'];
plot([0.5 0.5],[0 0],'color','k','linewidth',line_width,'linestyle','--',...
    'marker','<','markersize',marker_size,'markerfacecolor','k');
hold on;
plot([0.5 0.5],[0 0],'color','b','linewidth',line_width,'linestyle','--',...
    'marker','o','markersize',marker_size,'markerfacecolor','b');
hold on;
plot([0.5 0.5],[0 0],'color','c','linewidth',line_width,'linestyle','--',...
    'marker','D','markersize',marker_size,'markerfacecolor','c');
hold on;
plot([0.5 0.5],[0 0],'color','r','linewidth',line_width,'linestyle','--',...
    'marker','s','markersize',marker_size,'markerfacecolor','r');
hold on;
plot([0 0],[0 0],'color','g','linewidth',line_width,'linestyle',':');
hold on;
for ind_s = 1:length(beta_s)
    color_list = ['k','b','c','r','g','y','m'];
    marker_list = ['<','o','D','s','v','x','p'];
    
    % Plot oracle theratical throughput
    for pind = 1:length(p)
        yyaxis left;
        plot(beta_t_theo,theo_rate_h(pind,:,ind_s),'linestyle','--',...
                'color',color_list(pind),'linewidth',line_width);       
        hold on;
    end
    
    % Plot oracle simulated throughput
    for pind = 1:length(p)
        yyaxis left;
        plot(beta_t,sim_rate_h(pind,:,ind_s),'color',color_list(pind),'marker',...
            marker_list(pind),'markerfacecolor',color_list(pind),'markersize',...
            marker_size,'linestyle','none');
        hold on;
    end
    
    % Plot oracle theratical security
    pind = 4;      
        yyaxis right;
        plot(beta_t_theo,theo_prob_success_attack(pind,:,ind_s),'linestyle','--',...
                'color',color_list(pind),'linewidth',line_width);
        ax = gca;
        ax.YColor = 'k';
        hold on;
    % Plot oracle simulated security
        yyaxis right;
        plot(beta_t,sim_prob_success_attack(pind,:,ind_s),'color',color_list(pind),'marker',...
            marker_list(pind),'markerfacecolor',color_list(pind),'markersize',...
            marker_size,'linestyle','none');
        hold on;
            
    % Plot PoW theratical throughput    
    yyaxis left;
    plot(beta_t_theo,pow_rate_h(pind,:,ind_s),'linestyle',':',...
            'color',color_list(pind + 1),'linewidth',line_width);
    ylabel('Normalized  Throughput'); 
    hold on;
    
    % Plot PoW theratical security 
    yyaxis right;
    plot(beta_t_theo,pow_prob_success_attack(pind,:,ind_s),'linestyle',':',...
            'color',color_list(pind + 1),'linewidth',line_width);
    ylabel('Confirmation Error Prob.'); 
    hold on;
    legend(legend_p, 'location', 'southwest');
            
    xlabel('\beta');
    box on;
    grid on;
end
x = gcf;
    Font_size = 16;
    % Throughput
    annotation(x,'textarrow',[0.45 0.13],[0.53 0.53],'String',{'Throughput'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman',...
    'horizontalalignment','left');

    % Security
    annotation(x,'textarrow',[0.73 0.89],[0.78 0.78],'String',{'Security'},...
    'HeadStyle','cback3','FontSize', Font_size, 'FontName', 'Times New Roman','horizontalalignment','left');

    % Comparison
    annotation(x,'textarrow',[0.59 0.67],[0.8 0.63],'String',{'Proposed protocol has the', 'same safety property as PoW'},...
    'HeadStyle','cback3','FontSize', 15, 'FontName', 'Times New Roman','horizontalalignment','left');   
    annotation('ellipse',[0.43 0.52 .04 .22]);
    PrintFigToPaper('-dpdf', mfilename, 16, 'Times New Roman', 7, 1, 0);