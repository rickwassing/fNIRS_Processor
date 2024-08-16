function [cfg] = graph_init(data, measlist, cfg)
% -------------------------------------------------------------------------
cfg.uniqueevents = unique(data.info.events.type);
cfg.numuniqueevents = length(cfg.uniqueevents);
for i = 1:length(cfg.uniqueevents)
    cfg.ntrials(i) = sum(strcmpi(data.info.events.type, cfg.uniqueevents{i}));
end
% -------------------------------------------------------------------------
if ~isfield(cfg, 'colormap')
    cfg.colormap = load('colormap_roma.mat');
    cfg.colormap = cfg.colormap.roma;
end
% -------------------------------------------------------------------------
[cfg.chanlist, cfg.chanindex] = getchannellist(measlist);
% -------------------------------------------------------------------------
cfg = hmr2chanlocs(data, cfg);
% -------------------------------------------------------------------------
% Remove short channels
cfg.chanlist([cfg.chanlocs.distance] < cfg.sschandist) = [];
cfg.chanindex([cfg.chanlocs.distance] < cfg.sschandist, :) = [];
cfg.chanlocs([cfg.chanlocs.distance] < cfg.sschandist) = [];
% -------------------------------------------------------------------------
cfg.outputdir = strrep(fileparts(data.info.outputfile), [filesep, 'nirs'], [filesep, 'qc']);
[~, cfg.outputfilename] = fileparts(data.info.outputfile);
if exist(cfg.outputdir, 'dir') == 0
    mkdir(cfg.outputdir)
end
% -------------------------------------------------------------------------
end