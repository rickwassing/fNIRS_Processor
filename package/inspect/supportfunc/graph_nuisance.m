function [ax, h] = graph_nuisance(data, cfg, fig, h)
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
ax.XTick = [];
ax.XLim = [min(data.raw.data.time), max(data.raw.data.time)];
ax.FontSize = 8;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
ax.YLabel.String = 'Nuisance regressors';
% -------------------------------------------------------------------------
for i = 1:cfg.numuniqueevents
    tmp = data.info.events(strcmpi(data.info.events.type, cfg.uniqueevents{i}), :);
    Color = ax.ColorOrder(mod(i-1, 7)+1, :);
    for j = 1:size(tmp, 1)
        onset = tmp.onset(j);
        duration = tmp.duration(j);
        XData = [onset, onset+duration, onset+duration, onset];
        plot(ax, XData(1:2), [-9999, 9999], ':', 'LineWidth', 0.5, 'Color', Color)
    end
end
% -------------------------------------------------------------------------
for i = 1:length(cfg.nidx)
    Color = ax.ColorOrder(mod(i-1, 7)+1, :);
    for j = 1:cfg.nbchan
        h.chan(j).origdc(i) = plot(ax, nan, nan, '-', 'Color', [0.44, 0.45, 0.46], 'LineWidth', 1.5);
        h.chan(j).aux(i) = plot(ax, nan, nan, '-', 'Color', Color, 'LineWidth', 1.5);
    end
end

end