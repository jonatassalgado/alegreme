import os
import re
import base64
import pandas as pd
import numpy as np
import seaborn as sns
import ast
import heapq as hq
import time

from sklearn.pipeline import Pipeline
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import GridSearchCV
from joblib import dump
from joblib import load

class PersonaPrediction(object):

    def __init__(self):
        self.base = pd.read_csv('../svm-classification-personas-v3-events.csv')


    def visualize(self):
        corr = self.base.iloc[:, 1:].corr().round(1)
        cmap = sns.diverging_palette(220, 10, as_cmap=True)
        sns.heatmap(corr, cmap=cmap, center=0, square=True, linewidths=.5, fmt="f", vmax=0.5, cbar_kws={"shrink": 1})


    def clean(self):
        base = self.base.iloc[:, 0:8].dropna().transpose()
        self.X = base.iloc[1:8, :].astype(int).values
        self.y = base[1:8].index.values


    def train(self):
        timestr = time.strftime("%Y%m%d-%H%M%S")
        X_test = np.random.choice([-1, 0, 1], size=(21,), p=[3/10, 3/10, 4/10]).reshape(1, -1)
        #X_test = [[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]]

        classificator = Pipeline([('clf-svm', SGDClassifier(alpha=0.01, loss='log'))])
        parameters_svm = {'clf-svm__alpha': (1e-2, 1e-3),
                          'clf-svm__loss': ('log', 'modified_huber')}

        classificator = classificator.fit(self.X, self.y)

        dump(classificator, 'predict-persona-model-' + timestr + '.joblib')


    def predict(self, query):
        query = ast.literal_eval(query)
        query = list(map(int, query))

        regex = re.compile(r'predict-persona-model-\d{8}-\d{6}\.joblib$')
        last_file = max(filter(regex.search, os.listdir('./')))

        classificator = load(last_file)
        predictions = classificator.predict_proba([query])


        for prediction in predictions:
            best_four_labels_index = hq.nlargest(4, range(len(prediction)), prediction.take)
            best_labels_name = classificator.classes_[best_four_labels_index]
            best_labels_score = hq.nlargest(4, prediction)

            output = [
                        [best_labels_name[0], best_labels_score[0]],
                        [best_labels_name[1], best_labels_score[1]],
                        [best_labels_name[2], best_labels_score[2]],
                        [best_labels_name[3], best_labels_score[3]]
                     ]
            print(output)
            return output

#
#predictModel = PersonaPrediction()
#predictModel.clean()
#predictModel.train()  # 2   3   4    5   6   7   8   9   10   11  12  13  14   15 16  17   18  19  20  21   22
#predictModel.predict("['0','1','-1','0','0','1','0','0','1','-1','0','0','-1','0','1','1','-1','0','0','1','1' ]")
