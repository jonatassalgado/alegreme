import re
import string
import spacy
import base64

from nltk import download
from nltk.tokenize import word_tokenize
from nltk.stem import RSLPStemmer
from nltk.corpus import stopwords
from spacy.matcher import Matcher

from bs4 import BeautifulSoup

from sklearn.feature_extraction.text import CountVectorizer

download('stopwords')

stopwords = stopwords.words("portuguese")
custom_stopwords = [
    "01", "r", "º", "r$", "2009", "abertura", "abril", "aceitos", "acesso", "acontece", "acréscimo", "agenda", "agora", "agosto", "ainda", "ajuda", "ajudar", "alegre", "algo", "alguns", "alimento", "além", "ambiente", "ambientes", "amigos", "amor", "amp", "andar", "andradas", "ano", "anos", "antecipado", "antecipados", "antes", "ao", "aos", "apenas", "apoio", "aprender", "apresenta", "apresentar", "apresentação", "após", "aqui", "arte", "artes", "as", "assim", "atenção", "através", "atual", "atualmente", "até", "atéh", "aulas", "autorais", "av", "avenida", "bairro", "baixa", "baixo", "bar", "barra", "belas", "bem", "ben", "benefício", "bilheteria", "bit", "boa", "bom", "bora", "bourbon", "br", "brasil", "brasileira", "breve", "calendário", "cada", "canoas", "carlos", "carteira", "cartão", "casa", "caso", "categoria", "centro", "chega", "chegou", "cheia", "cheio", "chuva", "cidade", "claro", "classificação", "com", "começa", "como", "compartilhar", "comunicação", "confiança", "conflitos", "conhecer", "conhecido", "conhecimento", "consulta", "consumo", "conta", "contato", "conteúdo", "conveniência", "convidados", "corpo", "criação", "crédito", "curtir", "da", "dar", "das", "dash", "data", "de", "dekg", "demais", "depois", "desconto", "desde", "dessa", "desse", "deste", "deverão", "dezembro", "dia", "dias", "diferentes", "dinheiro", "disponível", "diversas", "diversos", "divulgação", "do", "doação", "documento", "documentos", "dois", "domingo", "dos", "dose", "duas", "dupla", "durante", "duração", "débito", "edição", "ela", "ele", "eles", "em", "emocional", "empresa", "empresas", "encontro", "energia", "entrada", "entre", "entregues", "então", "enviar", "esgotado", "espaço", "esquema", "especial", "essa", "esse", "esta", "estado", "estadual", "estar", "estarão", "este", "estudantes", "está", "estão", "eu", "evento", "eventos", "experiência", "experiências", "facebook", "fazer", "federal", "feira", "fernando", "ferramentas", "fevereiro", "fica", "ficar", "ficha", "fila", "fim", "final", "foi", "fone", "fora", "foram", "forma", "formada", "formas", "formação", "foto", "free", "frente", "funcionamento", "gaúcha", "gente", "geral", "gmail", "graduada", "grande", "grandes", "grupo", "grupos", "gt", "h", "história", "hoje", "hora", "horas", "horário", "horários", "http", "https", "humano", "há", "i", "ideias", "identidade", "identificação", "idosos", "importantes", "in", "inclui", "informações", "ingresso", "ingressos", "inscrição", "inscrições", "instagram", "inteira", "interna", "internacional", "internet", "investimento", "início", "ir", "irá", "isso", "itens", "j", "janeiro", "joão", "julho", "junho", "já", "la", "lado", "lei", "limitadas", "lista", "livre", "locais", "local", "loja", "lojas", "lote", "lugar", "ly", "mail", "maio", "maior", "maiores", "mais", "marca", "marcas", "março", "mas", "me", "mediante", "meia", "meio", "melhor", "melhores", "mesmo", "mestre", "meu", "momento", "muita", "muito", "mulheres", "multisom", "mundo", "mãe", "mês", "na", "nacional", "nas", "necessária", "nessa", "nesta", "neste", "no", "nome", "nomes", "nos", "nossa", "nossas", "nosso", "nossos", "nova", "novembro", "novidades", "novo", "num", "numa", "não", "nós", "número", "objetivo", "obra", "obrigatória", "of", "oficial", "onde", "online", "organização", "os", "ou", "outras", "outros", "outubro", "pagamento", "palco", "para", "parte", "participante", "participantes", "participação", "participe", "partir", "patrocínio", "paulo", "país", "pedro", "pela", "pelo", "pequeno", "perecível", "pesquisa", "pessoa", "pessoais", "pessoal", "pessoas", "planejamento", "poa", "pode", "podem", "poder", "pontos", "por", "porto", "possam", "possui", "possuir", "pra", "praia", "precisa", "presença", "prestigiar", "primeira", "primeiro", "principais", "problema", "processo", "processos", "produção", "produções", "programa", "programação", "projeto", "projetos", "promo", "promocional", "promove", "propõe", "prática", "práticas", "pré", "próprio", "próximo", "página", "pós", "público", "públicos", "qual", "qualquer", "quando", "quatro", "que", "quem", "quer", "quinta", "reais", "real", "realiza", "realizar", "realização", "receber", "reduzido", "região", "relações", "resultados", "rg", "rio", "rs", "rua", "ré", "saldanha", "se", "segunda", "segundo", "seja", "sem", "semana", "sempre", "sendo", "ser", "serviço", "será", "serão", "setembro", "seu", "seus", "sexta", "shopping", "si", "siga", "site", "sob", "sobre", "social", "solidário", "som", "somente", "sou", "sua", "suas", "sucesso", "sujeito", "sul", "super", "sympla", "sábado", "são", "só", "também", "taxa", "te", "teatro", "telefone", "tem", "tempo", "ter", "teremos", "the", "toda", "todas", "todo", "todos", "total", "trabalho", "trabalhos", "tribo", "três", "tudo", "técnica", "um", "uma", "uso", "vagas", "vai", "valor", "valores", "vamos", "vem", "venda", "venha", "verão", "vez", "vida", "violenta", "vista", "vivo", "você", "volta", "voz", "vão", "whats", "whatsapp", "www", "ª", "°", "às", "àsh", "água", "área", "áreas", "é", "último", "—", "‘", "’", "“", "”", "•", "↓", "⇨", "articula ", "integra ", "documenta", "difunde", "produzida", "dentro", "propor", "extensões", "confira", "encontrar", "gaúcho", "instigante", "capaz", "acionar", "segundas", "sextasfeiras", "permanente", "outro", "moeda", "permanente", "confira", "completa", "terçafeira", "domingos", "feriados", "descontos", "clientes", "benefícios", "meiaentrada", "comprovante", "pertencentes", "famílias", "renda", "idade", "deficiência", "acompanhante", "necessário", "doadores", "sangue", "saiba", "comprovar", "acessando", "importante", "limitados", "sujeitos", "disponibilidade", "dê", "preferência", "compras", "vacinação", "vacinalcompleto", "operando", "capacidade", "lotação", "reduzida", "lugares", "ocupados", "ordem", "chegada", "cedo", "escolher", "regras", "obrigatório", "máscara", "obrigatório", "cumprimento", "regras", "protocolos", "segurança", "vetada", "menores", "vetada", "responsável", "algum", "sintoma", "suspeita", "covid", "evite", "vir", "convivência", "direta", "parentes", "risco", "mantenha", "distanciamento", "pega", "mandar", "levar", "sextafeira", "novos", "vier", "cabeça", "comprou", "ganha", "mostrar", "garante", "via", "preço", "circular", "proibido", "disponibilizadas", "mesas", "cadeiras", "álcool", "gel", "estratégicos", "aceitamos", "cartões", "bandeiras", "visa", "master", "elo", "criado", "arrecadar", "fundos", "envolvidos", "doaram", "arrecadado", "revertido", "organizado", "apresentadoras", "juntamente", "diretora", "polícia", "web", "tv", "gentilmente", "cedeu", "seguirá", "conforme", "decreto", "governamental",
]
stopwords.extend(custom_stopwords)


