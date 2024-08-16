% FNI_GRAPHTRIALQUALITY
%
% Usage:
%   >> fni_graphtrialquality(data);
%
% Inputs:
%   'data.raw' - [DataClass] Homer3 data class
%   'data.dod' - [DataClass] Homer3 data class
%   'data.dod_psa' - [DataClass] Homer3 data class
%   'data.dc' - [DataClass] Homer3 data class
%   'data.quality' - [DataClass] Homer3 data class
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

function fni_graphtrialquality(data, cfg)
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing signal quality for each trial.\n');
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Get the channel list and their indices
[chanlist, chanindex] = getchannellist(data.dod.measurementList);
chanlist = cellfun(@(s) strsplit(s, '-'), chanlist, 'UniformOutput', false);
cfg.opto = ft_read_sens(data.info.outputfile, 'senstype', 'nirs', 'readbids', 'yes');
cfg.skipscale = 'yes';
cfg.skipcomnt = 'yes';
cfg.layout = ft_prepare_layout(cfg);
cfg.outputdir = strrep(fileparts(data.info.outputfile), [filesep, 'nirs'], [filesep, 'qc']);
[~, cfg.outputfilename] = fileparts(data.info.outputfile);
if exist(cfg.outputdir, 'dir') == 0
    mkdir(cfg.outputdir)
