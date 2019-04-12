import sys
import pandas as pd
import numpy as np
import json


from flask import Flask
from flask_restful import reqparse, abort, Api, Resource
from personaprediction import PersonaPrediction
from eventprediction import EventPrediction
from eventcategoryprediction import EventCategoryPrediction

app = Flask(__name__)
api = Api(app)


parser = reqparse.RequestParser()
parser.add_argument('query')

class PredictPersona(Resource):
    def get(self):
        args = parser.parse_args()
        user_query = args['query']

        prediction = PersonaPrediction.predict(self, query=user_query)
        output = np.array(prediction).tolist()

        return {'personas' :
                    {
                        'primary' : output[0],
                        'secondary' : output[1]
                    }
               }

class PredictEvent(Resource):
    def get(self):
        args = parser.parse_args()
        user_query = args['query']
        print(user_query)

        predictPersonaModel = EventPrediction()
        predictCategoryModel = EventCategoryPrediction()

        persona_prediction = predictPersonaModel.predict(user_query)
        category_prediction = predictCategoryModel.predict(user_query)

        persona_output = np.array(persona_prediction).tolist()
        category_output = np.array(category_prediction).tolist()

        print(persona_output)
        print(category_output)

        return {
                'classification' : {
                    'personas':
                        {
                            'primary' : {
                                'name': persona_output[0][0],
                                'score': persona_output[0][1]
                            },
                            'secondary' : {
                                'name': persona_output[1][0],
                                'score': persona_output[1][1]
                            }
                        },
                    'categories':
                        {
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
