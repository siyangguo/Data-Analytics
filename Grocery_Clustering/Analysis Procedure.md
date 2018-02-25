

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

    (250000, 8)





<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>transaction_id</th>
      <th>product_id</th>
      <th>reordered</th>
      <th>product_name</th>
      <th>aisle_id</th>
      <th>department_id</th>
      <th>department</th>
      <th>aisle</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>10</td>
      <td>26842</td>
      <td>0</td>
      <td>Boneless Beef Sirloin Steak</td>
      <td>122</td>
      <td>12</td>
      <td>meat seafood</td>
      <td>meat counter</td>
    </tr>
    <tr>
      <th>1</th>
      <td>10</td>
      <td>1529</td>
      <td>0</td>
      <td>Parsley, Italian (Flat), New England Grown</td>
      <td>16</td>
      <td>4</td>
      <td>produce</td>
      <td>fresh herbs</td>
    </tr>
    <tr>
      <th>2</th>
      <td>10</td>
      <td>31717</td>
      <td>0</td>
      <td>Organic Cilantro</td>
      <td>16</td>
      <td>4</td>
      <td>produce</td>
      <td>fresh herbs</td>
    </tr>
    <tr>
      <th>3</th>
      <td>10</td>
      <td>21137</td>
      <td>1</td>
      <td>Organic Strawberries</td>
      <td>24</td>
      <td>4</td>
      <td>produce</td>
      <td>fresh fruits</td>
    </tr>
    <tr>
      <th>4</th>
      <td>10</td>
      <td>24852</td>
      <td>1</td>
      <td>Banana</td>
      <td>24</td>
      <td>4</td>
      <td>produce</td>
      <td>fresh fruits</td>
    </tr>
  </tbody>
</table>
</div>



