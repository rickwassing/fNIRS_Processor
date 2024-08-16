% FNI_GRAPHGLMTIMESERIES
%
% Usage:
%   >> fni_graphglmtimeseries(data);
%
% Inputs:
%   'data.dc' - [DataClass] Homer3 data class
%   'data.glm' - [DataClass] Homer3 data class
%   'data.info' - [struct] configuration settings
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

function fni_graphglmtimeseries(data)
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing GLM timeseries.\n');
% =========================================================================
% INIT
% -------------------------------------------------------------------------
cfg = graph_init(data, data.dod.measurementList, []);
cfg.chanlist = cellfun(@(s) strsplit(s, '-'), cfg.chanlist, 'UniformOutput', false);
cfg.nbchan = 1;
cfg.nidx = find(strcmpi(data.glm.stats.beta_label, 'Aux'));
cfg.numnuisance = length(cfg.nidx);
% =========================================================================
% Initialize the figure and handles
% -------------------------------------------------------------------------
h = [];
% -------------------------------------------------------------------------
% Figure
src = groot();
fig = graph_figure([1, 1, src.ScreenSize(3), 250]);
% -------------------------------------------------------------------------
% Axes and plots
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(1), h] = graph_layout(cfg, fig, h);
ax(1).Position = [0/12, 0/12, 1.6/12, 12/12];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(2), h] = graph_events(data, cfg, fig, h);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(3), h] = graph_nuisance(data, cfg, fig, h);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(4), h] = graph_dc(data, cfg, fig, h);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
remspace = 1 - ax(2).OuterPosition(4);
divider = cfg.numnuisance + 3;
ax(2).OuterPosition(1:3) = [1/12, 1 - ax(2).OuterPosition(4), 11/12];
ax(3).OuterPosition = [1/12, 3/divider*remspace, 11/12, cfg.numnuisance/divider*remspace];
ax(4).OuterPosition = [1/12, 0/12, 11/12, 3/divider*remspace];
h.leg(1).Position(1:2) = [ax(4).Position(1)+ax(4).Position(3), ax(4).Position(2)+ax(4).Position(4)-h.leg(1).Position(4)];
% =========================================================================
for i = 1:length(cfg.chanlist)
    % ---------------------------------------------------------------------
    % UPDATE LAYOUT
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Highlight the current channel
    set(findobj(ax(1).Children, 'Type', 'text'), 'Color', [0.44, 0.45, 0.46])
    h.tmp = findobj(ax(1).Children, 'String', upper(cfg.chanlist{i}{1}));
    h.tmp.Color = 'k';
    h.tmp = findobj(ax(1).Children, 'String', upper(cfg.chanlist{i}{2}));
    h.tmp.Color = 'k';
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Get the channel location
    YData = mean([...
        cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{1}), 1), ...
        cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{2}), 1)]);
    XData = mean([...
        cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{1}), 2), ...
        cfg.layout.pos(strcmpi(cfg.layout.label, cfg.chanlist{i}{2}), 2)]);
    h.chanloc.XData = XData;
    h.chanloc.YData = YData;
    % ---------------------------------------------------------------------
    % NUISANCE REGRESSORS
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    cidx = find(...
        [data.dc.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
        [data.dc.measurementList.detectorIndex] == cfg.chanindex(i, 2) & ...
        strcmpi({data.dc.measurementList.dataTypeLabel}, 'hbo'));
    XData = data.dc.time;
    YLim = [Inf, -Inf];
    ThisYOffset = 0;
    for j = 1:length(cfg.nidx)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        Beta = data.glm.beta(cfg.nidx(j), cidx);
        YDataDC = data.dc.dataTimeSeries(:, cidx).*1000000;
        YDataAux = data.glm.stats.desmat(:, cfg.nidx(j)).*1000000 .* Beta;
        ThisYOffset = ThisYOffset + abs(min([YDataDC; YDataAux]));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.chan(1).origdc(j).XData = XData;
        h.chan(1).origdc(j).YData = YDataDC + ThisYOffset;
        h.chan(1).aux(j).XData = XData;
        h.chan(1).aux(j).YData = YDataAux + ThisYOffset;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if min([YDataDC; YDataAux] + ThisYOffset) < YLim(1)
            YLim(1) = min([YDataDC; YDataAux] + ThisYOffset);
        end
        if max([YDataDC; YDataAux] + ThisYOffset) > YLim(2)
            YLim(2) = max([YDataDC; YDataAux] + ThisYOffset);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ThisYOffset = ThisYOffset + abs(max([YDataDC; YDataAux]));
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ax(3).YLim = YLim;
    ax(3).YTick = YLim(2);
    % ---------------------------------------------------------------------
    % HEMOGLOBIN CONCENTRATION
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    dCData = data.glm.dc.GetDataTimeSeries('reshape').*1000000;
    XData = data.glm.dc.time;
    YLim = [Inf, -Inf];
    ThisYOffset = 0;
    for j = 1:2
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        YData = dCData(:, j, i);
        % ThisYOffset = ThisYOffset + abs(min(YData));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.chan(1).dc(j).XData = XData;
        h.chan(1).dc(j).YData = YData + ThisYOffset;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if min(YData + ThisYOffset) < YLim(1)
            YLim(1) = min(YData + ThisYOffset);
        end
        if max(YData + ThisYOffset) > YLim(2)
            YLim(2) = max(YData + ThisYOffset);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % ThisYOffset = ThisYOffset + abs(max(YData));
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ax(4).YLim = YLim;
    ax(4).YTick = YLim(2);
    % ---------------------------------------------------------------------
    outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-glmtimeseries_chan-', strjoin(cfg.chanlist{i}, ''), '_nirs']);
    drawnow();
    exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 144);
end

close(fig);

end