#!/bin/bash

mkdir -p output/week

while read -r line;
do
cat <<EOD >> temp_create_output.sql

\o result_week$line.txt
SELECT year, week_no, days_total, days_rained as days_rained_fact,
PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$line') as days_rained_predict,
total_amount as total_amount_fact, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$line') as total_amount_predict
FROM rainfall_ml.predict_week$line;
SELECT GET_MODEL_SUMMARY(USING PARAMETERS model_name='model_ml_days_rained_week$line');
SELECT GET_MODEL_SUMMARY(USING PARAMETERS model_name='model_ml_total_amount_week$line');
\o
EOD
done < datalist_weekly.txt

echo "\! mv result*txt ./output/week/" >> temp_create_output.sql
