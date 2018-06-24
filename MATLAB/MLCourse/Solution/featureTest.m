function criterion = featureTest(Xtrain, Ytrain, Xtest, Ytest)

     t = ClassificationTree.fit(Xtrain,Ytrain);
     Y_t = t.predict(Xtest);
     Cmat = confusionmat(Ytest,Y_t);
     
     % Confusion matrix in percentage/100
      Cmat = bsxfun(@rdivide,Cmat,sum(Cmat,2));

     % Misclassification rate for each class
       misclassification = 1 - diag(Cmat);

       criterion = sum(misclassification);
       %criterion = Cmat(1,2)/sum(Cmat(:,2));

end

