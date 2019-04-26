
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
stopwords.extend(['porto', 'alegre', 'dia', 'ano', '“', '”', 'é', '⇨', 'ª', '’', 'página', 'evento', 'poa', 'brasil', 'propõe', 'edição', '01', '2009', 'dessa', 'desse', 'deste', 'chegou', 'hora', 'lugar', 'tempo', 'real', 'mais', 'ajuda', 'problema', 'após', 'acontece', 'boa', 'cheio', 'cheia', 'além', 'acesso', 'consulta', 'pessoas', 'pode', 'ser', 'planejamento', 'próximo', 'precisa', 'possuir', 'qualquer', 'agenda', 'breve', 'todas', 'novidades', 'chega', 'prestigiar', 'local', 'pequeno', 'aqui', 'apresenta', 'sábado', 'frente', 'ré', 'novo', 'nova', 'divulgação', 'participe', 'facebook', 'instagram', 'siga', 'promove', 'realiza', 'de', 'do', 'com', 'da', 'em', 'que', 'para', 'no', 'na', 'um', 'os', 'uma', 'as', 'como', 'por', 'se', 'não', 'dos', 'ao', 'das', 'anos', 'ou', 'sua', 'são', 'seu', 'entrada', 'pela', 'lote', 'àsh', 'nos', 'sobre', 'até', 'tem', 'ingressos', 'entre', 'comunicação', 'valor', 'às', 'pelo', 'também', 'informações', 'você', 'onde', 'meia', 'vida', 'nossa', 'suas', 'dinheiro', 'pra', 'cidade', 'rua', 'já', 'feira', 'shopping', 'inteira', 'pessoa', 'multisom', 'arte', 'quem', 'apresentação', 'espaço', 'casa', 'nas', 'vai', 'rs', 'desconto', 'grupo', 'dash', 'data', 'muito', 'gt', 'abril', 'será', 'todos', 'partir', 'vem', 'venda', 'grande', 'trabalho', 'sul', 'público', 'pagamento', 'quando', 'através', 'dias', 'está', 'seus', 'somente', 'mundo', 'br', 'sem', 'janeiro', 'teatro', 'estudantes', 'horário', 'segunda', 'todo', 'foi', 'nosso', 'forma', 'alimento', 'outros', 'cada', 'voz', 'promocional', 'horários', 'realização', 'estão', 'pontos', 'rio', 'mas', 'ingresso', 'domingo', 'abertura', 'fazer', 'formas', 'história', 'doação', 'canoas', 'vamos', 'gente', 'sexta', 'classificação', 'reduzido', 'dekg', 'disponível', 'idosos', 'desde', 'perecível', 'aos', 'horas', 'projeto', 'av', 'melhor', 'lei', 'serão', 'bem', 'atéh', 'www', 'vez', 'esse', 'locais', 'lista', 'primeiro', 'isso', 'outras', 'objetivo', 'ainda', 'amor', 'joão', 'conta', 'dois', 'essa', 'funcionamento', 'federal', 'formação', 'produção', 'caso', 'contato', 'https', 'maior', 'só', 'há', 'sempre', 'nome', 'toda', 'social', 'duração', 'maio', 'crédito', 'mesmo', 'inscrições', 'verão', 'antes', 'momento', 'oficial', 'vagas', 'centro', 'programa', 'paulo', 'documento', 'esta', 'diversos', 'relações', 'março', 'empresas', 'processos', 'assim', 'especial', 'solidário', 'eventos', 'pessoal', 'ter', 'grandes', 'experiência', 'praia', 'brasileira', 'eu', 'débito', 'durante', 'valores', 'prática', 'carteira', 'online', 'este', 'cartão', 'apenas', 'livre', 'ele', 'bom', 'volta', 'tudo', 'amigos', 'participantes', 'mestre', 'presença', 'whatsapp', 'benefício', 'apoio', 'projetos', 'então', 'criação', 'programação', 'serviço', 'baixa', 'primeira', 'ambiente', 'corpo', 'nomes', 'muita', 'curtir', 'duas', 'maiores', 'bar', 'bourbon', 'artes', 'palco', 'bilheteria', 'pesquisa', 'poder', 'encontro', 'demais', 'foto', 'belas', 'pedro', 'nós', 'podem', 'diferentes', 'parte', 'the', 'dupla', 'saldanha', 'empresa', 'pré', 'estar', 'quatro', 'grupos', 'taxa', 'te', 'conhecer', 'site', 'me', 'mediante', 'técnica', 'práticas', 'convidados', 'limitadas', 'quer', 'fevereiro', 'obra', 'gmail', 'meio', 'fica', 'atualmente', 'identidade', 'aprender', 'área', 'fim', 'venha', 'antecipado', 'sendo', 'apresentar', 'dar', 'uso', 'depois', 'qual', 'identificação', 'ly', 'ideias', 'nossos', 'energia', 'possui', 'hoje', 'lado', 'conteúdo', 'início', 'aulas', 'conveniência', 'avenida', 'final', 'patrocínio', 'segundo', 'obrigatória', 'bit', 'amp', 'diversas', 'participação', 'nossas', 'trabalhos', 'estado', 'nacional', 'ferramentas', 'processo', 'in', 'of', 'acréscimo', 'baixo', 'necessária', 'aceitos', 'graduada', 'sympla', 'região', 'autorais', 'ela', 'alguns', 'inscrição', 'marca', 'sucesso', 'investimento', 'neste', 'mail', 'atenção', 'total', 'reais', 'antecipados', 'melhores', 'internet', 'deverão', 'fernando', 'resultados', 'três', 'teremos', 'internacional', 'geral', 'importantes', 'la', 'principais', 'gaúcha', 'meu', 'barra', 'tribo', 'formada', 'loja', 'produções', 'água', 'entregues', 'lojas', 'mãe', 'mulheres', 'conflitos', 'carlos', 'http', 'som', 'agora', 'irá', 'públicos', 'nessa', 'áreas', 'bairro', 'vista', 'confiança', 'quinta', 'sujeito', 'seja', 'categoria', 'andradas', 'semana', 'documentos', 'humano', 'violenta', 'marcas', 'experiências', 'free', 'vivo', 'país', 'conhecimento', 'ambientes', 'pós', 'organização', 'emocional'])

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

    def __get_top_n_words(self, corpus, n=None):
        vec = CountVectorizer().fit(corpus)
        bag_of_words = vec.transform(corpus)
        sum_words = bag_of_words.sum(axis=0) 
        words_freq = [(word, sum_words[0, idx]) for word, idx in     vec.vocabulary_.items()]
        words_freq =sorted(words_freq, key = lambda x: x[1], reverse=True)
        return words_freq[:n]

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
        X_train, X_test, y_train, y_test = train_test_split(self.X, self.y, test_size=0.15, random_state=True)

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
        
        
    def most_popular_words(self, n=300):
        self.base = self.base.loc[(self.base['description'].notna()) & (self.base['label_b'].notna())]
        self.X = self.base['name'].str.cat(self.base[['description']], sep=' ', na_rep='').values.astype(str)
        self.y = self.base.loc[:, 'label_b'].values.astype(str)

        descriptions_cleanned = []
        for description in self.X:
            descriptions_cleanned.append(self.__cleanning_text(description))
        X = self.__get_top_n_words(descriptions_cleanned, n)
        
        most_popular = []
        for x in X[0:n]:
            most_popular.append(x[0])
        return most_popular

        
    def get_best_params(self):
        classificator = Pipeline([('vect', CountVectorizer(ngram_range=(1, 1))),
                                  ('tfidf', TfidfTransformer(use_idf=True)),
                                  ('clf-svm', SGDClassifier(alpha=0.001, loss='modified_huber', penalty='elasticnet', max_iter=1000))])
        
        from sklearn.model_selection import GridSearchCV
        parameters_svm = {'vect__ngram_range': [(1, 1), (1, 2)],
                          'tfidf__use_idf': (True, False),
                          'clf-svm__alpha': (0.01, 0.001, 0.0001),
                          'clf-svm__penalty': ( 'l2', 'l1', 'elasticnet'),
                          'clf-svm__max_iter': ( 5, 1000),  
                          'clf-svm__loss': ('log', 'modified_huber')}
        
        gs_clf_svm = GridSearchCV(classificator, parameters_svm, n_jobs=-1)
        
        X_train, X_test, y_train, y_test = train_test_split(self.X, self.y, test_size=0.15, random_state=True)
        
        gs_classificator = gs_clf_svm.fit(X_train, y_train)
        return gs_classificator.best_params_

 