class EventFeatures(object):

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
            text = BeautifulSoup(text, "html.parser")
            links = text.select("a")
            for link in links:
                link.decompose()

            cleaner = re.compile('<.*?>')
            text = re.sub(cleaner, ' ', str(text))
            text = re.sub(r'htt(s|)\S+', '', text, flags=re.MULTILINE)
            return text

        text = __remove_html_tags(text)
        text = __downcase(text)
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
        words_freq = [[word, int(sum_words[0, idx])]
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

        matcher.add("andar_ADP_NOUN", [[{
            "LEMMA": "andar"
        }, {
            "POS": "ADP"
        }, {
            "POS": "NOUN"
        }]])

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
        matcher.add("VERB", [[{"TEXT": {"REGEX": "(.+(er|ar|ir)$)"}}]])

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
        matcher.add("NOUN", [[{"POS": "NOUN"}]])

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
        matcher.add("ADJ", [[{"POS": "ADJ"}]])

        doc = nlp(text)
        matches = matcher(doc)

        adjs = []
        for match_id, start, end in matches:
            span = doc[start:end]
            adjs.append(span.text)

        return adjs[:n]

    def __bag_of_words(self, text_cleanned, text_stemmed):
        pass
    # text_top_tfifd = self.__get_top_tfifd(text_cleanned)
    # text_activities = self.__get_activities(text_cleanned)

    def extract_features(self, text):
        text_cleanned = self.__cleanning_text(text)
        text_stemmed = self.__stemming_text(text_cleanned)

        text_words_freq = self.__get_top_n_words([text_cleanned], 30)
        text_nouns = self.__get_nouns(text_cleanned)
        text_verbs = self.__get_verbs(text_cleanned)
        text_adjs = self.__get_adjs(text_cleanned)

        item = {
            'cleanned': text_cleanned,
            'stemmed': text_stemmed,
            'freq': text_words_freq,
            'nouns': text_nouns,
            'verbs': text_verbs,
            'adjs': text_adjs
        }

        return item


# predictModel = EventPersonaPrediction()
# predictModel.clean()
# predictModel.train()
# predictModel.debug
#bagOfWords = predictModel.bag_of_words()

#stemmed, cleanned = predictModel.X
#mostFreq = predictModel.most_popular_words

#
# predictModel.get_features('<span>Nossa Feira aterriza novamente na Casa de Cultura Mario Quintana como um grande mercado do alternativo, vintage e cultural.<br>Como sempre teremos expositores dos mais variados, um som gostoso e nostálgico e algumas atrações!<br><br>A arara convidada desta vez fica por conta da querida Carol Morandi que traz sua linha de peças em crochê, a Carol Morandi Handmade Crochet, marca local que também irá fazer um desfile pocket em nosso evento!<br><br>Na finaleira não podia faltar o agito dos Teachers Trio na pista, tocando o melhor da Jovem Guarda! Pedida mais que confirmada!<br><br>Não perde!<br><br>***Vai ser em <br>14/04 na Casa de Cultura Mario Quintana, Travessa dos Catavento<br>das 13h às 19h<br><br>ENTRADA FRANCA<br><br>***16h Desfile pocket da marca Carol Morandi Handmade Crochet<br><br>***17h show com a banda Teachers Trio<br><br>/////Em caso de chuva o evento será transferido\\\\\<br><br>Tem uma marca, trabalho artístico, brechó e que expor?<br>Entra em contato conosco pelo<br>mercadodepulgaspoa@gmail.com e manda teu portfólio!<br><br>*Breve mais informações S2<br></span>')
