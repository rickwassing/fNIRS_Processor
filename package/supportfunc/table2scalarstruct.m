function s = table2scalarstruct(tbl)

s = struct();
fnames = tbl.Properties.VariableNames;
if isempty(fnames)
    s = struct([]);
    return
end
for i = 1:length(fnames)
    s.(fnames{i}) = tbl.(fnames{i});
end

end