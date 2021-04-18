import os
import re
import pickle
import pandas as pd
import heapq as hq
import time
import string
import spacy
import base64

from nltk import download
from nltk.tokenize import word_tokenize
from nltk.stem import RSLPStemmer
from nltk.corpus import stopwords
from spacy.matcher import Matcher

from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics import accuracy_score

download('stopwords')
download('punkt')
download('rslp')
download('mac_morpho')

stopwords = stopwords.words('portuguese')
stopwords.extend([
    '01', 'r', 'º', 'r$', '2009', 'abertura', 'abril', 'aceitos', 'acesso',
    'acontece', 'acréscimo', 'agenda', 'agora', 'agosto', 'ainda', 'ajuda',
    'ajudar', 'alegre', 'algo', 'alguns', 'alimento', 'além', 'ambiente',
    'ambientes', 'amigos', 'amor', 'amp', 'andar', 'andradas', 'ano', 'anos',
    'antecipado', 'antecipados', 'antes', 'ao', 'aos', 'apenas', 'apoio',
    'aprender', 'apresenta', 'apresentar', 'apresentação', 'após', 'aqui',
    'arte', 'artes', 'as', 'assim', 'atenção', 'através', 'atual',
    'atualmente', 'até', 'atéh', 'aulas', 'autorais', 'av', 'avenida',
    'bairro', 'baixa', 'baixo', 'bar', 'barra', 'belas', 'bem', 'ben',
    'benefício', 'bilheteria', 'bit', 'boa', 'bom', 'bora', 'bourbon', 'br',
    'brasil', 'brasileira', 'breve', 'cada', 'canoas', 'carlos', 'carteira',
    'cartão', 'casa', 'caso', 'categoria', 'centro', 'chega', 'chegou',
    'cheia', 'cheio', 'chuva', 'cidade', 'claro', 'classificação', 'com',
    'começa', 'como', 'compartilhar', 'comunicação', 'confiança', 'conflitos',
    'conhecer', 'conhecido', 'conhecimento', 'consulta', 'consumo', 'conta',
    'contato', 'conteúdo', 'conveniência', 'convidados', 'corpo', 'criação',
    'crédito', 'curtir', 'da', 'dar', 'das', 'dash', 'data', 'de', 'dekg',
    'demais', 'depois', 'desconto', 'desde', 'dessa', 'desse', 'deste',
    'deverão', 'dezembro', 'dia', 'dias', 'diferentes', 'dinheiro',
    'disponível', 'diversas', 'diversos', 'divulgação', 'do', 'doação',
    'documento', 'documentos', 'dois', 'domingo', 'dos', 'duas', 'dupla',
    'durante', 'duração', 'débito', 'edição', 'ela', 'ele', 'eles', 'em',
    'emocional', 'empresa', 'empresas', 'encontro', 'energia', 'entrada',
    'entre', 'entregues', 'então', 'enviar', 'esgotado', 'espaço', 'especial',
    'essa', 'esse', 'esta', 'estado', 'estar', 'estarão', 'este', 'estudantes',
    'está', 'estão', 'eu', 'evento', 'eventos', 'experiência', 'experiências',
    'facebook', 'fazer', 'federal', 'feira', 'fernando', 'ferramentas',
    'fevereiro', 'fica', 'ficar', 'ficha', 'fila', 'fim', 'final', 'foi',
    'fone', 'fora', 'foram', 'forma', 'formada', 'formas', 'formação', 'foto',
    'free', 'frente', 'funcionamento', 'gaúcha', 'gente', 'geral', 'gmail',
    'graduada', 'grande', 'grandes', 'grupo', 'grupos', 'gt', 'h', 'história',
    'hoje', 'hora', 'horas', 'horário', 'horários', 'http', 'https', 'humano',
    'há', 'i', 'ideias', 'identidade', 'identificação', 'idosos', 'importantes',
    'in', 'inclui', 'informações', 'ingresso', 'ingressos', 'inscrição',
    'inscrições', 'instagram', 'inteira', 'interna', 'internacional',
    'internet', 'investimento', 'início', 'ir', 'irá', 'isso', 'itens',
    'j', 'janeiro', 'joão', 'julho', 'junho', 'já', 'la', 'lado', 'lei',
    'limitadas', 'lista', 'livre', 'locais', 'local', 'loja', 'lojas', 'lote',
    'lugar', 'ly', 'mail', 'maio', 'maior', 'maiores', 'mais', 'marca',
    'marcas', 'março', 'mas', 'me', 'mediante', 'meia', 'meio', 'melhor',
    'melhores', 'mesmo', 'mestre', 'meu', 'momento', 'muita', 'muito',
    'mulheres', 'multisom', 'mundo', 'mãe', 'mês', 'na', 'nacional', 'nas',
    'necessária', 'nessa', 'nesta', 'neste', 'no', 'nome', 'nomes', 'nos',
    'nossa', 'nossas', 'nosso', 'nossos', 'nova', 'novembro', 'novidades',
    'novo', 'num', 'numa', 'não', 'nós', 'número', 'objetivo', 'obra',
    'obrigatória', 'of', 'oficial', 'onde', 'online', 'organização', 'os',
    'ou', 'outras', 'outros', 'outubro', 'pagamento', 'palco', 'para', 'parte',
    'participante', 'participantes', 'participação', 'participe', 'partir',
    'patrocínio', 'paulo', 'país', 'pedro', 'pela', 'pelo', 'pequeno',
    'perecível', 'pesquisa', 'pessoa', 'pessoais', 'pessoal', 'pessoas',
    'planejamento', 'poa', 'pode', 'podem', 'poder', 'pontos', 'por', 'porto',
    'possam', 'possui', 'possuir', 'pra', 'praia', 'precisa', 'presença',
    'prestigiar', 'primeira', 'primeiro', 'principais', 'problema', 'processo',
    'processos', 'produção', 'produções', 'programa', 'programação', 'projeto',
    'projetos', 'promo', 'promocional', 'promove', 'propõe', 'prática',
    'práticas', 'pré', 'próprio', 'próximo', 'página', 'pós', 'público',
    'públicos', 'qual', 'qualquer', 'quando', 'quatro', 'que', 'quem', 'quer',
    'quinta', 'reais', 'real', 'realiza', 'realizar', 'realização', 'receber',
    'reduzido', 'região', 'relações', 'resultados', 'rg', 'rio', 'rs', 'rua',
    'ré', 'saldanha', 'se', 'segunda', 'segundo', 'seja', 'sem', 'semana',
    'sempre', 'sendo', 'ser', 'serviço', 'será', 'serão', 'setembro', 'seu',
    'seus', 'sexta', 'shopping', 'si', 'siga', 'site', 'sob', 'sobre',
    'social', 'solidário', 'som', 'somente', 'sou', 'sua', 'suas', 'sucesso',
    'sujeito', 'sul', 'super', 'sympla', 'sábado', 'são', 'só', 'também',
    'taxa', 'te', 'teatro', 'telefone', 'tem', 'tempo', 'ter', 'teremos',
    'the', 'toda', 'todas', 'todo', 'todos', 'total', 'trabalho', 'trabalhos',
    'tribo', 'três', 'tudo', 'técnica', 'um', 'uma', 'uso', 'vagas', 'vai',
    'valor', 'valores', 'vamos', 'vem', 'venda', 'venha', 'verão', 'vez',
    'vida', 'violenta', 'vista', 'vivo', 'você', 'volta', 'voz', 'vão',
    'whats', 'whatsapp', 'www', 'ª', '°', 'às', 'àsh', 'água', 'área', 'áreas',
    'é', 'último', '—', '‘', '’', '“', '”', '•', '↓', '⇨'
])


