% FNI_GRAPHAVG
%
% Usage:
%   >> fni_graphavg(avg, std);
%
% Inputs:
%   'avg' - [DataClass] Homer3 data class
%   'std' - [DataClass] Homer3 data class
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

function fni_graphavg(avg, std, cfg) %#ok<INUSD>
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing averages and standard deviations.\n');
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Get the channel list and their indices
[chanlist, chanindex] = getchannellist(avg.measurementList);
chanlist = cellfun(@(s) strsplit(s, '-'), chanlist, 'UniformOutput', false);
% =========================================================================
% Initialize the figure
% -------------------------------------------------------------------------
% Figure
fig = figure();
fig.Color = 'w';
fig.Units = 'pixels';
fig.Position(3:4) = [260, 260];
% -------------------------------------------------------------------------
% Axes
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ax(1) = axes(fig);
ax(1).NextPlot = 'add';
ax(1).Toolbar = [];
ax(1).Box = 'on';
ax(1).TickDir = 'out';
ax(1).TickLength = [0, 0];
ax(1).Color = [0.83, 0.84, 0.86];
ax(1).XGrid = 'on';
ax(1).GridColor = 'w';
ax(1).GridAlpha = 1;
ax(1).MinorGridLineStyle = 'none';
ax(1).OuterPosition = [0/12, 0/12, 12/12, 12/12];
ax(1).XTick = 0;
ax(1).YTick = [];
ax(1).FontSize = 8;
ax(1).TitleFontSizeMultiplier = 1;
ax(1).LabelFontSizeMultiplier = 1;
ax(1).XLabel.String = 'Time (s)';
ax(1).YLabel.String = '\Delta [Hemoglobin]';
% =========================================================================
% Initalize plots
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
handles = [];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
numavgchans = sum(...
    [avg.measurementList.sourceIndex] == avg.measurementList(1).sourceIndex & ...
    [avg.measurementList.detectorIndex] == avg.measurementList(1).detectorIndex);
for i = 1:numavgchans
    handles.std(i) = patch(ax(1), nan, nan, nan, ...
        'LineStyle', 'none', ...
        'FaceAlpha', 0.1);
    handles.avg(i) = plot(ax(1), nan, nan, '-', 'Color', 'k', 'LineWidth', 1.5);
    handles.leg(i) = text(ax(1), nan, nan, '', ...
        'Color', [0.55, 0.56, 0.57], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'middle');
end
ax(1).Children = flipud(ax(1).Children);
% =========================================================================
for i = 1:length(chanlist)
    % ---------------------------------------------------------------------
    % AVERAGED RESPONSE
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    cidx = find(...
        [avg.measurementList.sourceIndex] == chanindex(i, 1) & ...
        [avg.measurementList.detectorIndex] == chanindex(i, 2));
    XData = ascolumn(avg.time);
    YLim = [Inf, -Inf];
    for j = 1:length(cidx)
        YData = avg.dataTimeSeries(:, cidx(j));
        EData = std.dataTimeSeries(:, cidx(j));
        switch lower(avg.measurementList(cidx(j)).dataTypeLabel)
            case 'hrf hbo'
                Color = [0.8500, 0.3250, 0.0980]; % red
            case 'hrf hbr'
                Color = [0.0000, 0.4470, 0.7410]; % blue
            otherwise
                continue
        end
        handles.avg(j).XData = XData;
        handles.avg(j).YData = YData;
        handles.avg(j).Color = Color;
        handles.std(j).XData = [XData; flipud(XData)];
        handles.std(j).YData = [YData+EData; flipud(YData-EData)];
        handles.std(j).FaceColor = Color;
        handles.leg(j).Position(1:2) = [XData(end), YData(end)];
        handles.leg(j).String = [' ', num2str(avg.measurementList(cidx(j)).dataTypeIndex)];
        if min(YData-EData) < YLim(1)
            YLim(1) = min(YData-EData);
        end
        if max(YData+EData) > YLim(2)
            YLim(2) = max(YData+EData);
        end
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ax(1).XLim = [XData(1), XData(end)];
    ax(1).XTick = sort([0, ax(1).XLim]);
    ax(1).YLim = YLim;
    ax(1).YTick = sort([0, YLim]);
    % ---------------------------------------------------------------------
    % outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-average_chan-', strjoin(chanlist{i}, ''), '_nirs']);
    % drawnow();
    % exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 144);
end
% close all

end