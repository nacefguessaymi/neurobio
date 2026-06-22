function X = mapping_structs(file_source, conversion_factor, X)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Faking a SQL Join to a Struct %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get reference file (right table value)
% input: file_source
% output: ref table from Excel
ref = readtable(file_source);

%% Pull struct field you want to join on (left table key)
% input: L.pulseamp (struct + field to join on), 'pulseAmps' (new column
% name for ref table
% output: pulseAmps (column to map to refernce table)
pulseAmps = array2table(vertcat(X.pulseamp), 'VariableNames', {'pulseAmps'});

%% Unit conversion 
% input: ref.mA (column to convert), conversion_factor
% output: ref.pulseAmps (table with correct field)
%conversion_factor = 1000;
ref.pulseAmps = arrayfun(@(x) conversion_factor*x, ref.mA); 

%% Create columns that you want to add to your struct
% input: pulseAmps (column for mapping to ref table), 'pulseAmps' (key from
% both tables), uW (field to join to struct)
% output: newStructField (mapped values now in order and length of struct
% field)
newStructField = num2cell(join(pulseAmps, ref,'Keys','pulseAmps').uW);

%% Include Missing Values
val = [];
emptyCells = cellfun(@isempty,{X(:).pulseamp});
idx = find(emptyCells);
for i = 1:length(idx)
    val = {[]};
    newStructField = [newStructField(1:idx(i)-1); val; newStructField(idx(i):end)];
end
%% Tack on new fields at end of struct
% input: newStructField (columns to join)
% L_copy(:),pulsepower (new struct field)
[X(:).pulsepower] = (newStructField{:});
end