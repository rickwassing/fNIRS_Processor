% FNI_GRAPHTRIALSACROSSCHANS
%
% Usage:
%   >> fni_graphtrialsacrosschans(data, cfg);
%
% Inputs:
%   'data.info' - [struct] configuration settings
%   'data.raw' - [DataClass] Homer3 data class
%   'data.dod' - [DataClass] Homer3 data class
%   'data.dc' - [DataClass] Homer3 data class
%      or
%   'data.glm' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'colormap' - [matrix] <n x 3> (optional) colormap
%
% Outputs:
%   none

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-09-06, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function fni_graphtrialsacrosschans(data, cfg)
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing trials across channels.\n');
% =========================================================================
% INIT
% -------------------------------------------------------------------------
cfg = graph_init(data, data.dod.measurementList, cfg);
cfg.chanlist = cellfun(@(s) strsplit(s, '-'), cfg.chanlist, 'UniformOutput', false);
cfg.axheight = 100;
cfg.nbchan = length(cfg.chanlist);
if ~isfield(cfg, 'timepoints')
    cfg.timepoints = linspace(cfg.window(1), cfg.window(end), 7);
    cfg.timepoints([1, 3, 7]) = [];
end
switch cfg.source
    case 'dc'
        source = data.dc;
    case 'glm'
        source = data.glm.dc;
    otherwise
        error('>> FNI: Requested source ''%s'' is not implemented, sorry. Contact Rick Wassing.', cfg.source)
end
% =========================================================================
% Initialize the figure and handles
% -------------------------------------------------------------------------
h = [];
% -------------------------------------------------------------------------
% Figure
src = groot();
fig = graph_figure([1, 1, min([src.ScreenSize(3), length(cfg.timepoints).*75]), 3*cfg.axheight]);
% -------------------------------------------------------------------------
% Axes and plots
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(1), h] = graph_avgtrial(cfg, fig, h);
ax(1).Units = 'pixels';
ax(1).OuterPosition([2, 4]) = [1, 2*cfg.axheight];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cfg.style = 'blank';
[ax(2), h] = graph_topoplot(cfg, fig, h);
ax(2).Units = 'pixels';
ax(2).Position = [ax(1).Position(1), ax(1).Position(2)+ax(1).Position(4)-0.5*cfg.axheight, 0.5.*cfg.axheight, 0.5.*cfg.axheight];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ax(1).Units = 'normalized';
o = ax(1).Position(1);
w = ax(1).Position(3);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
h.topoplots = struct();
for i = 1:length(cfg.timepoints)
    cfg.style = 'map';
    [ax(end+1), h.topoplots(i).h] = graph_topoplot(cfg, fig, []);
    ax(end).Position = [o+(i-1)*w/length(cfg.timepoints), 0.67, w/length(cfg.timepoints), 0.33];
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
h.colorbar = colorbar(ax(end), 'eastoutside', 'FontSize', 8);
h.colorbar.Label.String = 'HbO (\muM)';
h.colorbar.Label.FontSize = 8;
h.colorbar.Position(1) = ax(1).Position(1).*0.8;
h.colorbar.Position([2, 4]) = [0.7625, 0.15];
% =========================================================================
% Iterate over all the event types
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for e = 1:length(cfg.uniqueevents)
    % ---------------------------------------------------------------------
    % SINGLE EVENT IMAGE
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    idx = strcmpi({data.raw.stim.name}, cfg.uniqueevents{e});
    stim = StimClass(); % Init an empty stim class
    stim.name = cfg.uniqueevents{e};
    stim.data = data.raw.stim(idx).data;
    stim.states = [data.raw.stim(idx).states(:, 1), ones(size(stim.data, 1), 1)];
    if size(stim.data, 1) < 3
        continue
    end
    avg = hmrR_BlockAvg(source, stim, cfg.window);
    % ---------------------------------------------------------------------
    % UPDATE THE AVERAGE ACROSS CHANNELS
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    idx_hbo = contains(lower({avg.measurementList.dataTypeLabel}), 'hbo');
    idx_ml = nan(cfg.nbchan, 1);
    tmp = avg.dataTimeSeries(:, idx_hbo).*1000000;
    ml = source.measurementList(idx_hbo);
    for i = 1:cfg.nbchan
        idx_ml(i) = find(cfg.chanindex(i, 1) == [ml.sourceIndex] & cfg.chanindex(i, 2) == [ml.detectorIndex]);
    end
    tmp = tmp(:, idx_ml);
    for i = 1:cfg.nbchan
        h.hboavgtrial(i).XData = avg.time;
        h.hboavgtrial(i).YData = tmp(:, i);
    end
    try
    ax(1).YLim = 1.1.*[-1*max(abs(tmp(:))), max(abs(tmp(:)))];
    catch ME
        keyboard
    end
    ax(1).YTick = 1.1.*max(abs(tmp(:)));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ax(1).Title.HorizontalAlignment = 'left';
    ax(1).Title.String = sprintf('Source: %s\nEvent: %s', cfg.source, cfg.uniqueevents{e});
    ax(1).Title.Position(1) = cfg.window(1);
    ax(1).Title.Position(2) = ax(1).YLim(2);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    h.avgonsetmarker.YData = ax(1).YLim;
    for j = 1:length(h.timepointline)
        h.timepointtext(j).Position(2) = ax(1).YLim(2)+range(ax(1).YLim).*0.25;
        h.timepointline(j).YData = [ax(1).YLim, ax(1).YLim(2)+range(ax(1).YLim).*0.20];
    end
    % -----------------------------------------------------------------
    % TOPOPLOTS
    for j = 1:length(cfg.timepoints)
        [~, idx_t] = min(abs(avg.time - cfg.timepoints(j)));
        [~, CData] = topoplot(tmp(idx_t, :), cfg.chanlocs, 'noplot', 'on', 'colormap', cfg.colormap);
        CData(isnan(h.topoplots(j).h.toposurf.CData)) = nan;
        h.topoplots(j).h.toposurf.CData = CData;
        ax(j+2).CLim = ax(1).YLim;
    end        
    h.colorbar.Limits = ax(1).YLim;
    h.colorbar.Ticks = [0, ax(1).YLim(2)];
    % -----------------------------------------------------------------
    outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-trialsacrosschans_source-', cfg.source, '_event-', cfg.uniqueevents{e}, '_nirs']);
    drawnow();
    exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 144);
end

close(fig);

end