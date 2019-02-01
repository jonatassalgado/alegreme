import sys
sys.path.insert(0, '../alegreme/ml')
import pandas as pd
import numpy as np
import json


from flask import Flask
from flask_restful import reqparse, abort, Api, Resource
from personaprediction import PersonaPrediction

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


api.add_resource(PredictPersona, '/')


if __name__ == '__main__':
    app.run(debug=True)
