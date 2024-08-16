function [ax, h] = graph_sci(data, fig, h)
% -------------------------------------------------------------------------
ax = axes(fig);
ax.NextPlot = 'add';
ax.Toolbar = [];
ax.Box = 'on';
ax.Clipping = 'off';
ax.TickDir = 'out';
ax.TickLength = [0, 0];
ax.Color = [0.83, 0.84, 0.86];
ax.YGrid = 'on';
ax.GridColor = 'w';
ax.GridAlpha = 1;
ax.XLim = [min(data.raw.data.time), max(data.raw.data.time)];
ax.YTick = [-1, 0, 1];
ax.YLim = [-1, 1];
ax.FontSize = 8;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
ax.YLabel.String = 'SCI';
% -------------------------------------------------------------------------
if isfield(h, 'reject')
    h.reject(end+1) = patch(ax, 'XData', nan, 'YData', nan, 'CData', nan, ...
        'LineStyle', 'none', ...
        'FaceColor', 'r', ...
        'FaceAlpha', 0.1);
else
    h.reject = patch(ax, 'XData', nan, 'YData', nan, 'CData', nan, ...
        'LineStyle', 'none', ...
        'FaceColor', 'r', ...
        'FaceAlpha', 0.1);
end
% -------------------------------------------------------------------------
h.sqi_lo = plot(ax, nan, nan, ':k', 'LineWidth', 0.5);
h.sqi_hi = plot(ax, nan, nan, ':k', 'LineWidth', 0.5);
h.sqi_mu = plot(ax, nan, nan, ':k', 'LineWidth', 0.5);
h.sqi_text_lo = text(ax, nan, nan, 'lo', 'FontSize', 8);
h.sqi_text_hi = text(ax, nan, nan, 'lo', 'FontSize', 8);
h.sqi_text_mu = text(ax, nan, nan, 'lo', 'FontSize', 8);
h.sqi = plot(ax, nan, nan, '-', 'LineWidth', 1.5);

end