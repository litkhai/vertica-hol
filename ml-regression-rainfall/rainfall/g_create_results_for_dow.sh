#!/bin/bash

mkdir -p output/dow
echo "--Create results" > temp_create_output.sql

while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"
cat <<EOD >> temp_create_output.sql

\o result_$pstfix.txt
select date, week_no, dow, rained as rained_fact, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_rained_$pstfix') as rained_predict
, amount as amount_fact, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_amount_$pstfix') as amount_predict
FROM rainfall_ml.predict_$pstfix;
SELECT GET_MODEL_SUMMARY(USING PARAMETERS model_name='model_ml_rained_$pstfix');
SELECT GET_MODEL_SUMMARY(USING PARAMETERS model_name='model_ml_amount_$pstfix');
\o
EOD
done < datalist_daily.txt

echo "\! mv result*txt ./output/dow/" >> temp_create_output.sql

