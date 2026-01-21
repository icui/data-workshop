url = 'https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec20.ndk';
options = weboptions('ContentType','text');
data = splitlines(webread(url, options));

% option 1: Nested dictionary (JSON)
data_nested = struct();

% option 2: Parameter (JSON) + raw array files
data_meta.row = {};
data_meta.column = {'depth', 'm0', 'm1', 'm2', 'm3', 'm4', 'm5', 'M0'};
data_array = zeros(floor(length(data)/5), 8);  % Preallocate array

% option 3: Key-value pairs (HDF5)
data_kv = struct();

% Process the data by lines
limit = floor(length(data)/5) * 5;
for i = 1:5:limit % each event has 5 lines
    event_name = strsplit(strtrim(data{i+1}));
    event_name = event_name{1};
    
    parts_depth = strsplit(strtrim(data{i+2}));
    depth = str2double(parts_depth{8});
    
    parts_mom = strsplit(strtrim(data{i+3}));
    ex = str2double(parts_mom{1});
    m0 = str2double(parts_mom{2});
    m1 = str2double(parts_mom{4});
    m2 = str2double(parts_mom{6});
    m3 = str2double(parts_mom{8});
    m4 = str2double(parts_mom{10});
    m5 = str2double(parts_mom{12});
    
    parts_M0 = strsplit(strtrim(data{i+4}));
    M0 = str2double(parts_M0{11});

    % option 1: Nested dictionary (JSON)
    data_nested.(event_name).depth = depth;
    data_nested.(event_name).m0 = m0 * 10^ex;
    data_nested.(event_name).m1 = m1 * 10^ex;
    data_nested.(event_name).m2 = m2 * 10^ex;
    data_nested.(event_name).m3 = m3 * 10^ex;
    data_nested.(event_name).m4 = m4 * 10^ex;
    data_nested.(event_name).m5 = m5 * 10^ex;
    data_nested.(event_name).M0 = M0 * 10^ex;
    
    % option 2: Parameter (JSON) + raw array files
    event_data_array = [depth, m0 * 10^ex, m1 * 10^ex, m2 * 10^ex, m3 * 10^ex, m4 * 10^ex, m5 * 10^ex, M0 * 10^ex];
    data_meta.row{end+1} = event_name;
    data_array(floor((i-1)/5) + 1, :) = event_data_array;

    % option 3: Key-value pairs (HDF5)
    data_kv.(event_name) = event_data_array;
end

% save option 1
fid = fopen('data_nested.json', 'w');
fprintf(fid, '%s', jsonencode(data_nested, 'PrettyPrint', true));
fclose(fid);

% save option 2
fid = fopen('data_meta.json', 'w');
fprintf(fid, '%s', jsonencode(data_meta, 'PrettyPrint', true));
fclose(fid);
save('data_array.mat', 'data_array');

% save option 3
if exist('data_kv.h5', 'file')
    delete('data_kv.h5');
end
keys = fieldnames(data_kv);
for k = 1:length(keys)
    key = keys{k};
    val = data_kv.(key);
    h5create('data_kv.h5', ['/' key], size(val));
    h5write('data_kv.h5', ['/' key], val);
end
