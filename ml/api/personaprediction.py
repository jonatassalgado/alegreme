import pandas as pd
import numpy as np
import seaborn as sns
import ast
import heapq as hq
import time

from sklearn.pipeline import Pipeline
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import GridSearchCV
from joblib import dump, load

class PersonaPrediction(object):

    def __init__(self):
        self.base = pd.read_csv('../svm-classification-personas-v3-events.csv')


    def visualize(self):
        corr = self.base.iloc[:, 1:].corr().round(1)
        cmap = sns.diverging_palette(220, 10, as_cmap=True)
        sns.heatmap(corr, cmap=cmap, center=0, square=True, linewidths=.5, fmt="f", vmax=0.5, cbar_kws={"shrink": 1})


    def clean(self):
        base = self.base.iloc[:, 0:9].dropna().transpose()
        self.X = base.iloc[1:9, :].astype(int).values
        self.y = base[1:9].index.values


    def train(self):
        timestr = time.strftime("%Y%m%d-%H%M%S")
        X_test = np.random.choice([-1, 0, 1], size=(23,), p=[3/10, 3/10, 4/10]).reshape(1, -1)
        #X_test = [[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]]

        classificator = Pipeline([('clf-svm', SGDClassifier(alpha=0.01, loss='log'))])
        parameters_svm = {'clf-svm__alpha': (1e-2, 1e-3),
                          'clf-svm__loss': ('log', 'modified_huber')}

        classificator = classificator.fit(self.X, self.y)

        dump(classificator, 'predict-persona-model-' + timestr + '.joblib')


    def predict(self, query):
        query = ast.literal_eval(query)
        query = list(map(int, query))
        classificator = load('predict-persona-model.joblib')
        predictions = classificator.predict_proba([query])


        for prediction in predictions:
            best_label_index = prediction.argmax(axis=0)
            best_label_name = classificator.classes_[best_label_index]



            best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)
            return classificator.classes_[best_two_labels_index]

#
# predictModel = PersonaPrediction()
# predictModel.clean()
# predictModel.train()
