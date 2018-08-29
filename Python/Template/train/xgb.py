from sklearn import metrics
from statsmodels.stats.outliers_influence import variance_inflation_factor
import numpy as np
import xgboost as xgb
from sklearn import ensemble
from sklearn.model_selection import KFold
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
import pandas as pd
import scipy
from scipy.stats import chi2
import matplotlib.pyplot as plt
from sklearn.utils.multiclass import type_of_target
from scipy import stats

params = {
    'booster': 'gbtree',
    'objective': 'binary:logistic',  # 逻辑损失
    'max_depth': 4,  # 深度
    'subsample': 0.7,
    'colsample_bytree': 0.7,
    'min_child_weight': 150,  # 叶子节点最小的样本数
    'silent': 0,
    'eta': 0.05,  # 学习速率
    'seed': 100,
    'nthread': 7,
    'eval_metric': 'auc'
}


def report_performance(preds, y, cutoff=0.5):
    ks = stats.ks_2samp(preds[y == 1], preds[y != 1]).statistic
    gini = metrics.roc_auc_score(y, preds) * 2 - 1.0
    accuracy = metrics.accuracy_score(y, np.where(preds > cutoff, 1, 0))
    recall = metrics.recall_score(y, np.where(preds > cutoff, 1, 0))
    precision = metrics.precision_score(y, np.where(preds > cutoff, 1, 0))
    cm = metrics.confusion_matrix(y, np.where(preds > cutoff, 1, 0))
    # fpr, tpr, thresholds = metrics.roc_curve(y,preds)
    # roc_auc = metrics.auc(fpr,tpr)
    print('=======================report=================')
    print('Gini is: %-.5f \t KS is: %-.5f \t accuracy: %-.5f \t Precision: %-.5f \t Recall:%-.5f' % (
    gini, ks, accuracy, precision, recall))
    print('confusion matrix:')
    print(cm)


X_train = train_df.drop(['default'], axis=1)
xgb_train = xgb.DMatrix(X_train, label=train_df.default)
xgb_test = xgb.DMatrix(test_df[X_train.columns], label=test_df.default)

xgb_oot = xgb.DMatrix(oot[X_train.columns], label=oot.default)

booster = xgb.train(params, xgb_train, num_boost_round=500, evals=[(xgb_train, 'train'), (xgb_test, 'test')],
                    early_stopping_rounds=20)  # 20次AUC不上升，就停止

preds = booster.predict(xgb_train)
report_performance(preds, train_df.default)

preds2 = booster.predict(xgb_test)
report_performance(preds2, test_df.default)

preds3 = booster.predict(xgb_oot)
report_performance(preds3, oot.default)
