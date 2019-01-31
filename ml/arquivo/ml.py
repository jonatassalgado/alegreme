import pandas as pd

base = pd.read_csv('credit-data.csv')

# Descreve os dados
base.describe()

# Mostra a média de todos
base['age'].mean()

# Mostra a média somente dos valores maior que zero
base['age'][base.age > 0].mean()

# Atribui o valor médio as valores da coluna age
base.loc[base.age < 0, 'age'] = 40.92

# Retorna true ou false para os valores que estão vazio
base.loc[pd.isnull(base['age'])]

# Separa o dataframe em dois arrays com variáveis x e y
previsores = base.iloc[:, 1:4].values
classe = base.iloc[:, 4].values


# carrega o scikit learn
from sklearn.preprocessing import Imputer

# carrega módulo para remover valores vazios
imputer = Imputer(missing_values='NaN', strategy='mean', axis=0)
imputer = imputer.fit(previsores[:, 0:3])
previsores[:, 0:3] = imputer.transform(previsores[:, 0:3])

# Realizar escanolmento entre variáveis
from sklearn.preprocessing import StandardScaler 
scaler = StandardScaler()
previsores = scaler.fit_transform(previsores)


from sklearn.model_selection import train_test_split
previsores_treinamento, previsores_teste, classe_treinamento, classe_teste = train_test_split(previsores, classe, test_size=0.25, random_state=0)


from sklearn.naive_bayes import GaussianNB
classificador = GaussianNB()
classificador.fit(previsores_treinamento , classe_treinamento)
previsoes = classificador.predict(previsores_teste)


from sklearn.metrics import confusion_matrix, accuracy_score
precisao = accuracy_score(classe_teste, previsoes)

matrix = confusion_matrix(classe_teste, previsoes)





















