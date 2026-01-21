% load option 1
tic;
fid = fopen('data_nested.json', 'r');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
data_nested = jsondecode(str);
load_time_1 = toc;

% load option 2
tic;
fid = fopen('data_meta.json', 'r');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
data_meta = jsondecode(str);
load('data_array.mat', 'data_array'); % Loading .mat instead of .npy
load_time_2 = toc;

% load option 3
tic;
data_kv = struct();
info = h5info('data_kv.h5');
for i = 1:length(info.Datasets)
    key = info.Datasets(i).Name;
    % h5read returns the dataset. Note: strings in keys might need handling if not simple
    % h5create in download_extract uses ['/' key], so we read ['/' key]
    data_kv.(key) = h5read('data_kv.h5', ['/' key]);
end
load_time_3 = toc;

% Using option 1
tic;
% Calculate the min, max and median of earthquake depths
fields1 = fieldnames(data_nested);
depths_option1 = [];
for i = 1:length(fields1)
    depths_option1(end+1) = data_nested.(fields1{i}).depth;
end
min_depth1 = min(depths_option1);
max_depth1 = max(depths_option1);
median_depth1 = median(depths_option1);
% Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)`
moments_option1 = [];
for i = 1:length(fields1)
    moments_option1(end+1) = data_nested.(fields1{i}).M0;
end
mw_option1 = (2/3) * (log10(moments_option1) - 16.1);
earthquakes_gt_8_option1 = {};
for i = 1:length(fields1)
    event = data_nested.(fields1{i});
    if ((2/3)*(log10(event.M0) - 16.1)) > 8.0
        earthquakes_gt_8_option1{end+1} = event;
    end
end
% Find the maximum absolute value among the moment tensor components of all earthquakes
max_moment_tensor_component = 0;
for i = 1:length(fields1)
    event = data_nested.(fields1{i});
    for key = {'m0', 'm1', 'm2', 'm3', 'm4', 'm5'}
        max_moment_tensor_component = max(max_moment_tensor_component, abs(event.(key{1})));
    end
end
calc_time_1 = toc;

% Using option 2
tic;
% Calculate the min, max and median of earthquake depths
depths_option2 = data_array(:, 1);  % depth is the first column (1-based index)
min_depth2 = min(depths_option2);
max_depth2 = max(depths_option2);
median_depth2 = median(depths_option2);
% Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)`
moments_option2 = data_array(:, 8);  % M0 is the eighth column (index 8)
mw_option2 = (2/3) * (log10(moments_option2) - 16.1);
earthquakes_gt_8_option2 = data_array(mw_option2 > 8.0, :);
% Find the maximum absolute value among the moment tensor components of all earthquakes
% m0 to m5 are columns 1 to 6 (py) -> 2 to 7 (matlab)
max_moment_tensor_component2 = max(max(abs(data_array(:, 2:7))));
calc_time_2 = toc;

% Using option 3
tic;
% Calculate the min, max and median of earthquake depths
fields3 = fieldnames(data_kv);
depths_option3 = [];
for i = 1:length(fields3)
    depths_option3(end+1) = data_kv.(fields3{i})(1);
end
min_depth3 = min(depths_option3);
max_depth3 = max(depths_option3);
median_depth3 = median(depths_option3);
% Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)`
moments_option3 = [];
for i = 1:length(fields3)
    moments_option3(end+1) = data_kv.(fields3{i})(8);
end
mw_option3 = (2/3) * (log10(moments_option3) - 16.1);
earthquakes_gt_8_option3 = {};
for i = 1:length(fields3)
    event = data_kv.(fields3{i});
    if ((2/3)*(log10(event(8)) - 16.1)) > 8.0
        earthquakes_gt_8_option3{end+1} = event;
    end
end
% Find the maximum absolute value among the moment tensor components of all earthquakes
max_moment_tensor_component3 = 0;
for i = 1:length(fields3)
    event = data_kv.(fields3{i});
    for val = event(2:7)' % m0 to m5 are elements 2 to 7
        max_moment_tensor_component3 = max(max_moment_tensor_component3, abs(val));
    end
end
calc_time_3 = toc;

% Print results
fprintf('Option 1 - Nested Dictionary:\n');
fprintf('Min Depth: %f, Max Depth: %f, Median Depth: %f\n', min_depth1, max_depth1, median_depth1);
fprintf('Number of Earthquakes with Mw > 8.0: %d\n', length(earthquakes_gt_8_option1));
fprintf('Max Moment Tensor Component: %f\n', max_moment_tensor_component);
fprintf('Load Time: %.4fs Option 1 Calculation Time: %.4fs\n', load_time_1, calc_time_1);
fprintf('\n');

fprintf('Option 2 - Parameter + Raw Array:\n');
fprintf('Min Depth: %f, Max Depth: %f, Median Depth: %f\n', min_depth2, max_depth2, median_depth2);
fprintf('Number of Earthquakes with Mw > 8.0: %d\n', length(earthquakes_gt_8_option2)); % rows
fprintf('Max Moment Tensor Component: %f\n', max_moment_tensor_component2);
fprintf('Load Time: %.4fs Option 2 Calculation Time: %.4fs\n', load_time_2, calc_time_2);
fprintf('\n');

fprintf('Option 3 - Key-Value Pairs:\n');
fprintf('Min Depth: %f, Max Depth: %f, Median Depth: %f\n', min_depth3, max_depth3, median_depth3);
fprintf('Number of Earthquakes with Mw > 8.0: %d\n', length(earthquakes_gt_8_option3));
fprintf('Max Moment Tensor Component: %f\n', max_moment_tensor_component3);
fprintf('Load Time: %.4fs Option 3 Calculation Time: %.4fs\n', load_time_3, calc_time_3);
