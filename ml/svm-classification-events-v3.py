#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 11 14:27:26 2019

@author: jon
"""


import re

def clean_text(text):
    """
    Applies some pre-processing on the given text.

    Steps :
    - Removing HTML tags
    - Removing punctuation
    - Lowering text
    """
    
    # remove emojis
    emoji_pattern = re.compile("["
                           u"\U0001F600-\U0001F64F"  # emoticons
                           u"\U0001F300-\U0001F5FF"  # symbols & pictographs
                           u"\U0001F680-\U0001F6FF"  # transport & map symbols
                           u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                           u"\U00002702-\U000027B0"
                           u"\U000024C2-\U0001F251"
                           "]+", flags=re.UNICODE)

    text = emoji_pattern.sub(r'', text)
    
    # remove HTML tags
    text = re.sub(r'<.*?>', ' ', text)

    # remove the characters [\], ['] and ["]
    text = re.sub(r"\\", "", text)    
    text = re.sub(r"\'", "", text)    
    text = re.sub(r"\"", "", text)
    text = re.sub(r"", "", text)   
    
    # remove numbers
    text = re.sub(" \d+|\d{2}:\d{2}|\d{2}/\d{2}|\dº|\(\d+\)|\d{2}h\d{2}|\d{2}.|\d{2}h|\d\d|\d{2}min|,|º", "", text)
    text = re.sub("(\\b[A-Za-z] \\b|\\b [A-Za-z]\\b)", " ", text)
    
    # convert text to lowercase
    text = text.strip().lower()
    
    # replace punctuation characters with spaces
    filters='!"\'#$%&()*+,-./:;<=>?@[\\]^_`{|}~\t\n'
    translate_dict = dict((c, " ") for c in filters)
    translate_map = str.maketrans(translate_dict)
    text = text.translate(translate_map)

    return text

import pandas as pd
import numpy as np
import heapq as hq

#raw = pd.read_json('./events.json')
#csv = raw.to_csv('./events-raw.csv')

base = pd.read_csv('./svm-classification-events-20190407-114953.csv')

# remove null values
base = base.loc[(base['description'].notna()) & (base['label_b'].notna())]

X = base['name'].str.cat(base[['description', 'categories']], sep=' ', na_rep='').values.astype(str)
y = base.loc[:, ['label_b', 'label_c', 'label_d']].values.astype(str).tolist()

while 'nan' in y[0]:
    for row in y:
        for index, item in enumerate(row):
            if item == 'nan':
                np.delete(row, index)
        

from nltk import download
download('stopwords')
download('punkt')
download('rslp')

from nltk.tokenize import word_tokenize
from nltk.stem import RSLPStemmer
from nltk.corpus import stopwords

from sklearn.pipeline import Pipeline

stopwords = stopwords.words('portuguese')
stopwords.extend(['porto', 'alegre', 'dia', 'ano', '“', '”', 'ano', 'é', '⇨', 'ª', '’', 'página', 'evento', 'poa', 'brasil', 'propõe', 'edição', 'ano', '01', '2009', 'dessa', 'desse', 'deste', 'chegou', 'hora', 'lugar', 'tempo', 'real', 'mais', 'ajuda', 'problema', 'após', 'acontece', 'boa', 'cheio', 'cheia', 'além', 'acesso', 'consulta', 'pessoas', 'pode', 'ser', 'planejamento', 'ano', 'próximo', 'precisa', 'possuir', 'qualquer', 'ser', 'agenda', 'breve', 'todas', 'novidades', 'chega', 'prestigiar', 'local', 'pequeno', 'aqui', 'apresenta', 'sábado', 'frente', 'ré', 'novo', 'nova', 'divulgação', 'participe', 'facebook', 'instagram', 'siga', 'promove', 'realiza'])


def cleanner_text(descriptions):
    descriptions_cleanned = []
    for description in descriptions:
        descriptions_cleanned.append(clean_text(description))
    return descriptions_cleanned


def stemmer_text(descriptions):
    descriptions_stemmed = []
    for description in descriptions:
        description_tokenized = []
        description_tokenized.append(word_tokenize(description))
        for description in description_tokenized:
            description_stemmed = []
            for word in description:
                stemmer = RSLPStemmer()
                if word not in stopwords:
                    description_stemmed.append(stemmer.stem(word))
                    pass
            description_stringfyed = ' '.join(description_stemmed)
            descriptions_stemmed.append(description_stringfyed)
    
    return descriptions_stemmed


X_cleanned = cleanner_text(X)
X_stemmed = stemmer_text(X_cleanned)


from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X_stemmed, y, test_size=0.10, random_state=None)


from sklearn.feature_extraction.text import CountVectorizer
#vectorizer = CountVectorizer(preprocessor=clean_text)
#vectorizer = vectorizer.fit(X_train)

#training_features = vectorizer.transform(X_train)
#test_features = vectorizer.transform(X_test)


from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.linear_model import SGDClassifier
from sklearn.ensemble import RandomForestClassifier



classificator = Pipeline([('vect', CountVectorizer(ngram_range=(1, 1))),
                          ('tfidf', TfidfTransformer(use_idf=True)),
                          ('clf-svm', RandomForestClassifier())])


#    
#from sklearn.model_selection import GridSearchCV
#parameters_svm = {'vect__ngram_range': [(1, 1), (1, 2)],
#                  'vect__min-df': range(0.0, 1.0, 0.1),
#                  'tfidf__use_idf': (True, False),
#                  'clf-svm__alpha': (0.01, 0.001, 0.0001),
#                  'clf-svm__penalty': ( 'l2', 'l1', 'elasticnet'),
#                  'clf-svm__max_iter': ( 5, 1000),  
#                  'clf-svm__loss': ('log', 'modified_huber')}
#
#gs_clf_svm = GridSearchCV(classificator, parameters_svm, n_jobs=-1)
#
#
#gs_classificator = gs_clf_svm.fit(X_train, y_train)
#best_params = gs_classificator.best_params_
#predictions = gs_classificator.predict_proba(X_test)

    
    
classificator = classificator.fit(X_train, y_train)
predictions = classificator.predict(X_test)
score = classificator.score(X_test, y_test)


predictions_labels = []
for prediction in predictions:    
    best_label_index = prediction.argmax(axis=0)
    best_label_name = classificator.classes_[best_label_index]
    
    
    
    best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)
    predictions_labels.append(classificator.classes_[best_two_labels_index])

print(predictions_labels)


from sklearn.metrics import accuracy_score
accuracy = accuracy_score([i[0] for i in predictions_labels], y_test)
accuracyb = accuracy_score([i[1] for i in predictions_labels], y_test)
accuracyc = accuracy + accuracyb 

















