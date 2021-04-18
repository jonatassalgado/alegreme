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


class EventPricePrediction(object):
    def __init__(self):
        pass
    
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
    
    def predict(self, query):
        query = self.__cleanning_text(query)
        query = self.__stemming_text(query)

        regex = re.compile(r'predict-event__price-model-\d{8}-\d{6}\.pkl$')
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
