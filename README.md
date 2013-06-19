Bird_Identification
===================

scripts and functions for ICML 2013 Bird Challenge 


Birds2_train_delta:  Performs data segmentation and subsequently train the feature extraction using the MFCC and Delta MFCC coefficients. 
  	Once extracted features expands consecutive sampling variables. Projection is performed with LDA and save the data.

Birds2_test_delta: Very similar to the previous segmentation by changing the test data and using the screening test saved.

Classify_test: Train and test the neural network predictions and removed for those birds with poorer AUC in training (set to 0). 
		For each clip predictions combining all samples belonging to said clip. Since there are quite random component to train the 
		model results have kept preprocessed and train the neural network that generated the best prediction.


NeuralNetworkbagging_Validation.m: auxiliary function for testing the performance and see the influence of diversity in initialization and in the training set.

Birds_Recog_Final.csv: File with the submission with better results in the final prediction AUC.
