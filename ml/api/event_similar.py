import pandas as pd
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
            
            if similar_scores >= 0.02:
                similar_items.append([similar_descriptions, similar_scores, similar_ids])

        similar_items_ids = [item[2] for item in similar_items]

        return similar_items_ids

    def get_similarity(self, text, base):
        similarity = self.__get_similarity(text, base)

        return similarity


# base = "[[\"god sav queen araúj viann god sav queen eleit revist rolling ston band tribut queen traz show auditóri araúj viann conseg cri sens vend ouv queen integr ocup mesm cen instrument orig vestu cenograf cop detalh band freddi mercury brian may john deacon rog tayl god sav queen araúj viann osvald aranh eduard holm pont uno plate alt later plate alt centr plate later plate centr plate gold meiaentr estudantil cie espetácul vál determin descont jov pertenc famíl rend jov defici acompanh necess prest continu assist defici emit institut segur ins doad regul sang estad n° vál exped hemocentrosbanc sang sóci club assin zh vers lindo cobranç vers gal chav planet surf iguatem wallig ipirang wwwsymplacombraraujoviann wwwaraujoviannaoficialcombr wwwfacebookcomaraujoviannaofic wwwtwittercomaraujoviann araúj viann\", 9693], [\"paul viol araúj viann paul viol samb auditóri araúj viann carr músic deix algum compos etern músic coraçã levi pass paul viol araúj viann osvald aranh opin produt plate alt later compr kg plate alt centr compr kg plate later compr kg plate centr compr kg plate gold compr kg aliment auditóri araúj viann meiaentr estudantil cie espetácul vál determin descont jov pertenc famíl rend jov defici acompanh necess prest continu assist defici emit institut segur ins sóci club assin zh vers lindo cobranç vers gal chav planet surf iguatem wallig ipirang wwwsymplacombr wwwopiniaocombr wwwfacebookcomopiniaoprodu wwwtwittercomopinia araúj viann\", 9691], [\"bonni tyl araúj viann confirm aí comemor carr tour histór pass cidad reviv sucess bonni tyl únic imperd bonni tyl sextaf araúj viann osvald aranh morphin coproduç fg music plate alt later compr kg plate alt centr compr kg plate later compr kg plate centr compr kg plate gold compr kg aliment auditóri araúj viann meiaentr estudantil cie espetácul vál determin descont jov pertenc famíl rend jov defici acompanh necess prest continu assist defici emit institut segur ins vers lindo cobranç vers gal chav planet surf iguatem wallig ipirang httpsbiletosymplacombrevent wwwopiniaocombr wwwfacebookcomopiniaoprodu wwwtwittercomopinia araúj viann\", 9697], [\"enald authentic gam araúj viann youtub enald authentic gam junt auditóri araúj viann enald authentic gam araúj viann osvald aranh opin produt plate alt later compr kg plate alt centr compr kg plate later compr kg plate centr compr kg plate gold compr kg plate alt later compr kg plate alt centr compr kg plate later compr kg plate centr compr kg plate gold compr kg aliment auditóri araúj viann meiaentr estudantil cie espetácul vál determin vers lindo cobranç vers gal chav planet surf iguatem wallig ipirang wwwsymplacombraraujoviann wwwaraujoviannaoficialcombr wwwfacebookcomaraujoviannaofic wwwtwittercomaraujoviann araúj viann\", 9698]]"
# predictModel = EventSimilar()
# s = predictModel.get_similarity("0", base)
