function [] = PrintFigToPaper (OutputType,plotFileName,...
    FigFontSize,FigFontName,FigWidth,IsPrint,IsPrintTime,IsCustomHeight,FigHeightCustom,IsHideAxis)
% OutputType = -depsc  -dpdf  -dpng
% FigFontSize = 16;
% FigFontName = 'Times New Roman';
% FigWidth = 7; %inches
% IsPrint = 1; %flag: 1-output this figure
% IsPrintTime = 0; %flag: 0-do not append a timestamp to the filename
% IsCustomHeight = 0; %flag: 0-the figure height is automatically adapted
% FigHeightCustom = 5; %(OPTIONAL)
% IsHideAxis = 0; %(OPTIONAL) flag: 0-Hide the Axes

numdip = 300;
set(gcf,'PaperUnits','inches');
set(gcf,'Units','inches');
if nargin >= 10 && IsHideAxis == 1
    set(gca, 'xcolor', 'none', 'ycolor', 'none');
else
    set(gca,'color','none');
end
screenposition = get(gcf,'Position');
FigHeight = FigWidth/screenposition(3)*screenposition(4);
if nargin > 7 && IsCustomHeight
     FigHeight = FigHeightCustom;
end
set(gcf,'PaperPosition',[0 2 FigWidth FigHeight]);
set(gcf,'Position',[screenposition(1:2)/2  FigWidth FigHeight]);
set([get(gca,'XLabel'),get(gca,'YLabel')],...
    'FontSize',FigFontSize,'FontName', FigFontName);
set(findobj('FontSize',10),'FontSize',FigFontSize);
set(findobj('FontName','Helvetica'),'FontName', FigFontName);
set(findobj('FontSize',10),'FontSize',FigFontSize);
set(findobj('FontSize',16),'FontSize',FigFontSize);

% output
if ~exist('pic','dir')
   mkdir('pic');
end
if(IsPrint && 1)
    if(IsPrintTime && 1)
        print(gcf,OutputType,'-painters',['-r',num2str(numdip)],['pic/',plotFileName,datestr(clock,30)]);
    else
        print(gcf,OutputType,'-painters',['-r',num2str(numdip)],['pic/',plotFileName]);
    end
end