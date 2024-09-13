% FNI_GRAPHTRIALSWITHINCHAN
%
% Usage:
%   >> fni_graphtrialswithinchan(data, cfg);
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

function fni_graphtrialswithinchan(data, cfg)
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing trials within each channel.\n');
% =========================================================================
% INIT
% -------------------------------------------------------------------------
cfg = graph_init(data, data.dod.measurementList, cfg);
cfg.chanlist = cellfun(@(s) strsplit(s, '-'), cfg.chanlist, 'UniformOutput', false);
cfg.axheight = 100;
cfg.nbchan = 1;
if ~isfield(cfg, 'timepoints')
    cfg.timepoints = [];
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
fig = graph_figure([1, 1, min([src.ScreenSize(3), range(cfg.window).*25]), cfg.axheight+cfg.axheight+9*cfg.ntrials(1)]);
% -------------------------------------------------------------------------
% Axes and plots
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(1), h] = graph_layout(cfg, fig, h);
ax(1).Position = [0/12, 0/12, 12/12, 12/12];
ax(1).Units = 'pixels';
ax(1).Position([2, 4]) = [sum(ax(1).Position([2, 4]))-cfg.axheight, cfg.axheight];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(2), h] = graph_trials(cfg, fig, h);
ax(2).Units = 'pixels';
ax(2).Position([2, 4]) = [cfg.axheight, 9*cfg.ntrials(1)];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(3), h] = graph_avgtrial(cfg, fig, h);
ax(3).Units = 'pixels';
ax(3).OuterPosition([2, 4]) = [1, cfg.axheight];
ax(2).Position(3) = ax(2).Position(3) - (ax(3).Position(1) - ax(2).Position(1));
ax(2).Position(1) = ax(3).Position(1);
ax(3).Position(3) = ax(2).Position(3);
h.leg.Units = 'pixels';
h.leg.Position(1:2) = [ax(3).Position(1) + ax(3).Position(3), ax(3).Position(2) + ax(3).Position(4) - h.leg.Position(4)];
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
    [avg, std, ~, ~, trials] = fni_blockavg(source, stim, cfg.window);
    trials = trials.yblk;
    % ---------------------------------------------------------------------
    % UPDATE FIGURE AND AXES DIMENSIONS
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    fig.Position(4) = cfg.axheight+cfg.axheight+9*cfg.ntrials(e);
    ax(1).Position([2, 4]) = [fig.Position(4)-cfg.axheight, cfg.axheight];
    ax(2).Position([2, 4]) = [cfg.axheight, 9*cfg.ntrials(e)];
    ax(2).Title.String = sprintf('Source: %s\nEvent: %s', cfg.source, cfg.uniqueevents{e});
    ax(2).Title.Position(1) = cfg.window(1);
    ax(2).Title.HorizontalAlignment = 'left';
    % =====================================================================
    for i = 1:length(cfg.chanlist)
        % -----------------------------------------------------------------
        % Get channel index
        cidxhbo = find(...
            [source.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
            [source.measurementList.detectorIndex] == cfg.chanindex(i, 2) & ...
            strcmpi({source.measurementList.dataTypeLabel}, 'hbo'));
        cidxhbr = find(...
            [source.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
            [source.measurementList.detectorIndex] == cfg.chanindex(i, 2) & ...
            strcmpi({source.measurementList.dataTypeLabel}, 'hbr'));
        % -----------------------------------------------------------------
        % UPDATE LAYOUT
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Title
        ax(1).Title.String = sprintf('%s-%s', cfg.chanlist{i}{1}, cfg.chanlist{i}{2});
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Highlight the current channel
        set(findobj(ax(1).Children, 'Type', 'text'), 'Color', [0.44, 0.45, 0.46])
        h.tmp = findobj(ax(1).Children, 'String', upper(cfg.chanlist{i}{1}));
        h.tmp.Color = 'k';
        h.tmp = findobj(ax(1).Children, 'String', upper(cfg.chanlist{i}{2}));
        h.tmp.Color = 'k';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Get the channel location
        YData = mean([...
            cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{1}), 1), ...
            cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{2}), 1)]);
        XData = mean([...
            cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{1}), 2), ...
            cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{2}), 2)]);
        h.chanloc.XData = XData;
        h.chanloc.YData = YData;
        % -----------------------------------------------------------------
        % UPDATE TRIAL IMAGE
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.trialimage.XData = avg.time;
        h.trialimage.YData = 1:size(trials, 4);
        h.trialimage.CData = squeeze(trials(:, 1, i, :))' .* 1000000;
        try
            ax(2).YLim = [1, size(trials, 4)] + [-0.5, 0.5];
        catch
            ax(2).YLim = [-0.5, 0.5];
        end
        ax(2).YTick = 1:size(trials, 4);
        try
            ax(2).CLim = [-1 * max(abs(h.trialimage.CData(:))), max(abs(h.trialimage.CData(:)))];
        catch
            ax(2).CLim = [-1, 1];
        end
        h.colorbar.Limits = ax(2).CLim;
        % -----------------------------------------------------------------
        % UPDATE AVERAGE TRACE
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.hbravgtrial.XData = avg.time;
        h.hbravgtrial.YData = avg.dataTimeSeries(:, cidxhbr).*1000000;
        h.hbrstdtrial.XData = ascolumn([avg.time, fliplr(avg.time)]);
        h.hbrstdtrial.YData = [avg.dataTimeSeries(:, cidxhbr) - std.dataTimeSeries(:, cidxhbr); flipud(avg.dataTimeSeries(:, cidxhbr) + std.dataTimeSeries(:, cidxhbr))];
        h.hbrstdtrial.YData = h.hbrstdtrial.YData.*1000000;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.hboavgtrial.XData = avg.time;
        h.hboavgtrial.YData = avg.dataTimeSeries(:, cidxhbo).*1000000;
        h.hbostdtrial.XData = ascolumn([avg.time, fliplr(avg.time)]);
        h.hbostdtrial.YData = [avg.dataTimeSeries(:, cidxhbo) - std.dataTimeSeries(:, cidxhbo); flipud(avg.dataTimeSeries(:, cidxhbo) + std.dataTimeSeries(:, cidxhbo))];
        h.hbostdtrial.YData = h.hbostdtrial.YData.*1000000;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        try
            ax(3).YLim = [-1*max(abs([h.hbostdtrial.YData;h.hbrstdtrial.YData])), max(abs([h.hbostdtrial.YData;h.hbrstdtrial.YData]))];
        catch
            ax(3).YLim = [-1, 1];
        end
        ax(3).YTick = ax(3).YLim(2);
        % -----------------------------------------------------------------
        % UPDATE TRIAL ONSET MARKERS
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.trialonsetmarker.YData = ax(2).YLim;
        h.avgonsetmarker.YData = ax(3).YLim;
        % -----------------------------------------------------------------
        outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-trialswithinchan_source-', cfg.source, '_chan-', strjoin(cfg.chanlist{i}, ''), '_event-', cfg.uniqueevents{e}, '_nirs']);
        drawnow();
        exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 144);
    end
end

close(fig);

end