import sys
import pandas as pd
import numpy as np
import json
import logging
import base64


from datetime import datetime
from flask import Flask
from event_content_rules import EventContentRulesPrediction
from user_persona import UserPersonaPrediction
from event_persona import EventPersonaPrediction
from event_category import EventCategoryPrediction
from event_price import EventPricePrediction
from event_features import EventFeatures
from event_similar import EventSimilar
from flask_restful import reqparse, abort, Api, Resource
from flask_cors import CORS

logging.basicConfig(filename='log/error.log',level=logging.DEBUG)

app = Flask(__name__)
cors = CORS(app, resources={r"/*": {"origins": "*"}})

api = Api(app)



parser = reqparse.RequestParser()
parser.add_argument('query')
parser.add_argument('text')
parser.add_argument('base')

class UserPersonaRoute(Resource):
    def get(self):
        args = parser.parse_args()
        user_query = args['query']

        prediction = UserPersonaPrediction.predict(self, user_query)
        persona_output = np.array(prediction).tolist()

        return {
            'classification': {
                'personas': {
                    'primary' : {
                        'name': persona_output[0][0],
                        'score': persona_output[0][1]
                    },
                    'secondary' : {
                        'name': persona_output[1][0],
                        'score': persona_output[1][1]
                    },
                    'tertiary' : {
                        'name': persona_output[2][0],
                        'score': persona_output[2][1]
                    },
                    'quartenary' : {
                        'name': persona_output[3][0],
                        'score': persona_output[3][1]
                    },
                    'assortment' : {
                        'finished': 'true',
                        'finished_at' : datetime.strftime(datetime.today(), '%Y-%m-%d %H:%M:%S')
                    }
                }
            }
        }

class EventLabelRoute(Resource):
    def post(self):
        args = parser.parse_args()
        user_query = args['query']

        predictEventContentRulesModel = EventContentRulesPrediction()
        predictPersonaModel = EventPersonaPrediction()
        predictCategoryModel = EventCategoryPrediction()
        predictPriceModel = EventPricePrediction()

        content_rules_prediction = predictEventContentRulesModel.predict(user_query)
        persona_prediction = predictPersonaModel.predict(user_query)
        category_prediction = predictCategoryModel.predict(user_query)
        price_prediction = predictPriceModel.predict(user_query)

        content_rules_output = np.array(content_rules_prediction).tolist()
        persona_output = np.array(persona_prediction).tolist()
        category_output = np.array(category_prediction).tolist()
        price_output = np.array(price_prediction).tolist()

        return {
                'classification' : {
                    'content_rules': [
                        {
                            'model_version': datetime.strftime(datetime.today(), 'content-rules-%Y%m%d-%H%M%S'),
                            'result': [
                                        {
                                            'from_name': "content_rules",
                                            'to_name':   "description",
                                            'type':      "choices",
                                            'value':     {
                                                'choices': [content_rules_output[0][0].lower()]
                                            }
                                        }
                                        ],
                            'score': content_rules_output[0][1]
                        }
                    ],
                    'personas': {
                        'primary' : {
                            'name': persona_output[0][0],
                            'score': persona_output[0][1]
                        },
                        'secondary' : {
                            'name': persona_output[1][0],
                            'score': persona_output[1][1]
                        }
                    },
                    'categories': {
                        'primary' : {
                            'name': category_output[0][0],
                            'score': category_output[0][1]
                        },
                        'secondary' : {
                            'name': category_output[1][0],
                            'score': category_output[1][1]
                        }
                    },
                    'price': {
                        'name': price_output[1][0],
                        'score': price_output[1][1]
                    }
                }
            }


class EventFeaturesRoute(Resource):
    def post(self):
        args = parser.parse_args()
        query = args['query']

        eventFeatures = EventFeatures()
        features = eventFeatures.extract_features(query)

        return features



class EventSimilarRoute(Resource):
    def post(self):
        args = parser.parse_args()
        text = args['text']
        base = args['base']

        eventSimilar = EventSimilar()
        similar = eventSimilar.get_similarity(text, base)

        return similar



api.add_resource(EventFeaturesRoute, '/event/features')
api.add_resource(EventLabelRoute, '/event/label')
api.add_resource(EventSimilarRoute, '/event/similar')
api.add_resource(UserPersonaRoute, '/user/persona')


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
