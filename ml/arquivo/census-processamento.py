#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan  9 23:48:12 2019

@author: jon
"""

import pandas as pd

base = pd.read_csv('census.csv')

previsores = base.iloc[:, 0:14].values
classe = base.iloc[:, 14].values




from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoder_previsores = LabelEncoder()
#labels = labelencoder_previsores.fit_transform(previsores[:, 1])

previsores[:,1] = labelencoder_previsores.fit_transform(previsores[:, 1])
previsores[:,3] = labelencoder_previsores.fit_transform(previsores[:, 3])
previsores[:,5] = labelencoder_previsores.fit_transform(previsores[:, 5])
previsores[:,6] = labelencoder_previsores.fit_transform(previsores[:, 6])
previsores[:,7] = labelencoder_previsores.fit_transform(previsores[:, 7])
previsores[:,8] = labelencoder_previsores.fit_transform(previsores[:, 8])
previsores[:,9] = labelencoder_previsores.fit_transform(previsores[:, 9])
previsores[:,13] = labelencoder_previsores.fit_transform(previsores[:, 13])


from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores[:, 0] = scaler.fit_transform(previsores[:, 0].reshape(1, -1))
previsores[:, 2] = scaler.fit_transform(previsores[:, 2].reshape(1, -1))
previsores[:, 4] = scaler.fit_transform(previsores[:, 4].reshape(1, -1))
previsores[:, 10] = scaler.fit_transform(previsores[:, 10].reshape(1, -1))
previsores[:, 11] = scaler.fit_transform(previsores[:, 11].reshape(1, -1))
previsores[:, 12] = scaler.fit_transform(previsores[:, 12].reshape(1, -1))


onehotencoder = OneHotEncoder(categorical_features=[1,3,5,6,7,8,9,13])
previsores = onehotencoder.fit_transform(previsores).toarray()

labelencoder_classe = LabelEncoder()
classe = labelencoder_classe.fit_transform(classe)


from sklearn.model_selection import train_test_split
previsores_treinamento, previsores_teste, classe_treinamento, classe_teste = train_test_split(previsores, classe, test_size=0.15, random_state=0)


from sklearn.naive_bayes import GaussianNB
classificador = GaussianNB()
classificador.fit(previsores_treinamento , classe_treinamento)
previsoes = classificador.predict(previsores_teste)


from sklearn.metrics import confusion_matrix, accuracy_score
precisao = accuracy_score(classe_teste, previsoes)

matrix = confusion_matrix(classe_teste, previsoes)


























