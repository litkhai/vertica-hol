#!/bin/bash

echo "--Create Schema for Prediction" > temp_daily_ml.sql

while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"
cat <<EOD >> temp_daily_ml.sql

-- Work for Week Number $week and DOW $dow
CREATE TABLE rainfall_ml.whole_$pstfix AS SELECT * FROM rainfall.daily_data WHERE week_no=$week and dow=$dow;
CREATE TABLE rainfall_ml.training_$pstfix AS SELECT * FROM rainfall_ml.whole_$pstfix TABLESAMPLE(70);
UPDATE rainfall_ml.whole_$pstfix SET valid = 0 WHERE year IN (SELECT year FROM rainfall_ml.training_$pstfix);

CREATE TABLE rainfall_ml.predict_$pstfix AS SELECT * FROM rainfall_ml.whole_$pstfix WHERE valid=1;

--SELECT NORMALIZE('norm_model_ml_rained_$pstfix', 'rainfall_ml.training_$pstfix','*', 'zscore' USING PARAMETERS exclude_columns= 'date');
--SELECT NORMALIZE('norm_model_ml_rained_$pstfix', 'rainfall_ml.training_$pstfix','*', 'zscore' USING PARAMETERS exclude_columns= 'date');
--SELECT NORMALIZE('norm_model_ml_amount_$pstfix', 'rainfall_ml.training_$pstfix','*', 'minmax' USING PARAMETERS exclude_columns= 'date');
--SELECT NORMALIZE('norm_model_ml_amount_$pstfix', 'rainfall_ml.training_$pstfix','*', 'minmax' USING PARAMETERS exclude_columns= 'date');


--SELECT linear_Reg('model_ml_rained_$pstfix', 'norm_model_ml_rained_$pstfix','rained','year');
----SELECT logistic_Reg('model_ml_rained_$pstfix', 'norm_model_ml_rained_$pstfix','rained','year');
--SELECT linear_Reg('model_ml_amount_$pstfix', 'norm_model_ml_amount_$pstfix','amount','year');

SELECT linear_Reg('model_ml_rained_$pstfix', 'rainfall_ml.training_$pstfix','rained','year');
----SELECT logistic_Reg('model_ml_rained_$pstfix', 'rainfall_ml.training_$pstfix','rained','year');
SELECT linear_Reg('model_ml_amount_$pstfix', 'rainfall_ml.training_$pstfix','amount','year');

--DROP VIEW norm_model_ml_rained_$pstfix;
--DROP VIEW norm_model_ml_amount_$pstfix;

--UPDATE rainfall_ml.predict_$pstfix SET rained_predict= PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_rained_$pstfix'), amount_predict=PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_amount_$pstfix');
--DROP MODEL model_ml_rained_$pstfix;
--DROP MODEL model_ml_amount_$pstfix;
EOD
done < datalist_daily.txt
