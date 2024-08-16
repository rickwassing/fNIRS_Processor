function [ax, h] = graph_trials(cfg, fig, h)
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
ax.YLabel.String = 'trials';
ax.YDir = 'reverse';
ax.Layer = 'top';
ax.Colormap = cfg.colormap;
% -------------------------------------------------------------------------
h.trialimage = imagesc(ax, nan);
h.trialonsetmarker = plot(ax, [0, 0], [0, 1], ':k', 'LineWidth', 0.5);
h.colorbar = colorbar(ax, 'eastoutside', 'FontSize', 8);
h.colorbar.Label.String = 'HbO (\muM)';
h.colorbar.Label.FontSize = 8;
end