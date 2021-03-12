import os
import re
import pickle
import heapq as hq
import numpy as np
import time
import string
import pdb

from nltk import download
from nltk.tokenize import word_tokenize
from nltk.stem import RSLPStemmer
from nltk.corpus import stopwords

from sklearn import preprocessing
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics import accuracy_score

from joblib import dump, load

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


from label_studio.ml import LabelStudioMLBase

class EventCategoryClassifier(LabelStudioMLBase):

    def __init__(self, **kwargs):
        # don't forget to initialize base class...
        super(EventCategoryClassifier, self).__init__(**kwargs)

        # then collect all keys from config which will be used to extract data from task and to form prediction
        # Parsed label config contains only one output of <Choices> type
        assert len(self.parsed_label_config) == 1
        self.from_name, self.info = list(self.parsed_label_config.items())[0]
        assert self.info['type'] == 'Choices'

        # the model has only one textual input
        assert len(self.info['to_name']) == 1
        assert len(self.info['inputs']) == 1
        assert self.info['inputs'][0]['type'] == 'Text'
        self.to_name = self.info['to_name'][0]
        self.value = self.info['inputs'][0]['value']
        
        self.le = preprocessing.LabelEncoder()
        self.le.fit(self.info['labels'])

        if not self.train_output:
            # If there is no trainings, define cold-started the simple TF-IDF text classifier
            self.reset_model()
            # This is an array of <Choice> labels
            self.labels = self.info['labels']
            # make some dummy initialization
            self.model.fit(X=self.labels, y=list(range(len(self.labels))))
            print('Initialized with from_name={from_name}, to_name={to_name}, labels={labels}'.format(
                from_name=self.from_name, to_name=self.to_name, labels=str(self.labels)
            ))
        else:
            # otherwise load the model from the latest training results
            self.model_file = self.train_output['model_file']
            with open(self.model_file, mode='rb') as f:
                self.model = pickle.load(f)
            # and use the labels from training outputs
            self.labels = self.info['labels']
            print('Loaded from train output with from_name={from_name}, to_name={to_name}, labels={labels}'.format(
                from_name=self.from_name, to_name=self.to_name, labels=str(self.labels)
            ))


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


    def __stemming_text(self, text):
        text_tokenized = word_tokenize(text)
        text_stemmed = []
        for word in text_tokenized:
            stemmer = RSLPStemmer()
            if word not in stopwords:
                text_stemmed.append(stemmer.stem(word))
                pass
        return ' '.join(text_stemmed)


    def reset_model(self):
        self.model = Pipeline([
            ('tfidf', TfidfVectorizer(ngram_range=(1, 1))),
            ('clf-svm', SGDClassifier(alpha=0.001, loss='modified_huber', penalty='l2'))
        ])


    def predict(self, tasks, **kwargs):
        # collect input texts
        input_texts = []
        for task in tasks:
            text = task['data'][self.value]
            text = self.__cleanning_text(text)
            text = self.__stemming_text(text)
            input_texts.append(text)

        # get model predictions
        probabilities = self.model.predict_proba(input_texts)
        predicted_label_indices = np.argmax(probabilities, axis=1)
        predicted_scores = probabilities[np.arange(len(predicted_label_indices)), predicted_label_indices]
        predictions = []
        for idx, score in zip(predicted_label_indices, predicted_scores):
            predicted_label = list(self.le.inverse_transform([idx]))
            # prediction result for the single task
            result = [{
                'from_name': self.from_name,
                'to_name': self.to_name,
                'type': 'choices',
                'value': {'choices': predicted_label}
            }]

            # expand predictions with their scores for all tasks
            predictions.append({'result': result, 'score': score})

        return predictions


    def fit(self, completions, workdir=None, **kwargs):
        input_texts = []
        output_labels, output_labels_idx = [], []
        label2idx = {l: i for i, l in enumerate(self.labels)}
        for completion in completions:
            # get input text from task data

            if completion['completions'][0].get('skipped') or completion['completions'][0].get('was_cancelled'):
                continue

            input_text = completion['data'][self.value]
            input_text = self.__cleanning_text(input_text)
            input_text = self.__stemming_text(input_text)
            input_texts.append(input_text)

            # get an annotation
            output_label = completion['completions'][0]['result'][0]['value']['choices'][0]
            output_labels.append(output_label)
            # output_label_idx = label2idx[output_label]
            # output_labels_idx.append(output_label_idx)

        # new_labels = set(output_labels)
        # if len(new_labels) != len(self.labels):
        #     self.labels = list(sorted(new_labels))
        #     print('Label set has been changed:' + str(self.labels))
        #     label2idx = {l: i for i, l in enumerate(self.labels)}
        #     output_labels_idx = [label2idx[label] for label in output_labels]

        # train the model
        # pdb.set_trace()
        
        self.reset_model()
        self.model.fit(input_texts, self.le.transform(output_labels))
        # self.model.fit(input_texts, output_labels_idx)

        # save output resources
        model_file = os.path.join(workdir, 'model.pkl')
        with open(model_file, mode='wb') as fout:
            pickle.dump(self.model, fout)

        train_output = {
            'labels': output_labels,
            'model_file': model_file
        }
        return train_output