import os
import sys
import pickle

import pandas as pd

sys.path.append(os.path.join(os.getcwd(), 'data'))

data_1 = pickle.load(open(os.getcwd() + '\\data\\android_1.pkl', 'br'))
data_2 = pickle.load(open(os.getcwd() + '\\data\\android_2.pkl', 'br'))

# 初步处理数据源
column_duplicate = data_1.loc[:, ["customer_id", "ovr30", "sample_flag"]]
column_duplicate = column_duplicate.iloc[:, [1, 5, 8]]
data_1.drop(["customer_id", "ovr30", "sample_flag"], axis=1, inplace=True)
data = pd.concat([data_1, column_duplicate], axis=1)
column_delete = ["raw_vari0012", "updated_time", "raw_vari0015", "vari0008", "vari0009", "raw_vari0007",
                 "raw_vari0010", "raw_vari0017", "raw_vari0019", "raw_vari0022", "raw_vari0025"]
data = data.drop(column_delete, axis=1)
data = pd.merge(data, data_2, how='left', on='customer_id')
data = data[pd.isnull(data['ovr30']) == False]

train_data = open(os.getcwd() + '\\train\\train_data\\train_data.pkl', 'wb+')
pickle.dump(data, train_data)
