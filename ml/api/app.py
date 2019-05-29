import sys
import pandas as pd
import numpy as np
import json


from datetime import datetime
from flask import Flask
from eventpersonaprediction import EventPersonaPrediction
from eventcategoryprediction import EventCategoryPrediction
from flask_restful import reqparse, abort, Api, Resource

app = Flask(__name__)
api = Api(app)


parser = reqparse.RequestParser()
parser.add_argument('query')

class PredictPersona(Resource):
    def get(self):
        args = parser.parse_args()
        user_query = args['query']

        prediction = EventPersonaPrediction.predict(self, query=user_query)
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

class PredictEvent(Resource):
    def get(self):
        args = parser.parse_args()
        user_query = args['query']
        print(user_query)

        predictPersonaModel = EventPersonaPrediction()
        predictCategoryModel = EventCategoryPrediction()

        persona_prediction = predictPersonaModel.predict(user_query)
        category_prediction = predictCategoryModel.predict(user_query)

        persona_output = np.array(persona_prediction).tolist()
        category_output = np.array(category_prediction).tolist()

        return {
                'classification' : {
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
                    }
                }
            }


api.add_resource(PredictEvent, '/predict/event')
api.add_resource(PredictPersona, '/predict/persona')


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
