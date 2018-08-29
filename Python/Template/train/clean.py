import pandas as pd
import numpy as np


def single_value(df, x=""):
    """

    :param df:
    :param x: x默认为空，此时只对特征x判断是否是单一值；否则是对整个数据框判断单一值；
    :return: 返回单一值字段列表
    """
    if len(x) > 0:
        value = [i for i in df[x] if i == i]
        if (len(set(value)) == 1):
            print("{}只有一个值.".format(x))
        else:
            print("{}非单一值.".format(x))
    else:
        column_for_single_value = []
        for column in df.columns:
            value = [i for i in df[column] if i == i]
            if (len(set(value)) == 1):
                column_for_single_value.append(column)
                print("{}只有一个值.".format(column))
            else:
                continue
        return column_for_single_value


def missing_value(df, threshold, method = "mean"):
    missing_features = []
    missing_columns = []
    non_missing_features = []
    for column in df.columns:
        missing_rate = sum(pd.isnull(df[column])) * 1.0 / df.shape[0]
        if missing_rate >= threshold:
            print("{}是缺失字段,缺失率为{}.".format(column, missing_rate))
            missing_features.append(column)
        elif missing_rate > 0:
            missing_columns.append(column)
        else:
            non_missing_features.append(column)

    return missing_features, missing_columns, non_missing_features
