# Cancer detection data pipeline
# author: Rahul Kuriyedath
# date: 2020-12-04

all: results/prediction_table.csv figures/class_imbalance_check.png figures/pairplot.png src/EDA.html

# download data
data/raw/raw_data.csv: src/download_data.py
	python src/download_data.py --url='https://archive.ics.uci.edu/ml/machine-learning-databases/00451/dataR2.csv' --out_file='data/raw/raw_data.csv'

# split data into train and test splits
data/raw/train.csv data/raw/test.csv: src/split_train_test.py data/raw/raw_data.csv
	python src/split_train_test.py --in_train_file="data/raw/raw_data.csv" --train_out="data/raw/train.csv" --test_out="data/raw/test.csv"

# exploratory data analysis - visualize predictor distributions across classes
figures/class_imbalance_check.png figures/pairplot.png: src/generate_figs.py data/raw/train.csv
	python src/generate_figs.py --in_train_file="data/raw/train.csv" --figure_1='figures/class_imbalance_check.png' --figure_2='figures/pairplot.png'

# tune model (**Include details regarding type of model**)
results/classifiers_cv_scores.csv results/random_search_results.csv results/trained_model.sav: src/fit_cancer_prediction.py data/raw/train.csv
	python src/fit_cancer_prediction.py --in_train_file='data/raw/train.csv' --out_file='results/classifiers_cv_scores.csv' --out_file2='results/random_search_results.csv' --model='results/trained_model.sav'

# test model on unseen data
results/prediction_table.csv: src/test_cancer_prediction.py data/raw/test.csv results/trained_model.sav
	python src/test_cancer_prediction.py --in_test_file='data/raw/test.csv' --model='results/trained_model.sav' --out_file='results/prediction_table.csv'

# render report
src/EDA.html: src/EDA.ipynb
	jupyter nbconvert --to html src/EDA.ipynb

clean: 
	rm -rf data
	rm -rf results
	rm -rf doc
	rm -rf figures