# predictModel = EventCategoryPrediction()
# predictModel.clean()
#predictModel.train()
#
#predictModel.predict('<span>Nossa Feira aterriza novamente na Casa de Cultura Mario Quintana como um grande mercado do alternativo, vintage e cultural.<br>Como sempre teremos expositores dos mais variados, um som gostoso e nostálgico e algumas atrações!<br><br>A arara convidada desta vez fica por conta da querida Carol Morandi que traz sua linha de peças em crochê, a Carol Morandi Handmade Crochet, marca local que também irá fazer um desfile pocket em nosso evento!<br><br>Na finaleira não podia faltar o agito dos Teachers Trio na pista, tocando o melhor da Jovem Guarda! Pedida mais que confirmada!<br><br>Não perde!<br><br>***Vai ser em <br>14/04 na Casa de Cultura Mario Quintana, Travessa dos Catavento<br>das 13h às 19h<br><br>ENTRADA FRANCA<br><br>***16h Desfile pocket da marca Carol Morandi Handmade Crochet<br><br>***17h show com a banda Teachers Trio<br><br>/////Em caso de chuva o evento será transferido\\\\\<br><br>Tem uma marca, trabalho artístico, brechó e que expor?<br>Entra em contato conosco pelo<br>mercadodepulgaspoa@gmail.com e manda teu portfólio!<br><br>*Breve mais informações S2<br></span>')
