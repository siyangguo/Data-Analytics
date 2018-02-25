

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
seed=9999
plt.style.use("ggplot")
%matplotlib inline

from sklearn.preprocessing import normalize
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.decomposition import PCA

import itertools
from collections import Counter
```


```python
#read data
purchase=pd.read_csv("/Users/siyang/Downloads/Whole_Foods_Transaction_Data.csv")
```


```python
#discover data structure
print(purchase.shape)
purchase.head()
```
