function filelist = filterfiles(filelist, fcn, value)

if ~iscell(value)
    value = {value};
end

keepidx = ones(size(filelist));

for i = 1:length(value)
    switch fcn
        case 'contains'
            tmp = arrayfun(@(f) contains(f.folder, value{i}) | contains(f.name, value{i}), filelist);
        case 'notcontains'
            tmp = arrayfun(@(f) ~contains(f.folder, value{i}) & ~contains(f.name, value{i}), filelist);
    end
    keepidx = keepidx .* tmp;
end

filelist = filelist(keepidx == 1);

end