end
% =========================================================================
% Extract events and some data properties
events = data.info.events(ismember(data.info.events.type, cfg.eventlabels));
fs = round(1/mean(diff(data.dod.time)));
pnts = length(data.dod.time);
window = round(cfg.window .* fs);
% -------------------------------------------------------------------------
% For each event...
for e = 1:length(events)
    type = data.info.events.type{e};
    onset = round(data.info.events.onset(e)); % TODO, what if an event occurred off-sample? Upsample?
    latency = onset.*fs;
    win = window + latency;
    if any(win < 1) || any(win > pnts)
        fprintf(2, '>> FNI: Event ''%s'', trial %i, onset %.3f s, is out of bounds. This event is skipped.\n', events.type{e}, e, events.onset(e))
        continue
    end
    win = win(1):win(2);
    % =====================================================================
    % Create a figure to show the event data
    for i = 1:length(chanlist)
        % -----------------------------------------------------------------
        fig = figure();
        fig.Color = 'w';
        fig.Units = 'pixels';
        fig.Position(3:4) = [250, 360];
        % -----------------------------------------------------------------
        % LAYOUT
        ax = axes(fig); %#ok<LAXES>
        ax.NextPlot = 'add';
        ax.Toolbar = [];
        ax.XColor = 'w';
        ax.YColor = 'w';
        ax.Position = [0/12, 10/12, 6/12, 2/12];
        ax.PlotBoxAspectRatio = [1, 1, 1];
        ax.XLim = [-max(abs(cfg.layout.pos(:))), max(abs(cfg.layout.pos(:)))];
        ax.YLim = [-max(abs(cfg.layout.pos(:))), max(abs(cfg.layout.pos(:)))];
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XData = cfg.layout.pos(:, 2);
        YData = cfg.layout.pos(:, 1);
        plot(ax, XData, YData, '.', 'MarkerSize', 5, 'Color', [0.44, 0.45, 0.46]);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XData = cfg.layout.pos(strcmpi(cfg.layout.label, chanlist{i}{1}) | strcmpi(cfg.layout.label, chanlist{i}{2}), 2);
        YData = cfg.layout.pos(strcmpi(cfg.layout.label, chanlist{i}{1}) | strcmpi(cfg.layout.label, chanlist{i}{2}), 1);
        plot(ax, XData, YData, '.', 'MarkerSize', 10, 'Color', [0, 0, 0]);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        plot(ax, mean(XData), mean(YData), '.', 'MarkerSize', 10, 'Color', ax.ColorOrder(1, :));
        % -----------------------------------------------------------------
        % INFO
        XData = max(abs(cfg.layout.pos(:))).*1.5;
        YData = max(abs(cfg.layout.pos(:)));
        text(ax, XData, YData, sprintf('Channel: %s-%s\nEvent: ''%s''\nTrial: %i\nOnset: %.3f s\nSQI: %.1f', chanlist{i}{1}, chanlist{i}{2}, type, e, onset, mean(data.quality.sqi(win, i))), ...
            'Color', [0.14, 0.15, 0.16], ...
            'FontSize', 8, ...
            'VerticalAlignment', 'top')
        % -----------------------------------------------------------------
        % RAW AND BPFILT OPTICAL DENSITY
        ax = axes(fig); %#ok<LAXES>
        ax.NextPlot = 'add';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cidx = find(...
            [data.dod.measurementList.sourceIndex] == chanindex(i, 1) & ...
            [data.dod.measurementList.detectorIndex] == chanindex(i, 2) & ...
            [data.dod.measurementList.wavelengthIndex] == max([data.dod.measurementList.wavelengthIndex]));
        XData = data.dod.time(win);
        for j = 1:length(cidx)
            YData = data.dod.dataTimeSeries(win, cidx(j));
            plot(ax, XData, YData, '-', 'LineWidth', 1, 'Color', [0.34, 0.35, 0.36]);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cidx = find(...
            [data.dod_bpfilt.measurementList.sourceIndex] == chanindex(i, 1) & ...
            [data.dod_bpfilt.measurementList.detectorIndex] == chanindex(i, 2));
        XData = data.dod_bpfilt.time(win);
        clear h;
        leg = {};
        for j = 1:length(cidx)
            leg{j} = sprintf('%i', data.raw.probe.wavelengths(data.dod_bpfilt.measurementList(cidx(j)).wavelengthIndex)); %#ok<AGROW>
            YData = data.dod_bpfilt.dataTimeSeries(win, cidx(j));
            h(j) = plot(ax, XData, YData, '-', 'LineWidth', 1.5);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XLim = [min([ax.Children.XData]), max([ax.Children.XData])];
        YLim = [-max(abs([ax.Children.YData])), max(abs([ax.Children.YData]))];
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XData = data.dod_bpfilt.time(win(1)+abs(window(1)));
        plot(ax, [XData, XData], YLim, '--', 'LineWidth', 0.5, 'Color', [0.55, 0.56, 0.57]);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ax.Toolbar = [];
        ax.Box = 'on';
        ax.TickDir = 'out';
        ax.TickLength = [0, 0];
        ax.Color = [0.83, 0.84, 0.86];
        ax.YGrid = 'on';
        ax.GridColor = 'w';
        ax.GridAlpha = 1;
        ax.OuterPosition = [0/12, 5/12, 12/12, 5/12];
        ax.XTick = [];
        ax.XLim = XLim;
        ax.YLim = YLim;
        ax.YTick = [0, YLim(2)];
        ax.FontSize = 8;
        ax.TitleFontSizeMultiplier = 1;
        ax.LabelFontSizeMultiplier = 1;
        ax.YLabel.String = 'Optical Density';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        leg = legend(h, leg, 'Orientation', 'horizontal');
        leg.Position(1:2) = [ax.Position(1)+ax.Position(3)-leg.Position(3), ax.Position(2)+ax.Position(4)];
        leg.Color = 'none';
        leg.EdgeColor = 'none';
        % -----------------------------------------------------------------
        % HEMOGLOBIN CONCENTRATION
        ax = axes(fig); %#ok<LAXES>
        ax.NextPlot = 'add';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cidx = find(...
            [data.dc.measurementList.sourceIndex] == chanindex(i, 1) & ...
            [data.dc.measurementList.detectorIndex] == chanindex(i, 2));
        XData = data.dc.time(win);
        clear h;
        leg = {};
        for j = 1:length(cidx)
            leg{j} = data.dc.measurementList(cidx(j)).dataTypeLabel; %#ok<AGROW>
            YData = data.dc.dataTimeSeries(win, cidx(j));
            h(j) = plot(ax, XData, YData, '-', 'LineWidth', 1.5);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XLim = [min([ax.Children.XData]), max([ax.Children.XData])];
        YLim = [-max(abs([ax.Children.YData])), max(abs([ax.Children.YData]))];
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        XData = data.dc.time(win(1)+abs(window(1)));
        plot(ax, [XData, XData], YLim, '--', 'LineWidth', 0.5, 'Color', [0.55, 0.56, 0.57]);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ax.Toolbar = [];
        ax.Box = 'on';
        ax.TickDir = 'out';
        ax.TickLength = [0, 0];
        ax.Color = [0.83, 0.84, 0.86];
        ax.YGrid = 'on';
        ax.GridColor = 'w';
        ax.GridAlpha = 1;
        ax.OuterPosition = [0/12, 0/12, 12/12, 5/12];
        ax.XTick = data.dc.time([win(1), win(1)+abs(window(1)), win(end)]);
        ax.XLim = XLim;
        ax.YLim = YLim;
        ax.YTick = [0, YLim(2)];
        ax.FontSize = 8;
        ax.TitleFontSizeMultiplier = 1;
        ax.LabelFontSizeMultiplier = 1;
        ax.YLabel.String = '\Delta [Hemoglobin]';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        leg = legend(h, leg, 'Orientation', 'horizontal');
        leg.Position(1:2) = [ax.Position(1)+ax.Position(3)-leg.Position(3), ax.Position(2)+ax.Position(4)];
        leg.Color = 'none';
        leg.EdgeColor = 'none';
        % -----------------------------------------------------------------
        outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-qc_chan-', strjoin(chanlist{i}, ''), '_event-', type, '_trial-', num2str(e),'_nirs']);
        exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 600);
        close all
    end
end

end