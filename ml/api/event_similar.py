import pandas as pd
import base64
import json

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


class EventSimilar(object):
    def __get_similarity(self, current_text_index, base):

        similar_items = []

        current_text_index = json.loads(current_text_index)
        base = json.loads(base)

        d = {
            'text': [value[0] for idx, value in enumerate(base)],
            'ids': [value[1] for idx, value in enumerate(base)],
        }

        df = pd.DataFrame(data=d)

        count = TfidfVectorizer(ngram_range=(1, 2), min_df=0)
        count_matrix = count.fit_transform(df['text'])
        cosine_sim = cosine_similarity(count_matrix, count_matrix)

        score_series = pd.Series(
            cosine_sim[current_text_index]).sort_values(ascending=False)

        top_10_items = [
            list(score_series.iloc[1:11].index),
            list(score_series.iloc[1:11].values)
        ]

        for index, similar_index in enumerate(top_10_items[0]):
            similar_scores = round(top_10_items[1][index], 6)
            similar_descriptions = df.loc[similar_index, 'text']
            similar_ids = int(df.loc[similar_index, 'ids'])

            similar_items.append(
                [similar_descriptions, similar_scores, similar_ids])

        similar_items_ids = [item[2] for item in similar_items]

        return similar_items_ids

    def get_similarity(self, text, base):
        base = base64.b64decode(base).decode('utf-8')
        similarity = self.__get_similarity(text, base)

        print(similarity)
        return similarity


# predictModel = EventCategoryPrediction()
# predictModel.clean()
# predictModel.train()
#predictModel.debug
#bagOfWords = predictModel.bag_of_words()

#stemmed, cleanned = predictModel.X
#mostFreq = predictModel.most_popular_words

#
#predictModel.predict('<span>Nossa Feira aterriza novamente na Casa de Cultura Mario Quintana como um grande mercado do alternativo, vintage e cultural.<br>Como sempre teremos expositores dos mais variados, um som gostoso e nostálgico e algumas atrações!<br><br>A arara convidada desta vez fica por conta da querida Carol Morandi que traz sua linha de peças em crochê, a Carol Morandi Handmade Crochet, marca local que também irá fazer um desfile pocket em nosso evento!<br><br>Na finaleira não podia faltar o agito dos Teachers Trio na pista, tocando o melhor da Jovem Guarda! Pedida mais que confirmada!<br><br>Não perde!<br><br>***Vai ser em <br>14/04 na Casa de Cultura Mario Quintana, Travessa dos Catavento<br>das 13h às 19h<br><br>ENTRADA FRANCA<br><br>***16h Desfile pocket da marca Carol Morandi Handmade Crochet<br><br>***17h show com a banda Teachers Trio<br><br>/////Em caso de chuva o evento será transferido\\\\\<br><br>Tem uma marca, trabalho artístico, brechó e que expor?<br>Entra em contato conosco pelo<br>mercadodepulgaspoa@gmail.com e manda teu portfólio!<br><br>*Breve mais informações S2<br></span>')
