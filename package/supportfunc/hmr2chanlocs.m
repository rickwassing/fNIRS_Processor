function cfg = hmr2chanlocs(data, cfg)
if nargin < 2
    cfg = [];
end
if ~isfield(cfg, 'chanlist')
    error('>> FNI: Configuration struct must contain the ''chanlist'' field.')
end
if ~isfield(cfg, 'sschandist')
    cfg.sschandist = 0;
end
cfg.opto = ft_read_sens(data.info.outputfile, 'senstype', 'nirs', 'readbids', 'yes');
cfg.skipscale = 'yes';
cfg.skipcomnt = 'yes';
cfg.layout = ft_prepare_layout(cfg);
cfg.chanlocs = struct();
sd = cellfun(@(lbl) strsplit(lbl, '-'), cfg.chanlist, 'UniformOutput', false);
for i = 1:length(cfg.chanlist)
    idx = [find(strcmpi(cfg.layout.label, sd{i}(1))), find(strcmpi(cfg.layout.label, sd{i}(2)))];
    cfg.chanlocs(i).labels = cfg.chanlist{i};
    cfg.chanlocs(i).Y = mean([cfg.opto.optopos(idx(1), 1), cfg.opto.optopos(idx(2), 1)]);
    cfg.chanlocs(i).X = mean([cfg.opto.optopos(idx(1), 2), cfg.opto.optopos(idx(2), 2)]);
    cfg.chanlocs(i).Z = mean([cfg.opto.optopos(idx(1), 3), cfg.opto.optopos(idx(2), 3)]);
    cfg.chanlocs(i).distance = sqrt(...
        (cfg.opto.optopos(idx(1), 1) - cfg.opto.optopos(idx(2), 1)).^2 + ...
        (cfg.opto.optopos(idx(1), 2) - cfg.opto.optopos(idx(2), 2)).^2 + ...
        (cfg.opto.optopos(idx(1), 3) - cfg.opto.optopos(idx(2), 3)).^2);
end
cfg.chanlocs = convertlocs(cfg.chanlocs, 'cart2all');
end