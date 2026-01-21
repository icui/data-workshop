from mpi4py import MPI
import numpy as np
from adios2 import Stream
import json

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

with open('jan76_dec20.ndk', 'r') as file:
    data = file.readlines()

# option 2: Parameter (JSON) + raw array files
data_meta = {"row": [], "column": ["depth", "m0", "m1", "m2", "m3", "m4", "m5", "M0"]}
data_array = np.zeros((len(data)//20, 8))  # Preallocate array

# option 4: Key-value pairs (by data class)
data_kv2 = {
    "depth": [],
    "m0": [],
    "m1": [],
    "m2": [],
    "m3": [],
    "m4": [],
    "m5": [],
    "M0": []
}

# Process the data by lines
for i in range(0, len(data), 5): # each event has 5 lines
    event_name = data[i+1].split()[0]
    depth = float(data[i+2].split()[7])
    ex = float(data[i+3].split()[0])
    m0 = float(data[i+3].split()[1])
    m1 = float(data[i+3].split()[3])
    m2 = float(data[i+3].split()[5])
    m3 = float(data[i+3].split()[7])
    m4 = float(data[i+3].split()[9])
    m5 = float(data[i+3].split()[11])
    M0 = float(data[i+4].split()[10])

    # option 2: Parameter (JSON) + raw array files
    if i//5 % size == rank:
        event_data_array = np.array([depth, m0 * 10**ex, m1 * 10**ex, m2 * 10**ex, m3 * 10**ex, m4 * 10**ex, m5 * 10**ex, M0 * 10**ex])
        data_meta["row"].append(event_name)
        data_array[i//(5*size), :] = event_data_array

    # option 3: Key-value pairs (HDF5)
    data_kv2['depth'].append(depth)
    data_kv2['m0'].append(m0 * 10**ex)
    data_kv2['m1'].append(m1 * 10**ex)
    data_kv2['m2'].append(m2 * 10**ex)
    data_kv2['m3'].append(m3 * 10**ex)
    data_kv2['m4'].append(m4 * 10**ex)
    data_kv2['m5'].append(m5 * 10**ex)
    data_kv2['M0'].append(M0 * 10**ex)

# save option 2
with open(f'data_meta_rank{rank}.json', 'w') as f:
    json.dump(data_meta, f, indent=4)
np.save(f'data_array_rank{rank}.npy', data_array)

# save option 3
with Stream("data_kv2_mpi.bp", "w", comm=comm) as stream:
    for key in data_kv2.keys():
        data_kv2[key] = np.array(data_kv2[key])
        stream.write(key, data_kv2[key])
