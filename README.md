# Data Storage Hands-on

### Environment setup
#### Log in to Adroit:
```sh
ssh <user_name>@adroit.princeton.edu
```

#### Launch interactive shell

##### Python
```sh
module load anaconda3/2025.12
conda create -n data-ws python=3.14
conda activate data-ws
conda install h5py
python
```

##### MatLab
```sh
module load matlab/R2025b
matlab
```

### Part 1: download and extract data
We use earthquake records from 1976 to 2020 from [Global CMT Catalog](https://www.globalcmt.org). Direct link is provided as variable in the code below. More description on the format of the earthquake record can be found [here](https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained).

#### Access the catalog
The catalog will be saved as a very long string variable named `data`. Do not print it in the terminal directly, go to the [url](https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec20.ndk) to observe the value of `data`.

##### Python
```py
import urllib.request

url='https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec20.ndk'

with urllib.request.urlopen(url) as response:
    data = response.read().decode('utf-8')
```

##### MatLab
```matlab
url='https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec20.ndk';
options = weboptions('ContentType','text');
data = webread(url, options);
```

#### Extract and save data
We need depth, moment magnitude and six moment tensor components for each earthquake. Save them in a format that you think makes sense for processing.

<img src="img/ndk_format.png" alt="NDK Format" width="600"/>
