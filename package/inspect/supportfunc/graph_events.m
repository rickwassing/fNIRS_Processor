function [ax, h] = graph_events(data, cfg, fig, h)
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
ax.YLim = [0.5, cfg.numuniqueevents+0.5];
ax.YTick = 1:cfg.numuniqueevents;
ax.YTickLabel = cfg.uniqueevents;
ax.YDir = 'reverse';
ax.FontSize = 8;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
ax.Units = 'points';
ax.Position(4) = 9.*cfg.numuniqueevents;
ax.Units = 'normalized';
% -------------------------------------------------------------------------
for i = 1:cfg.numuniqueevents
    tmp = data.info.events(strcmpi(data.info.events.type, cfg.uniqueevents{i}), :);
    Color = ax.ColorOrder(mod(i-1, 7)+1, :);
    for j = 1:size(tmp, 1)
        onset = tmp.onset(j);
        duration = tmp.duration(j);
        XData = [onset, onset+duration, onset+duration, onset];
        YData = [i-0.33, i-0.33, i+0.33, i+0.33];
        patch(ax, ...
            'XData', XData, ...
            'YData', YData, ...
            'LineWidth', 0.5, ...
            'EdgeColor', Color, ...
            'FaceColor', Color);
    end
end

end