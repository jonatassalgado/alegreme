# -*- coding: utf-8 -*-
"""
Spyder Editor

Este é um arquivo de script temporário.
"""

import pandas as pd
import numpy as np
from sklearn.pipeline import Pipeline
from joblib import dump, load

base = pd.read_csv('svm-classification-personas-v2-events.csv')

import seaborn as sns
corr = base.iloc[:, 1:9].corr().round(1)
cmap = sns.diverging_palette(220, 10, as_cmap=True)
sns.heatmap(corr, cmap=cmap, center=0, square=True, linewidths=.5, fmt="f", vmax=1, cbar_kws={"shrink": 1})


base = base.iloc[:, 0:9].dropna().transpose()

X = base.iloc[1:9, :].astype(int).values
y = base[1:9].index.values


#X_test = np.random.choice([-1, 0, 1], size=(23,), p=[3/10, 3/10, 4/10]).reshape(1, -1)
X_test = [[1, 0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0]]

from sklearn.linear_model import SGDClassifier

classificator = Pipeline([('clf-svm', SGDClassifier(alpha=0.01, loss='log'))])

dump(classificator, 'predict-persona-model.joblib')

#from sklearn.model_selection import GridSearchCV
#parameters_svm = {'clf-svm__alpha': (1e-2, 1e-3),
#                  'clf-svm__loss': ('log', 'modified_huber')}

#gs_clf_svm = GridSearchCV(classificator, parameters_svm, n_jobs=-1)
#gs_classificator = gs_clf_svm.fit(X, y)

#best_params = gs_classificator.best_params_

#predictions = gs_classificator.predict_proba(X_test)

classificator = classificator.fit(X, y)
predictions = classificator.predict_proba(X_test)






