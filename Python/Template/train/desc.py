import os
import pickle

import numpy as np
import pandas as pd


def desc(df):
    """

    :param df:
    :return:
    """
    from scipy import stats

    result = []
    nrows = len(df)
    for col in df.columns:
        x = df[col]
        na = x.isnull().sum()
        nunique = x.nunique()
        missrate = na * 1.0 / nrows
        if x.dtypes != 'object':
            q = np.round(
                stats.scoreatpercentile(x.dropna(), [1, 5, 10, 20, 25, 30,
                                                     40, 50, 60, 70, 75,
                                                     80, 90, 95, 99]), 6)
            iqr = q[10] - q[4]
            iqrlow = q[4] - 1.5 * iqr
            iqrupp = q[10] + 1.5 * iqr

            coef = 0
            if x.mean() == 0:
                coef = np.nan
            else:
                coef = x.std() / x.mean()

            r = (col, 'Number', nrows, na, missrate,
                 nunique, x.min(), q[0], q[1], q[2],
                 q[3], q[4], q[5], q[6], q[7],
                 q[8], q[9], q[10], q[11], q[12],
                 q[13], q[14], x.max(), x.mean(), x.std(),
                 x.var(), coef, (x < 0).sum(), (x == 0).sum(), (x > 0).sum(),
                 (x < iqrlow).sum(), (x > iqrupp).sum(), iqr, x.max() - x.min(), x.skew(),
                 x.kurtosis(), np.nan, np.nan, np.nan, np.nan)
            result.append(r)
        else:
            cnts = x.value_counts()
            top = cnts.index[0]
            tail = cnts.index[-1]
            toprate = cnts[0] * 1.0 / nrows
            tailrate = cnts[-1] * 1.0 / nrows

            r = (col, 'Char', nrows, na, missrate,
                 nunique, np.nan, np.nan, np.nan, np.nan,
                 np.nan, np.nan, np.nan, np.nan, np.nan,
                 np.nan, np.nan, np.nan, np.nan, np.nan,
                 np.nan, np.nan, np.nan, np.nan, np.nan,
                 np.nan, np.nan, np.nan, np.nan, np.nan,
                 np.nan, np.nan, np.nan, np.nan, np.nan,
                 np.nan, top, toprate, tail, tailrate
                 )
            result.append(r)
    cols = ['Name', 'Type', 'N', 'NMiss', 'MissRate',
            'Unique', 'Min', 'Q1', 'Q5', 'Q10',
            'Q20', 'Q25', 'Q30', 'Q40', 'Q50',
            'Q60', 'Q70', 'Q75', 'Q80', 'Q90',
            'Q95', 'Q99', 'Max', 'Avg', 'Std',
            'Var', 'Coef', 'Skewness', 'Kurtosis', 'NNeg',
            'NZero', 'NPos', 'NOutL', 'NOutU', 'IQR',
            'Range', 'Top', 'TopRate', 'Tail', 'TailRate']
    print('done')
    eda_stat = pd.DataFrame(result, columns=cols).sort_values(by='Type')
    return eda_stat.sort_values(by='Name')


train_data = pickle.load(open(os.getcwd() + '\\train\\train_data\\train_data.pkl', 'br'))
train_data = train_data.drop(['sample_flag', 'ovr30', 'customer_id'], axis=1)
train_data = train_data.select_dtypes(['float64', 'int64'])
eda = desc(train_data)
