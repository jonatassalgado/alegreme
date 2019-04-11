
import os
import re
import pandas as pd
import numpy as np
import heapq as hq
import time

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

class EventCategoryPrediction(object):

    def __init__(self):
        regex = re.compile(r'svm-classification-events-\d{8}-\d{6}\.csv$')
        last_file = max(filter(regex.search, os.listdir('../')))
        self.base = pd.read_csv('../' + last_file)


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
        self.base = self.base.loc[(self.base['description'].notna()) & (self.base['label_b'].notna())]
        self.X = self.base['name'].str.cat(self.base[['description']], sep=' ', na_rep='').values.astype(str)
        self.y = self.base.loc[:, 'label_b'].values.astype(str)

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
        X_train, X_test, y_train, y_test = train_test_split(self.X, self.y, test_size=0.10, random_state=True)

        classificator = Pipeline([('vect', CountVectorizer(ngram_range=(1, 1))),
                                  ('tfidf', TfidfTransformer(use_idf=True)),
                                  ('clf-svm', SGDClassifier(alpha=0.001, loss='modified_huber', penalty='elasticnet', max_iter=1000))])

        classificator = classificator.fit(X_train, y_train)
        timestr = time.strftime("%Y%m%d-%H%M%S")
        dump(classificator, 'predict-event__category-model-' + timestr + '.joblib')
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

        regex = re.compile(r'predict-event__category-model-\d{8}-\d{6}\.joblib$')
        last_file = max(filter(regex.search, os.listdir('./')))

        classificator = load(last_file)
        predictions = classificator.predict_proba([query])


        for prediction in predictions:
            best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)
            best_labels_name = classificator.classes_[best_two_labels_index]
            best_labels_score = hq.nlargest(2, prediction)

            output = [
                        [best_labels_name[0], best_labels_score[0]],
                        [best_labels_name[1], best_labels_score[1]]
                     ]
            print(output)
            return output


predictModel = EventCategoryPrediction()
predictModel.clean()
predictModel.train()

predictModel.predict('Workshop: EMPATIA para liderança disruptiva.  <br>Como impulsionar ideias, engajamento e inovação.<br>Objetivo do Workshop?<br>Estimular a responsabilidade pessoal para desenvolvimento de pessoas através da valorização de idéias, estímulo a empatia e reforço da confiança relações de parceria do grupo. Através de metodologias inovadoras e criativas baseados nos princípios do Art of Hosting - Arte de Anfitriar -, o maior objetivo é estimular profissionais a desenvolverem em si e no outro a responsabilidade, autonomia e confiança para criarem novas ideias, inovar e buscar oportunidades de melhoria contínua, trazendo alto valor ao trabalho final executado pela organização. Questionar e minimizar paradigmas que dificultem relacionamentos para que o colaborador assuma a postura de protagonista e responsável por gerar resultados em seu entorno e busca de melhoria continua. Aprender a estimular a inteligência coletiva que surge da colaboração de muitos indivíduos em suas diversidades.<br>O que você vai aprender?  <br>Você vai aprender como construir um clima de confiança que conecta e facilita os processo de trabalho, melhora a comunicação e promove a colaboração. Transmitir confiança e credibilidade em suas relações e assim criar ambientes de cooperação saudáveis, construtivos e produtivos, ampliando a resolução de problemas, a inovação e o engajamento de equipes. <br>Conteúdo programático e módulos:<br>- Conceitos de liderança disruptiva, colaboração e inteligência emocional<br>- Propósito e valores individuais X organizacionais<br>- Autoconhecimento e quebra de paradigmas  - precisamos falar sobre autonomia, controle e confiança<br>- Mindfulness e liderança <br>- Colaboração gera resultados práticos? <br>- Metodologia World Café <br>- Ambientes de confiança e inovação<br>A quem se destina? <br>Líderes e funcionários que queiram desenvolver habilidades de liderança e criar ambientes de colaboração, inovação e confiança entre suas equipe<br>Instrutora: <br>Semadar Marques - Escritora, palestrante e uma estudiosa do comportamento humano, com doze anos de experiência e mais de 500 palestras ministradas. Facilitadora de aprendizagens sobre Empatia e Liderança Colaborativa, sou analista em Inteligência Emocional pela Six Seconds Emotional Intelligence (SEI), com diversas formações em desenvolvimento emocional. Também sou umas das 30 facilitadoras no Brasil do método Heal Your Life®, criado e disseminado no mundo inteiro pela escritora Louise Hay. <br>Vasta formação e experiência na área, ministrando palestras, conferências e workshops sobre estes temas por todo o pais. Mas gosta mesmo de se apresentar falando sobre sua capacidade de facilitar conversas que despertem reflexões profundas e questionamentos internos, criando equipes mais colaborativas e criativas, estimulando conexões saudáveis e incentivando-as a desafiar suas crenças e serem melhores a cada dia. <br>Tem como maiores influências Daniel Goleman, autor da teoria da Inteligência Emocional, Marshal Rosemberg, criador do conceito de Comunicação Não Violenta e Brene Brown, pesquisadora e conferencista americana que estuda conexões humanas e nossa habilidade de empatia. Também colunista do Portal RHevista RH e tem textos publicados em diversos sites e jornais de todo o Brasil, dentre eles a Folha de São Paulo, a Revista Donna do Jornal Zero Hora e a Associação Brasileira de Recursos Humanos - ABRH Brasil. <br>Data: 03/04/2019<br>Horário: 19h às 22h<br>Local: CC100 Av. Cristóvão Colombo, 100 – Floresta – Porto Alegre.<br>Carga horária: 3 horas<br>Informações: contato@eventsoffice.com.br ou WhatsApp (51) 984328121. ')
