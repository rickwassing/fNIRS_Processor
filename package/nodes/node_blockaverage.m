% -------------------------------------------------------------------------
% Block average
cfg = struct();
cfg.source = 'dc';
cfg.eventlabels = {...
    {'x1'}, ... % average all 'x1' trials
    };
cfg.window = [-15, 60]; % seconds pre-stimulus to post-stimulus
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('averagetrials', cfg);
pipe = [pipe; node];