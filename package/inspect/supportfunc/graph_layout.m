function [ax, h] = graph_layout(cfg, fig, h)
% -------------------------------------------------------------------------
ax = axes(fig);
ax.NextPlot = 'add';
ax.Toolbar = [];
ax.XColor = 'w';
ax.YColor = 'w';
% -------------------------------------------------------------------------
ft_plot_layout(cfg.layout, ...
    'box', 'no', ...
    'outline', 'no', ...
    'point', 'no', ...
    'fontcolor', [0.44, 0.45, 0.46], ...
    'fontsize', 6);
h.layout = findobj(ax.Children, 'Type', 'line');
h.layoutlabels = findobj(ax.Children, 'Type', 'text');
% -------------------------------------------------------------------------
for i = 1:length(h.layoutlabels)
    XData = h.layoutlabels(i).Position(2);
    YData = h.layoutlabels(i).Position(1);
    h.layoutlabels(i).Position(1) = XData;
    h.layoutlabels(i).Position(2) = YData;
end
XData = h.layout.YData;
YData = h.layout.XData;
h.layout.XData = XData;
h.layout.YData = YData;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for j = 1:length(h.layout)
    h.layout(j).LineStyle = 'none';
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
h.chanloc = plot(ax, nan, nan, '.', 'MarkerSize', 25);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Lim = [max(abs([ax.XLim, ax.YLim]))];
ax.XLim = [-Lim, Lim];
ax.YLim = [-Lim, Lim];
ax.PlotBoxAspectRatio = [1, 1, 1];
r = 0.85;
h.headplot = plot(ax, r.*Lim.*cos(0:pi/24:2*pi), r.*Lim.*sin(0:pi/24:2*pi), '-', ...
    'LineWidth', 3, ...
    'Color', [0.84, 0.85, 0.86]);
h.noseplot = plot(ax, [-0.19.*Lim, 0, 0.19.*Lim], [r.*Lim.*sin(0.42*pi), Lim, r.*Lim.*sin(0.58*pi)] , '-', ...
    'LineWidth', 3, ...
    'Color', [0.84, 0.85, 0.86]);
ax.Children = flipud(ax.Children);
ax.Title.String = '<label>';
ax.Title.FontSize = 8;
ax.Title.FontWeight = 'normal';
ax.Title.HorizontalAlignment = 'left';
ax.Title.VerticalAlignment = 'top';
ax.Title.Position(1) = ax.XLim(1);
ax.Title.Position(2) = ax.YLim(2);

end