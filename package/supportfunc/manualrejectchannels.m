function ml = manualrejectchannels(rej_chan, ml)

chanlabels = arrayfun(@(s, d) sprintf('s%id%i', s, d), ml(:, 1), ml(:, 2), 'UniformOutput', false);
rej_chan = lower(strrep(strrep(rej_chan, '-', ''), '_', ''));
is_active = double(~ismember(chanlabels, rej_chan));

ml(:, 3) = is_active;

end