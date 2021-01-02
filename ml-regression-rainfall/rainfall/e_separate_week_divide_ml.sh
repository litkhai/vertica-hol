#!/bin/bash

echo "--Create Schema for Weekly Gap Filling" > temp_weekly_ml.sql

while read -r line;
do
cat <<EOD >> temp_weekly_ml.sql

--
CREATE TABLE rainfall_ml.whole_week$line AS SELECT * FROM rainfall.weekly_data WHERE week_no=$line;
CREATE TABLE rainfall_ml.training_week$line AS SELECT * FROM rainfall_ml.whole_week$line TABLESAMPLE(70);
UPDATE rainfall_ml.whole_week$line SET valid = 0 WHERE year IN (SELECT year FROM rainfall_ml.training_week$line);
CREATE TABLE rainfall_ml.predict_week$line AS SELECT * FROM rainfall_ml.whole_week$line WHERE valid=1;

--SELECT NORMALIZE('norm_model_ml_days_rained_week$line', 'rainfall_ml.training_week$line','*', 'zscore');
--SELECT NORMALIZE('norm_model_ml_days_rained_week$line', 'rainfall_ml.training_week$line','*', 'zscore');

--SELECT NORMALIZE('norm_model_ml_total_amount_week$line', 'rainfall_ml.training_week$line','*', 'minmax');
--SELECT NORMALIZE('norm_model_ml_total_amount_week$line', 'rainfall_ml.training_week$line','*', 'minmax');

--SELECT linear_Reg('model_ml_days_rained_week$line', 'norm_model_ml_days_rained_week$line','days_rained','year');
--SELECT linear_Reg('model_ml_total_amount_week$line', 'model_ml_total_amount_week$line','total_amount','year');
SELECT linear_Reg('model_ml_total_amount_week$line', 'rainfall_ml.training_week$line','total_amount','year');
SELECT linear_Reg('model_ml_days_rained_week$line', 'rainfall_ml.training_week$line','days_rained','year');

--DROP VIEW norm_model_ml_days_rained_week$line;
--DROP VIEW norm_model_ml_total_amount_week$line;

--SELECT linear_Reg('model_ml_days_rained_week$line', 'rainfall_ml.training_week$line','days_rained','year');
--SELECT linear_Reg('model_ml_total_amount_week$line', 'rainfall_ml.training_week$line','total_amount','year');

EOD
done < datalist_weekly.txt
