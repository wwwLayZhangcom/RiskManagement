import os
import pickle

import pandas as pd

def binning(df, x, y, n, plot=True):
    """

    :param df:
    :param x:
    :param y:
    :param n:
    :param plot:
    :return:
    """

    result = binning_data(df, x, y, n)
    result = woe_iv(result, x)
    if plot:
        binning_plot(result, x)
    return result


def binning_data(df, x, y, n):
    """

    :param df:
    :param x:
    :param y:
    :param n:
    :return:
    """
    try:
        df = df[[x, y]].sort_values(by=x)
        df = df[pd.isnull(df[x]) == False]
        cut_pct = [i / n for i in list(range(1, n + 1))]
        cut_point = df[x].quantile(cut_pct)
        df['group'] = pd.cut(df[x], cut_point, right=False, duplicates='drop')
        df['group'][pd.isnull(df['group']) == True] = df['group'].unique().sort_values()[
            len(df['group'].unique().sort_values()) - 2]
        result = pd.concat([df.groupby('group')[y].sum(), df.groupby('group')[y].count()], axis=1).sort_index().reset_index(
            drop=False)
        result.columns = ['group', 'bad_count', 'total_count']
        return result
    except:
        print("{}生成result时发生错误.".format(x))


def woe_iv(result, x):
    """

    :param result:
    :return:
    """
    try:
        result['good_count'] = result['total_count'] - result['bad_count']
        result['good_rate'] = result['good_count'] / result['total_count']
        result['bad_rate'] = result['bad_count'] / result['total_count']
        result['bad_sample_pct'] = result['bad_count'] / sum(result['bad_count'])
        result['total_sample_pct'] = result['total_count'] / sum(result['total_count'])
        result['woe'] = (result['bad_count'] / result['good_count']) / (
                sum(result['bad_count']) / sum(result['good_count']))
        result['iv'] = ((result['bad_count'] / sum(result['bad_count'])) - (
                result['good_count'] / sum(result['good_count']))) * result['woe']
        result['max_woe'] = result['woe'].max()
        result['min_woe'] = result['woe'].min()
        result['iv_total'] = sum(result['iv'])
        result['column'] = x
        return result
    except:
        print("{}在计算woe时发生错误.".format(x))


def binning_plot(result, x):
    """

    :param result:
    :param x:
    :return:
    """
    try:
        import matplotlib.pyplot as plt
        x_ = list(range(len(result['group'])))
        plt.plot(x_, list(result['bad_rate']), marker='o', mec='r', mfc='w', label='bad_rate')
        plt.plot(x_, list(result['total_sample_pct']), marker='*', ms=10, label='total_sample_pct')
        plt.plot(x_, list(result['bad_sample_pct']), marker='*', ms=10, label='bad_sample_pct')
        plt.title(x)
        plt.legend()
        plt.savefig(os.path.join(os.getcwd(), 'train\\img', (x + '.jpg')))
        plt.show()
    except:
        print("{}在画图时发生错误.".format(x))


train_data = pickle.load(open(os.getcwd() + '\\train\\train_data\\train_data.pkl', 'br'))
for i in train_data.columns:
    binning(train_data, i, "ovr30", 10, plot=True)
