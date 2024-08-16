function [ax, h] = graph_dc(data, cfg, fig, h)
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
ax.YLabel.String = '\Delta [Hemoglobin]';
% -------------------------------------------------------------------------
dtypes = unique({data.dc.measurementList.dataTypeLabel}, 'stable');
for i = 1:length(dtypes)
    switch lower(dtypes{i})
        case 'hbo'
            Color = [0.8500, 0.3250, 0.0980]; % red
        case 'hbr'
            Color = [0.0000, 0.4470, 0.7410]; % blue
        otherwise
            Color = [0.4102, 0.4102, 0.4102]; % grey
    end
    for j = 1:cfg.nbchan
        h.chan(j).dc(i) = plot(ax, nan, nan, '-', 'Color', Color, 'LineWidth', 1.5);
    end
end
% -------------------------------------------------------------------------
for i = 1:cfg.numuniqueevents
    tmp = data.info.events(strcmpi(data.info.events.type, cfg.uniqueevents{i}), :);
    srate = data.info.nirs.SamplingFrequency;
    Color = ax.ColorOrder(mod(i-1, 7)+1, :);
    for j = 1:size(tmp, 1)
        onset = tmp.onset(j);
        XData = [onset, onset];
        plot(ax, XData, [-9999, 9999], ':', 'LineWidth', 0.5, 'Color', Color)
    end
end
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
ax.Children = flipud(ax.Children);
% -------------------------------------------------------------------------
if isfield(h, 'leg')
    h.leg = [h.leg, legend(ax, h.chan(1).dc, dtypes, ...
        'Color', 'none', ...
        'EdgeColor', 'none')];
else
    h.leg = legend(ax, h.chan(1).dc, dtypes, ...
        'Color', 'none', ...
        'EdgeColor', 'none');
end

end