class EventCategoryPrediction(object):
    def __init__(self):

        self.debug = {}
        
        if 'IS_DOCKER' in os.environ and os.environ['IS_DOCKER'] == 'true':
            regex = re.compile(r'svm-classification-events-\d{8}-\d{6}\.csv$')
            last_file = max(
                filter(regex.search,
                       os.listdir('/var/www/scrapy/data/classified/')))
            self.base = pd.read_csv('/var/www/scrapy/data/classified/' +
                                    last_file)
            self.base = self.base.drop_duplicates(['source_url'])

        else:
            regex = re.compile(r'svm-classification-events-\d{8}-\d{6}\.csv$')
            last_file = max(
                filter(regex.search,
                       os.listdir('../../../alegreme/scrapy/data/classified')))
            self.base = pd.read_csv('../../../alegreme/scrapy/data/classified/' +
                                    last_file)
            self.base = self.base.drop_duplicates(['source_url'])

    def __cleanning_text(self, text):
        def __downcase(text):
            return text.lower()

        def __remove_digits(text):
            return re.sub(r'\d+', '', text)

        def __remove_ponctuation(text):
            translator = str.maketrans(' ', ' ', string.punctuation)
            return text.translate(translator)

        def __remove_white_spaces(text):
            return " ".join(text.split())

        def __remove_stopwords(text):
            tokens = word_tokenize(text)
            text_without_stopwords = [i for i in tokens if not i in stopwords]
            return ' '.join(text_without_stopwords)

        def __remove_emojis(text):
            return text.encode('latin-1', 'ignore').decode('latin-1')

        def __remove_html_tags(text):
            cleaner = re.compile('<.*?>')
            clean_text = re.sub(cleaner, ' ', text)
            return clean_text

        text = __downcase(text)
        text = __remove_html_tags(text)
        text = __remove_digits(text)
        text = __remove_ponctuation(text)
        text = __remove_emojis(text)
        text = __remove_stopwords(text)
        text = __remove_white_spaces(text)

        return text

    def __get_top_n_words(self, corpus, n=None):
        vec = CountVectorizer().fit(corpus)
        bag_of_words = vec.transform(corpus)
        sum_words = bag_of_words.sum(axis=0)
        words_freq = [[word, sum_words[0, idx]]
                      for word, idx in vec.vocabulary_.items()]
        words_freq = sorted(words_freq, key=lambda x: x[1], reverse=True)
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

    def __get_activities(self, text, n=30):
        nlp = spacy.load("pt_core_news_sm")

        matcher = Matcher(nlp.vocab)

        matcher.add("andar_ADP_NOUN", None, [{
            "LEMMA": "andar"
        }, {
            "POS": "ADP"
        }, {
            "POS": "NOUN"
        }])

        doc = nlp(text)
        matches = matcher(doc)

        activities = []
        for match_id, start, end in matches:
            span = doc[start:end]
            activities.append(span.text)

        return activities[:30]

    def __get_verbs(self, text, n=30):
        nlp = spacy.load("pt_core_news_sm")
        matcher = Matcher(nlp.vocab)
        matcher.add("VERB", None, [{"TEXT": {"REGEX": "(.+(er|ar|ir)$)"}}])

        doc = nlp(text)
        matches = matcher(doc)

        verbs = []
        for match_id, start, end in matches:
            span = doc[start:end]
            verbs.append(span.text)

        return verbs[:n]

    def __get_nouns(self, text, n=30):
        nlp = spacy.load("pt_core_news_sm")
        matcher = Matcher(nlp.vocab)
        matcher.add("NOUN", None, [{"POS": "NOUN"}])

        doc = nlp(text)
        matches = matcher(doc)

        verbs = []
        for match_id, start, end in matches:
            span = doc[start:end]
            verbs.append(span.text)

        return verbs[:n]

    def __get_adjs(self, text, n=30):
        nlp = spacy.load("pt_core_news_sm")
        matcher = Matcher(nlp.vocab)
        matcher.add("ADJ", None, [{"POS": "ADJ"}])

        doc = nlp(text)
        matches = matcher(doc)

        adjs = []
        for match_id, start, end in matches:
            span = doc[start:end]
            adjs.append(span.text)

        return adjs[:n]

    def __get_similarity(self, idx=0):
        ids = [i for i, value in enumerate(self.X_stemmed)]

        d = {
            'ids': ids,
            'stemmed': self.X_stemmed,
            'cleanned': self.X_cleanned
        }
        df = pd.DataFrame(data=d)

        count = TfidfVectorizer(ngram_range=(1, 2), min_df=0)
        count_matrix = count.fit_transform(df['stemmed'])

        cosine_sim = cosine_similarity(count_matrix, count_matrix)

        similar_items = []

        score_series = pd.Series(cosine_sim[idx]).sort_values(ascending=False)
        top_10_items = [
            list(score_series.iloc[1:11].index),
            list(score_series.iloc[1:11].values)
        ]

        for index, top_index in enumerate(top_10_items[0]):
            similar_descriptions_cleanned = df.loc[top_index, 'cleanned']
            similar_indexes = round(top_10_items[1][index], 6)
            similar_items.append(
                [similar_descriptions_cleanned, similar_indexes])

        tops_tfifd = self.__get_top_tfifd(df, idx)

        return similar_items, tops_tfifd

    def __get_top_tfifd(self, df, doc=0, n=30):
        tf = TfidfVectorizer(ngram_range=(1, 2), min_df=0)
        matrix = tf.fit_transform(df['cleanned'])

        feature_names = tf.get_feature_names()
        feature_index = matrix[doc, :].nonzero()[1]
        tfidf_scores = zip(feature_index,
                           [matrix[doc, x] for x in feature_index])

        top_tfifds = []
        for w, s in [(feature_names[i], s) for (i, s) in tfidf_scores]:
            top_tfifds.append([w, round(s, 6)])

        top_tfifds.sort(key=lambda tup: tup[1], reverse=True)

        return top_tfifds[:n]

    def clean(self):

        self.base = self.base.loc[(self.base['description'].notna())
                                  & (self.base['category'].notna())]
        self.X = self.X_raw = self.base['name'].str.cat(
            self.base[['description']], sep=' ', na_rep='').values.astype(str)
        self.y = self.base.loc[:, 'category'].values.astype(str)

        descriptions_cleanned = []
        for description in self.X:
            word_list = word_tokenize(description)
            description = ' '.join(
                [word for word in word_list if word not in stopwords])
            descriptions_cleanned.append(self.__cleanning_text(description))
        self.X_cleanned = descriptions_cleanned

        descriptions_stemmed = []
        for description in self.X_cleanned:
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

        self.X = self.X_stemmed = descriptions_stemmed

    def bag_of_words(self):

        bag = []

        for idx, description in enumerate(self.X_raw):
            text_cleanned = self.X_cleanned[idx]
            text_stemmed = self.X_stemmed[idx]
            text_words_freq = self.__get_top_n_words([text_cleanned], 30)
            text_nouns = self.__get_nouns(text_cleanned)
            text_verbs = self.__get_verbs(text_cleanned)
            similar_texts, text_top_tfifd = self.__get_similarity(idx)
            #text_adjs = self.__get_adjs(text_cleanned)
            #text_activities = self.__get_activities(text_cleanned)

            item = {
                'text': description,
                'cleanned': text_cleanned,
                'stemmed': text_stemmed,
                'freq': text_words_freq,
                'nouns': text_nouns,
                'verbs': text_verbs,
                'similar_texts': similar_texts,
                'text_top_tfifd': text_top_tfifd
                #'adjs': text_adjs,
                #'activities': text_activities
            }

            bag.append(item)

        return bag

    def train(self):

        X_train, X_test, y_train, y_test = train_test_split(self.X,
                                                            self.y,
                                                            test_size=0.01,
                                                            random_state=True)

        classificator = Pipeline([
            ('tfidf', TfidfVectorizer(ngram_range=(1, 1))),
            ('clf-svm', SGDClassifier(alpha=0.001, loss='modified_huber', penalty='l2'))
        ])

        classificator = classificator.fit(X_train, y_train)
        timestr = time.strftime("%Y%m%d-%H%M%S")
        pickle.dump(classificator, open('predict-event__category-model-' + timestr + '.pkl', 'wb'))

        predictions = classificator.predict_proba(X_test)

        predictions_labels = []
        predictions_scores = []
        for prediction in predictions:
            best_two_labels_index = hq.nlargest(2, range(len(prediction)), prediction.take)
            predictions_labels.append(classificator.classes_[best_two_labels_index])
            predictions_scores.append(hq.nlargest(2, prediction))
        
        self.debug['predictionsLabels'] = predictions_labels

        accuracy = accuracy_score([i[0] for i in predictions_labels], y_test)
        accuracyb = accuracy_score([i[1] for i in predictions_labels], y_test)
        accuracyc = accuracy + accuracyb

        self.debug['predictionsVssLabels'] = [[label[0], y_test[idx], round(predictions_scores[idx][0], 6),  X_test[idx][:35]] for idx, label in enumerate(predictions_labels)]

        print(accuracy)
        print(accuracyb)
        print(accuracyc)

    def predict(self, query):
        query = self.__cleanning_text(query)
        query = self.__stemming_text(query)

        regex = re.compile(r'predict-event__category-model-\d{8}-\d{6}\.pkl$')
        last_file = max(filter(regex.search, os.listdir('./')))

        classificator = pickle.load(open(last_file, "rb"))
        predictions = classificator.predict_proba([query])

        for prediction in predictions:
            best_two_labels_index = hq.nlargest(2, range(len(prediction)),
                                                prediction.take)
            best_labels_name = classificator.classes_[best_two_labels_index]
            best_labels_score = hq.nlargest(2, prediction)

            output = [[best_labels_name[0], round(best_labels_score[0], 6)],
                      [best_labels_name[1], round(best_labels_score[1], 6)]]
            print(output)
            return output

    def most_popular_words(self, n=300):
        self.base = self.base.loc[(self.base['description'].notna())
                                  & (self.base['category'].notna())]
        self.X = self.base['name'].str.cat(self.base[['description']],
                                           sep=' ',
                                           na_rep='').values.astype(str)
        self.y = self.base.loc[:, 'category'].values.astype(str)

        descriptions_cleanned = []
        for description in self.X:
            descriptions_cleanned.append(self.__cleanning_text(description))
        X = self.__get_top_n_words(descriptions_cleanned, n)

        most_popular = []
        for x in X[0:n]:
            most_popular.append(x[0])
        return most_popular

    def get_best_params(self):
        classificator = Pipeline([('tfidf', TfidfVectorizer()),
                                  ('clf-svm', SGDClassifier())])

        from sklearn.model_selection import GridSearchCV
        parameters_svm = {
            'tfidf__ngram_range': [(1, 1), (1, 2), (1, 3), (2, 3)],
            'clf-svm__alpha': (0.01, 0.001, 0.0001),
            'clf-svm__penalty': ('l2', 'l1', 'elasticnet'),
            'clf-svm__max_iter': (5, 1000),
            'clf-svm__loss': ('log', 'modified_huber')
        }

        gs_clf_svm = GridSearchCV(classificator, parameters_svm, n_jobs=-1)

        X_train, X_test, y_train, y_test = train_test_split(self.X,
                                                            self.y,
                                                            test_size=0.01,
                                                            random_state=True)

        gs_classificator = gs_clf_svm.fit(X_train, y_train)
        return gs_classificator.best_params_


