function [ax, h] = graph_topoplot(cfg, fig, h)
% -------------------------------------------------------------------------
ax = axes(fig);
ax.NextPlot = 'add';
ax.Toolbar = [];
ax.XColor = 'w';
ax.YColor = 'w';
ax.PlotBoxAspectRatio = [1, 1, 1];
% -------------------------------------------------------------------------
if ~isfield(cfg, 'style')
    cfg.style = 'blank';
end
if ~isfield(cfg, 'plotchans')
    cfg.plotchans = 1:length(cfg.chanlocs);
end
Colors = hsv2rgb([ascolumn(linspace(0, 1, length(cfg.chanlocs))), 0.67.*ones(length(cfg.chanlocs), 2)]);
% -------------------------------------------------------------------------
topoplot(rand(1, length(cfg.chanlocs)), cfg.chanlocs, ...
    'style', cfg.style, ...
    'plotchans', cfg.plotchans, ...
    'hcolor', [0.24, 0.25, 0.26], ...
    'whitebk', 'on', ...
    'colormap', cfg.colormap);
% -------------------------------------------------------------------------
topopatch = findobj(ax.Children, 'Type', 'patch');
h.toposurf = findobj(ax.Children, 'Type', 'surface');
h.chanlocs = findobj(ax.Children, 'Marker', '.');
if ~isempty(topopatch)
    delete(topopatch)
end
% -------------------------------------------------------------------------
head = findobj(ax.Children, 'LineStyle', '-');
for i = 1:length(head)
    head(i).LineWidth = 1.5;
end
% -------------------------------------------------------------------------
if isempty(h.toposurf) && ~isempty(h.chanlocs)
    for i = 1:length(h.chanlocs.XData)
        h.chan(i).dot = copyobj(h.chanlocs, ax);
        h.chan(i).dot.XData = h.chanlocs.XData(i);
        h.chan(i).dot.YData = h.chanlocs.YData(i);
        h.chan(i).dot.ZData = h.chanlocs.ZData(i);
        h.chan(i).dot.Color = Colors(i, :);
    end
end
% -------------------------------------------------------------------------
% Mask any vertex that is too far away from a channel
d = [];
if ~isempty(h.toposurf)
    for x = 1:size(h.toposurf.XData, 2)
        for y = 1:size(h.toposurf.YData, 1)
            d(y, x) = min(sqrt((h.chanlocs.XData-h.toposurf.XData(y, x)).^2 + (h.chanlocs.YData-h.toposurf.YData(y, x)).^2)); 
        end
    end
    h.toposurf.CData(d > 0.08) = nan;
    delete(h.chanlocs)
end
% -------------------------------------------------------------------------
ax.XLim = [-0.6, 0.6];
ax.YLim = [-0.6, 0.6];
ax.PlotBoxAspectRatio = [1, 1, 1];

end