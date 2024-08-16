function [ax, h] = graph_psd(data, fig, h)
% -------------------------------------------------------------------------
ax = axes(fig);
ax.NextPlot = 'add';
ax.Toolbar = [];
ax.Box = 'on';
ax.TickDir = 'out';
ax.TickLength = [0, 0];
ax.Color = [0.83, 0.84, 0.86];
ax.XGrid = 'on';
ax.GridColor = 'w';
ax.GridAlpha = 1;
ax.MinorGridLineStyle = 'none';
ax.XTick = [0 0.01 0.1 1 2 5 10];
ax.YTick = [];
ax.XScale = 'log';
ax.YScale = 'log';
ax.FontSize = 8;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
ax.XLabel.String = 'Frequency';
ax.YLabel.String = 'Power-spectral density';
% -------------------------------------------------------------------------
for i = 1:length(data.raw.probe.wavelengths)
    switch i
        case 1
            Color = [0.8895, 0.5095, 0.1115]; % orange
        case 2
            Color = [0.8500, 0.3250, 0.0980]; % red
        otherwise
            Color = [0.4102, 0.4102, 0.4102]; % grey
    end
    h.psd(i) = plot(ax, nan, nan, '-', 'Color', Color, 'LineWidth', 1.5);
end

end