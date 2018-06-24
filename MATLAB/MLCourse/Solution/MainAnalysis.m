%% Classify Robot Execution Failures
% Robot Execution dataset contains force and torque measurements on a robot
% after failure detection. Each failure is characterized by 15 force/torque
% samples collected at regular time intervals starting immediately after
% failure detection. The total observation window for each failure instance
% was of 315 ms. All features are numeric and represent a force or a torque
% measured after failure detection.  The dataset used in the following
% workbook is a modified version where the average of the 15 samples is
% used to represent each failure. The goal of this analysis is to build a
% model to automatically identify the failure type given the sensor
% measurements.
%
% The data is stored in an excel file, as follows:
% Fx Fy Fz Tx Ty Tz Fault 
%
% The original dataset is courtesy of:
% Luis Seabra Lopes and Luis M. Camarinha-Matos
% Universidade Nova de Lisboa, 
% Monte da Caparica, Portugal
% Date Donated: April 23, 1999
%
% Copyright 2015 The MathWorks, Inc.


%% Import Existing Data
% In this example, the data is imported from an Excel File. We can make use
% of the interactive Import Tool to import the data and auto-generate the
% code for the purpose of automation. The table data type allows us to
% collect mixed-type data and metadata properties (such as variable names,
% row names, descriptions, and variable units) in a single container.
% Tables are suitable for column-oriented or tabular data that is often
% stored as columns in a text file or in a spreadsheet. Since our dataset
% contains experimental data with rows representing different observations
% and columns representing different measured variables, tables are a
% suitable choice.

% Auto-generated code for importing data
faultData = importFaultData('faultData.xlsx');


%% Convert Categorical Data into Categorical Arrays
% Categorical data contains discrete pieces of information, such as the
% different classes of faults in this dataset. A categorical array provides
% efficient storage and convenient manipulation of nonnumeric data while
% also maintaining meaningful names for the values. We can open a variable
% in the Variable Editor and convert categorical attributes into
% categorical arrays interactively. MATLAB will echo the code necessary
% to accomplish these interactive tasks in the Command Window.

% Convert categorical variables into categorical arrays
faultData.Fault = categorical(faultData.Fault);


%% Visualize Data
% By simply visualizing our data, we begin to get insights into our dataset.
% For example, we can see that the forces in Z direction are largely
% responsible in determining the Obstruction fault class.

% We can open the variable |faultData| in the Variable Editor and
% interactively create various types of plots by selecting one or more
% columns. As we create the plots, MATLAB echoes the corresponding commands
% in the Command Window.

% Display a pie chart to illustrate numerical distribution of faults
pie(faultData.Fault)

% Fz vs Tz plot, differentiated by Fault Class
figure
gscatter(faultData.Fz,faultData.Tz,faultData.Fault)
xlabel('Fz')
ylabel('Tz')
title('Outcome')

% Visualize data using a box plot
figure
boxplot(faultData.Fz,faultData.Fault)
xlabel('Fault')
ylabel('Fz')
title('Fz per fault class')


%% Summary of our dataset 
% We can gain some quick insights into the our data by using the |summary|
% command.
% The summary contains the following information on the variables:
%
%    Name (Size and Data Type)
%    Units (if any)
%    Description (if any)
%    Values
%        numeric variables     — minimum, median, and maximum values
%        logical variables     — number of values that are true and false
%        categorical variables — number of elements from each category

summary(faultData)


%% Filter Data
% From the summary results, notice that the 'lost' category of faults are
% only represented by three samples. In machine learning, data is key. Our
% model is only as good as the data we feed it. Since we do not have enough
% data to represent the 'lost' category, we will remove it from our dataset
% to increase the accuracy of our model.

% Remove 'lost' category
faultData(faultData.Fault == 'lost',:) = [];
faultData.Fault = removecats(faultData.Fault);


%% Apply Machine Learning Techniques 
% Statistics and Machine Learning Toolbox features a number of supervised
% and unsupervised machine learning techniques. It supports both
% classification and regression algorithms. The supervised learning
% techniques range from non-linear regression, generalized linear
% regression, discriminant analysis, SVMs to decision trees and ensemble
% methods.
% 
% Observe that once the data has been prepared, the syntax to utilize the
% different modeling techniques is very similar and most of these
% techniques can handle categorical predictors directly. The user can
% conveniently supply information about different parameters associated
% with the different algorithms.
% 
% All of the classification techniques can be explored interactively using
% our new Classification Learner App. Once we decide on an algorithm, the
% App can generate code for the desired technique.
% 
% For example, below we used the App to generate code for a Medium tree.

% Train and view classifier
[trainedClassifier, validationAccuracy, validationPredictions, validationScores]= trainClassifierMediumTree(faultData);
view(trainedClassifier.ClassificationTree, 'Mode', 'graph')


%% Predict responses for new data 
% After we create classification models interactively in the Classification
% Learner App, we can export our best model to the workspace. We can then 
% use the trained model to make predictions using new data.

% Predict a response using completely new data
PredictedResponse = trainedClassifier.predictFcn(faultData(18:20,:))






