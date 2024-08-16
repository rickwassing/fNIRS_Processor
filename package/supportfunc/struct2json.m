function json = struct2json(cfg)

try
    json = jsonencode(cfg, 'PrettyPrint', true);
catch
    json = jsonencode(cfg); % Legacy for releases prior to 2021a
end

end