# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import pandas as pd
from sklearn.tree import DecisionTreeClassifier # Import Decision Tree Classifier
from sklearn.model_selection import train_test_split # Import train_test_split function
from sklearn import metrics #Import scikit-learn metrics module for accuracy calculation
import sklearn.datasets as datasets
from sklearn.linear_model import LogisticRegression
from sklearn.tree import plot_tree
import matplotlib.pyplot as plt
# import databázy
ads= pd.read_csv("C:/Users/dizej/Downloads/archive (5)/advertising.csv")

#Oboznámenie sa s databázou
print(ads.head(10))
print(ads.info())
print(ads[["Daily Time Spent on Site", "Age"]].describe())
print(ads[["Area Income", "Daily Internet Usage"]].describe())

# Kontrola missing values
print(ads.isnull().sum())

# Odstránenie nepotrebných stĺpcov pre analýzu

ads=ads.drop(columns=['Ad Topic Line', 'City', 'Country','Timestamp'])    


#Logistická regresia
#Rozdelenie atributov a určenie tagertovej premennej
features=['Daily Time Spent on Site', 'Age', 'Area Income',
       'Daily Internet Usage','Male']
X=ads[features]
y=ads["Clicked on Ad"]

#rozdelenie na trenovaciu a testovaciu množinu
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=16)

#Model a predikcia
logreg = LogisticRegression(random_state=16)
logreg.fit(X_train, y_train)

y_pred = logreg.predict(X_test)

#Presnosť modelu (86% bolo správne zaradených)
print("Accuracy:",metrics.accuracy_score(y_test, y_pred))


#Confusion matrix
cnf_matrix = metrics.confusion_matrix(y_test, y_pred)
print(cnf_matrix)


#ROC krivka(pozrieš si ju v záložke Plots) - celý tento kod spusti dokopy, inak neukaze hodnotu AUC

y_pred_proba = logreg.predict_proba(X_test)[::,1]
fpr, tpr, _ = metrics.roc_curve(y_test,  y_pred_proba)
auc = metrics.roc_auc_score(y_test, y_pred_proba)
plt.plot(fpr,tpr,label="AUC="+str(auc))
plt.legend(loc=4)
plt.show()




# Rozhodovací strom
#Definovanie premmených 
features=['Daily Time Spent on Site', 'Age', 'Area Income',
       'Daily Internet Usage','Male']
X=ads[features]
y=ads["Clicked on Ad"]

#rozdelenie na testovacie a trenovaciu množinu
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=16)

#model
clf = DecisionTreeClassifier(max_depth=3)
clf = clf.fit(X_train,y_train)
y_pred = clf.predict(X_test)
#presnosť modelu (94%) - lepší ako logistická regresia
print("Accuracy:",metrics.accuracy_score(y_test, y_pred))

#confusion matrix
cnf_matrix = metrics.confusion_matrix(y_test, y_pred)
print(cnf_matrix)

#ROC krivka(pozrieš si ju v záložke Plots)  celý tento kod spusti dokopy, inak neukaze hodnotu AUC

y_pred_proba = clf.predict_proba(X_test)[::,1]
fpr, tpr, _ = metrics.roc_curve(y_test,  y_pred_proba)
auc = metrics.roc_auc_score(y_test, y_pred_proba)
plt.plot(fpr,tpr,label="AUC="+str(auc))
plt.legend(loc=4)
plt.show()



#Zobrazenie stromu( tiež v založke plots)
plt.figure(figsize=(25,10))
a = plot_tree(clf, 
              feature_names=features,
              class_names=['0','1'], 
              filled=True, 
              rounded=True, 
              fontsize=14)


