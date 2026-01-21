import numpy as np
import json
import h5py

# load option 1
with open('data_nested.json', 'r') as f:
    data_nested = json.load(f)

# load option 2
with open('data_meta.json', 'r') as f:
    data_meta = json.load(f)
data_array = np.load('data_array.npy')

# load option 3
data_kv = {}
with h5py.File('data_kv.h5', 'r') as hf:
    for key in hf.keys():
        data_kv[key] = hf[key][()]

# Using option 1
# Calculate the min, max and median of earthquake depths
depths_option1 = [event['depth'] for event in data_nested.values()]
min_depth1 = min(depths_option1)
max_depth1 = max(depths_option1)
median_depth1 = np.median(depths_option1)
# Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)`
moments_option1 = [event['M0'] for event in data_nested.values()]
mw_option1 = [(2/3)*(np.log10(M0) - 16.1) for M0 in moments_option1]
earthquakes_gt_8_option1 = [event for event in data_nested.values() if (2/3)*(np.log10(event['M0']) - 16.1) > 8.0]
# Find the maximum absolute value among the moment tensor components of all earthquakes
max_moment_tensor_component = 0
for event in data_nested.values():
    for key in ['m0', 'm1', 'm2', 'm3', 'm4', 'm5']:
        max_moment_tensor_component = max(max_moment_tensor_component, abs(event[key]))

# Using option 2
# Calculate the min, max and median of earthquake depths
depths_option2 = data_array[:, 0]  # depth is the first column
min_depth2 = np.min(depths_option2)
max_depth2 = np.max(depths_option2)
median_depth2 = np.median(depths_option2)
# Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)` list earthquakes with moment magnitude greater than 8.0 
moments_option2 = data_array[:, 7]  # M0 is the eighth column
mw_option2 = (2/3)*(np.log10(moments_option2) - 16.1)
earthquakes_gt_8_option2 = data_array[mw_option2 > 8.0]
# Find the maximum absolute value among the moment tensor components of all earthquakes
max_moment_tensor_component2 = np.max(np.abs(data_array[:, 1:7]))  # m0 to m5 are columns 1 to 6

# Using option 3
# Calculate the min, max and median of earthquake depths
depths_option3 = [data_kv[key][0] for key in data_kv.keys()]  # depth is the first element
min_depth3 = min(depths_option3)
max_depth3 = max(depths_option3)
median_depth3 = np.median(depths_option3)
# Calculate the Moment magnitude of each earthquake `Mw = (2/3)*(log10(M0) - 16.1)`
moments_option3 = [data_kv[key][7] for key in data_kv.keys()]  # M0 is the eighth element
mw_option3 = [(2/3)*(np.log10(M0) - 16.1) for M0 in moments_option3]
earthquakes_gt_8_option3 = [data_kv[key] for key in data_kv.keys() if (2/3)*(np.log10(data_kv[key][7]) - 16.1) > 8.0]
# Find the maximum absolute value among the moment tensor components of all earthquakes
max_moment_tensor_component3 = 0
for event in data_kv.values():
    for component in event[1:7]:  # m0 to m5 are elements 1 to 6
        max_moment_tensor_component3 = max(max_moment_tensor_component3, abs(component))

# Print results
print("Option 1 - Nested Dictionary:")
print(f"Min Depth: {min_depth1}, Max Depth: {max_depth1}, Median Depth: {median_depth1}")
print(f"Number of Earthquakes with Mw > 8.0: {len(earthquakes_gt_8_option1)}")
print(f"Max Moment Tensor Component: {max_moment_tensor_component}")
print()
print("Option 2 - Parameter + Raw Array:")
print(f"Min Depth: {min_depth2}, Max Depth: {max_depth2}, Median Depth: {median_depth2}")
print(f"Number of Earthquakes with Mw > 8.0: {len(earthquakes_gt_8_option2)}")
print(f"Max Moment Tensor Component: {max_moment_tensor_component2}")
print()
print("Option 3 - Key-Value Pairs:")
print(f"Min Depth: {min_depth3}, Max Depth: {max_depth3}, Median Depth: {median_depth3}")
print(f"Number of Earthquakes with Mw > 8.0: {len(earthquakes_gt_8_option3)}")
print(f"Max Moment Tensor Component: {max_moment_tensor_component3}")
