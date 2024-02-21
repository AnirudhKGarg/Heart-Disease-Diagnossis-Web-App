# Heart Disease Diagnossis Web App
 
This is a web app that makes a logistic regression model and uses it to predict a person's risk for heart disease.

This is the link: https://9uqjcw-anirudh-garg.shinyapps.io/Heart-Disease-Prediction/

# Disclaimer 

Warning, this is not medical advice. It is a simple model made by a data scientist, not a doctor. Ask your doctor regarding your risks as they vary person to person. 

# Data
This data set dates from 1988 and consists of four databases: Cleveland, Hungary, Switzerland, and Long Beach V. It contains 76 attributes, including the predicted attribute, but all published experiments refer to using a subset of 14 of them. The "target" field refers to the presence of heart disease in the patient. It is integer valued 0 = no disease and 1 = disease.
link: https://archive.ics.uci.edu/ml/datasets/heart+disease

# Model

Call:  glm(formula = Heart.Disease ~ Age + Cholesterol + BP + Max.HR + 
    ST.depression + Sex, family = binomial, data = train, contrasts = list(Sex = contr.treatment))

Coefficients:
  (Intercept)            Age    Cholesterol             BP         Max.HR  ST.depression           Sex2  
     -3.68071        0.01229        0.01310        0.03629       -0.05113        0.62952        2.25974  

Degrees of Freedom: 188 Total (i.e. Null);  182 Residual
Null Deviance:	    258.7 
Residual Deviance: 155.1 	AIC: 169.1

This can be interpreted as a baseline risk of 2.5% with an increase of 1.2% for every 1 year increase in age, 1.3% for every 1 mg/L of increase in cholesterol, 3.6% for every 1 point increase in blood pressure, -5.1% every 1 point increase in max heart rate, and a 62% for a 1 point absolute increase in stent depression. Men are 9.6x more likely to be at risk (ceteris paribus) compared to women.
