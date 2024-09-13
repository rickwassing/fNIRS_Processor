% FNI_GRAPHCHANNELQUALITY
%
% Usage:
%   >> fni_graphchannelquality(data);
% 
% Inputs:
%   'data.info' - [struct] configuration settings
%   'data.raw' - [DataClass] Homer3 data class
%   'data.dod' - [DataClass] Homer3 data class
%   'data.dod_psa' - [DataClass] Homer3 data class
%   'data.dc' - [DataClass] Homer3 data class
%   'data.quality' - [DataClass] Homer3 data class
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

function fni_graphchannelquality(data)
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: graphing signal quality.\n');
% =========================================================================
% INIT
% -------------------------------------------------------------------------
cfg = graph_init(data, data.dod.measurementList, []);
cfg.chanlist = cellfun(@(s) strsplit(s, '-'), cfg.chanlist, 'UniformOutput', false);
cfg.nbchan = 1;
% =========================================================================
% Initialize the figure and handles
% -------------------------------------------------------------------------
h = [];
datafields = fieldnames(data);
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
[ax(2), h] = graph_dod(data, cfg, fig, h);
ax(2).OuterPosition = [1/12, 8/12, 8/12, 4/12];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(3), h] = graph_dc(data, cfg, fig, h);
ax(3).OuterPosition = [1/12, 3/12, 8/12, 4/12];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(4), h] = graph_sci(data, fig, h);
ax(4).OuterPosition = [1/12, 0/12, 8/12, 4/12];
ax(4).XTick = floor(ax(4).XLim(2));
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(5), h] = graph_psd(data, fig, h);
ax(5).OuterPosition = [9/12, 0/12, 3/12, 12/12];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ax(6), h] = graph_events(data, cfg, fig, h);
ax(6).OuterPosition(1:3) = [1/12, 1 - ax(6).OuterPosition(4), 8/12];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
remspace = 1 - ax(6).OuterPosition(4);
ax(4).OuterPosition(4) = remspace * 4/12;
ax(3).OuterPosition(2) = ax(4).OuterPosition(2) + ax(4).OuterPosition(4);
ax(3).OuterPosition(4) = remspace * 4/12;
ax(2).OuterPosition(2) = ax(3).OuterPosition(2) + ax(3).OuterPosition(4);
ax(2).OuterPosition(4) = remspace * 4/12;
h.leg(1).Position(1:2) = [ax(2).Position(1)+ax(2).Position(3), ax(2).Position(2)+ax(2).Position(4)-h.leg(1).Position(4)];
h.leg(2).Position(1:2) = [ax(3).Position(1)+ax(3).Position(3), ax(3).Position(2)+ax(3).Position(4)-h.leg(2).Position(4)];
% =========================================================================
for i = 1:length(cfg.chanlist)
    % ---------------------------------------------------------------------
    % UPDATE LAYOUT
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Title
    ax(1).Title.String = sprintf('%s-%s', cfg.chanlist{i}{1}, cfg.chanlist{i}{2});
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
    % OPTICAL DENSITY
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    fld = datafields{contains(datafields, '_bpfilt')};
    cidx = find(...
        [data.dod.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
        [data.dod.measurementList.detectorIndex] == cfg.chanindex(i, 2));
    XData = data.dod.time;
    YLim = [Inf, -Inf];
    ThisYOffset = 0;
    for j = 1:length(cidx)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        YData_raw = data.dod.dataTimeSeries(:, cidx(j)).*1000;
        YData_preproc = data.(fld).dataTimeSeries(:, cidx(j)).*1000;
        ThisYOffset = ThisYOffset + abs(min([YData_raw; YData_preproc]));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        hidx = data.(fld).measurementList(cidx(j)).wavelengthIndex;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.chan(1).dod_raw(hidx).XData = XData;
        h.chan(1).dod_raw(hidx).YData = YData_raw + ThisYOffset;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.chan(1).dod_preproc(hidx).XData = XData;
        h.chan(1).dod_preproc(hidx).YData = YData_preproc + ThisYOffset;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if min([YData_raw; YData_preproc] + ThisYOffset) < YLim(1)
            YLim(1) = min([YData_raw; YData_preproc] + ThisYOffset);
        end
        if max([YData_raw; YData_preproc] + ThisYOffset) > YLim(2)
            YLim(2) = max([YData_raw; YData_preproc] + ThisYOffset);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ThisYOffset = ThisYOffset + abs(max([YData_raw; YData_preproc]));
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    try
        ax(2).YLim = YLim;
    catch
        ax(2).YLim = [0, 1];
    end
    ax(2).YTick = YLim(2);
    % ---------------------------------------------------------------------
    % HEMOGLOBIN CONCENTRATION
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    dtypes = unique({data.dc.measurementList.dataTypeLabel}, 'stable');
    cidx = find(...
        [data.dc.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
        [data.dc.measurementList.detectorIndex] == cfg.chanindex(i, 2));
    XData = data.dc.time;
    YLim = [Inf, -Inf];
    ThisYOffset = 0;
    for j = 1:length(cidx)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        YData = data.dc.dataTimeSeries(:, cidx(j)).*1000000;
        %ThisYOffset = ThisYOffset + abs(min(YData));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        hidx = find(strcmpi(data.dc.measurementList(cidx(j)).dataTypeLabel, dtypes));
        h.chan(1).dc(hidx).XData = XData;
        h.chan(1).dc(hidx).YData = YData + ThisYOffset;
        if min(YData + ThisYOffset) < YLim(1)
            YLim(1) = min(YData + ThisYOffset);
        end
        if max(YData + ThisYOffset) > YLim(2)
            YLim(2) = max(YData + ThisYOffset);
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        %ThisYOffset = ThisYOffset + abs(max(YData));
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    try
        ax(3).YLim = YLim;
    catch 
        ax(3).YLim = [0, 1];
    end
    ax(3).YTick = YLim(2);
    % ---------------------------------------------------------------------
    % SIGNAL QUALITY
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    h.sqi.XData = data.dc.time;
    h.sqi.YData = data.quality.sci(:, i);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    h.sqi_lo.XData = [data.dc.time(1), data.dc.time(end), data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1))];
    h.sqi_lo.YData = [min(data.quality.sci(:, i)), min(data.quality.sci(:, i)), -1];
    h.sqi_text_lo.Position(1:2) = [data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1)), -1];
    h.sqi_text_lo.String = sprintf('%.2f', min(data.quality.sci(:, i)));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    h.sqi_hi.XData = [data.dc.time(1), data.dc.time(end), data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1))];
    h.sqi_hi.YData = [max(data.quality.sci(:, i)), max(data.quality.sci(:, i)), 1];
    h.sqi_text_hi.Position(1:2) = [data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1)), 1];
    h.sqi_text_hi.String = sprintf('%.2f', max(data.quality.sci(:, i)));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    h.sqi_mu.XData = [data.dc.time(end), data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1))];
    h.sqi_mu.YData = [mean(data.quality.sci(:, i), 'omitnan'), 0];
    h.sqi_text_mu.Position(1:2) = [data.dc.time(end)+1/24.*(data.dc.time(end)-data.dc.time(1)), 0];
    h.sqi_text_mu.String = sprintf('%.2f', mean(data.quality.sci(:, i), 'omitnan'));
    % ---------------------------------------------------------------------
    % POOR QUALITY TIME PERIODS
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    cidx = find(...
        [data.dod.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
        [data.dod.measurementList.detectorIndex] == cfg.chanindex(i, 2));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    is_reject = any((data.quality.isclean(:, cidx) == 0)');
    isrej_up = find(diff([0, is_reject, 0]) == 1);
    isrej_do = find(diff([0, is_reject, 0]) == -1)-1;
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    for j = 1:length(h.reject)
        YLim = h.reject(j).Parent.YLim;
        XData = data.dod.time([1, isrej_up, isrej_up, isrej_do, isrej_do, length(is_reject)]);
        YData = [...
            YLim(1), ...
            YLim(1).*ones(1, length(isrej_up)), ...
            YLim(2).*ones(1, length(isrej_up)), ...
            YLim(2).*ones(1, length(isrej_do)), ...
            YLim(1).*ones(1, length(isrej_do)), ...
            YLim(1)];
        [XData, idx] = sort(XData);
        YData = YData(idx);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        h.reject(j).XData = XData;
        h.reject(j).YData = YData;
    end
    % ---------------------------------------------------------------------
    % POWER SPECTRUM
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    cidx = find(...
        [data.dod.measurementList.sourceIndex] == cfg.chanindex(i, 1) & ...
        [data.dod.measurementList.detectorIndex] == cfg.chanindex(i, 2));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if ~any(contains(datafields, '_psa'))
        XData = [NaN, NaN];
    else
        fld = datafields{contains(datafields, '_psa')};
        XData = data.(fld).freq;
    end
    for j = 1:length(cidx)
        if ~any(contains(datafields, '_psa'))
            YData = [NaN, NaN];
        else
            YData = data.(fld).pow(:, cidx(j));
        end
        hidx = data.dod.measurementList(cidx(j)).wavelengthIndex;
        h.psd(hidx).XData = XData;
        h.psd(hidx).YData = YData;
    end
    ax(5).XLim = [XData(2), XData(end)];
    try
        ax(5).YLim = [min([h.psd.YData]), max([h.psd.YData])];
    catch
        ax(5).YLim = [0, 1];
    end
    % ---------------------------------------------------------------------
    outputfile = strrep(cfg.outputfilename, '_nirs', ['_desc-qc_chan-', strjoin(cfg.chanlist{i}, ''), '_nirs']);
    drawnow();
    exportgraphics(fig, fullfile(cfg.outputdir, [outputfile, '.png']), 'Resolution', 144);
end

close(fig);

end