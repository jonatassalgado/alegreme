import re
import pandas as pd
import numpy as np
import heapq as hq

from nltk import download
from nltk.tokenize import word_tokenize
from nltk.stem import RSLPStemmer
from nltk.corpus import stopwords

from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import accuracy_score

from joblib import dump, load


stopwords = stopwords.words('portuguese')
stopwords.extend(['porto', 'alegre', 'dia', 'ano', '“', '”', 'ano', 'é', '⇨', 'ª', '’', 'página', 'evento', 'poa', 'brasil', 'propõe', 'edição', 'ano', '01', '2009', 'dessa', 'desse', 'deste', 'chegou', 'hora', 'lugar', 'tempo', 'real', 'mais', 'ajuda', 'problema', 'após', 'acontece', 'boa', 'cheio', 'cheia', 'além', 'acesso', 'consulta', 'pessoas', 'pode', 'ser', 'planejamento', 'ano', 'próximo', 'precisa', 'possuir', 'qualquer', 'ser', 'agenda', 'breve', 'todas', 'novidades', 'chega', 'prestigiar', 'local', 'pequeno', 'aqui', 'apresenta', 'sábado', 'frente', 'ré', 'novo', 'nova', 'divulgação', 'participe', 'facebook', 'instagram', 'siga', 'promove', 'realiza'])

download('stopwords')
download('punkt')
download('rslp')

class EventPrediction(object):

    def __init__(self):
        self.base = pd.read_csv('../svm-classification-events-v1-events.csv')


    def __cleanning_text(self, text):

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


    def __stemming_text(self, text):
        text_tokenized = word_tokenize(text)
        text_stemmed = []
        for word in text_tokenized:
            stemmer = RSLPStemmer()
            if word not in stopwords:
                text_stemmed.append(stemmer.stem(word))
                pass
        return ' '.join(text_stemmed)


    def clean(self):
        self.base = self.base.loc[(self.base['description'].notna()) & (self.base['label'].notna())]
        self.X = self.base['name'].str.cat(self.base[['description', 'categories']], sep=' ', na_rep='').values.astype(str)
        self.y = self.base.loc[:, 'label'].values.astype(str)

        descriptions_cleanned = []
        for description in self.X:
            descriptions_cleanned.append(self.__cleanning_text(description))
        self.X = descriptions_cleanned


        descriptions_stemmed = []
        for description in self.X:
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

        self.X = descriptions_stemmed


    def train(self):
        X_train, X_test, y_train, y_test = train_test_split(self.X, self.y, test_size=0.10, random_state=None)

        classificator = Pipeline([('vect', CountVectorizer(ngram_range=(1, 1))),
                                  ('tfidf', TfidfTransformer(use_idf=True)),
                                  ('clf-svm', SGDClassifier(alpha=0.001, loss='log'))])

        classificator = classificator.fit(X_train, y_train)
        dump(classificator, 'predict-event-model.joblib')
        classificator = classificator.fit(X_train, y_train)
        predictions = classificator.predict_proba(X_test)

        predictions_labels = []
        for prediction in predictions:
            best_label_index = prediction.argmax(axis=0)
            best_label_name = classificator.classes_[best_label_index]
            best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)
            predictions_labels.append(classificator.classes_[best_two_labels_index])

        accuracy = accuracy_score([i[0] for i in predictions_labels], y_test)
        accuracyb = accuracy_score([i[1] for i in predictions_labels], y_test)
        accuracyc = accuracy + accuracyb

        print(predictions_labels)
        print(accuracyc)


    def predict(self, query):
        query = self.__cleanning_text(query)
        query = self.__stemming_text(query)
        print(query)
        classificator = load('predict-event-model.joblib')
        predictions = classificator.predict_proba([query])


        for prediction in predictions:
            best_label_index = prediction.argmax(axis=0)
            best_label_name = classificator.classes_[best_label_index]

            best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)

            print(classificator.classes_[best_two_labels_index])
            return classificator.classes_[best_two_labels_index]

#
# predictModel = EventPrediction()
# predictModel.clean()
# predictModel.train()
