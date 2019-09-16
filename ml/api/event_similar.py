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
            list(score_series.iloc[1:17].index),
            list(score_series.iloc[1:17].values)
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

#        print(similarity)
        return similarity


#predictModel = EventSimilar()
#predictModel.get_similarity(1)
