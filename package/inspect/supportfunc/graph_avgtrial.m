function [ax, h] = graph_avgtrial(cfg, fig, h)
% -------------------------------------------------------------------------
ax = axes(fig);
ax.NextPlot = 'add';
ax.Toolbar = [];
ax.Box = 'on';
ax.TickDir = 'out';
ax.TickLength = [0, 0];
ax.Color = [0.83, 0.84, 0.86];
ax.GridColor = 'w';
ax.GridAlpha = 1;
ax.XTick = sort(unique([0, cfg.window]));
ax.XLim = [min(cfg.window), max(cfg.window)];
ax.FontSize = 8;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
if cfg.nbchan == 1
    ax.YLabel.String = 'Hb (\muM)';
else
    ax.YLabel.String = 'HbO (\muM)';
end
ax.Clipping = 'off';
% -------------------------------------------------------------------------
justify = linspace(cfg.window(1), cfg.window(2), 2*length(cfg.timepoints)+1);
justify = justify(2:2:end);
if isfield(cfg, 'timepoints')
    for i = 1:length(cfg.timepoints)
        h.timepointtext(i) = text(ax, justify(i), 0, sprintf('%.3f s', cfg.timepoints(i)), ...
            'FontSize', 8, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'baseline');
        h.timepointline(i) = plot(ax, ...
            [cfg.timepoints(i), cfg.timepoints(i), justify(i)], ...
            [0, 0, 0], '-', ...
            'Color', [0.45, 0.46, 0.47], ...
            'LineWidth', 0.5);
    end
end
% -------------------------------------------------------------------------
if cfg.nbchan == 1
    h.hbrtrial = patch(ax, 'XData', nan, 'YData', nan, ...
        'LineStyle', 'none', ...
        'FaceColor', [0.0000, 0.4470, 0.7410], ...
        'FaceAlpha', 0.33);
end
if cfg.nbchan == 1
    h.hbravgtrial = plot(ax, nan, nan, '-', 'Color', [0.0000, 0.4470, 0.7410], 'LineWidth', 1.5);
end
if cfg.nbchan == 1
    h.hbostdtrial = patch(ax, 'XData', nan, 'YData', nan, ...
        'LineStyle', 'none', ...
        'FaceColor', [0.8500, 0.3250, 0.0980], ...
        'FaceAlpha', 0.33);
end
for i = 1:cfg.nbchan
    if cfg.nbchan == 1
        Color = [0.8500, 0.3250, 0.0980];
    else
        Color = hsv2rgb([ascolumn(linspace(0, 1, cfg.nbchan)), 0.67.*ones(cfg.nbchan, 2)]);
    end
    h.hboavgtrial(i) = plot(ax, nan, nan, '-', 'Color', Color(i, :), 'LineWidth', 1.5);
end
h.avgonsetmarker = plot(ax, [0, 0], [0, 1], ':k', 'LineWidth', 0.5);
% -------------------------------------------------------------------------
if isfield(h, 'leg') && cfg.nbchan == 1
    h.leg = [h.leg, legend(ax, [h.hbravgtrial, h.hboavgtrial], {'HbR', 'HbO'}, ...
        'Color', 'none', ...
        'EdgeColor', 'none')];
elseif cfg.nbchan == 1
    h.leg = legend(ax, [h.hbravgtrial, h.hboavgtrial], {'HbR', 'HbO'}, ...
        'Color', 'none', ...
        'EdgeColor', 'none');
end

end