#predictModel = EventCategoryPrediction()
#predictModel.clean()
#predictModel.train()
#predictModel.debug
#bagOfWords = predictModel.bag_of_words()

#stemmed, cleanned = predictModel.X
#mostFreq = predictModel.most_popular_words

#
#predictModel.predict('<span>Nossa Feira aterriza novamente na Casa de Cultura Mario Quintana como um grande mercado do alternativo, vintage e cultural.<br>Como sempre teremos expositores dos mais variados, um som gostoso e nostálgico e algumas atrações!<br><br>A arara convidada desta vez fica por conta da querida Carol Morandi que traz sua linha de peças em crochê, a Carol Morandi Handmade Crochet, marca local que também irá fazer um desfile pocket em nosso evento!<br><br>Na finaleira não podia faltar o agito dos Teachers Trio na pista, tocando o melhor da Jovem Guarda! Pedida mais que confirmada!<br><br>Não perde!<br><br>***Vai ser em <br>14/04 na Casa de Cultura Mario Quintana, Travessa dos Catavento<br>das 13h às 19h<br><br>ENTRADA FRANCA<br><br>***16h Desfile pocket da marca Carol Morandi Handmade Crochet<br><br>***17h show com a banda Teachers Trio<br><br>/////Em caso de chuva o evento será transferido\\\\\<br><br>Tem uma marca, trabalho artístico, brechó e que expor?<br>Entra em contato conosco pelo<br>mercadodepulgaspoa@gmail.com e manda teu portfólio!<br><br>*Breve mais informações S2<br></span>')
