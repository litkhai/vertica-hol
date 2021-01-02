#!/bin/bash

echo "--Create Schema for Weekly Gap Filling" > temp_weekly_gap.sql
echo "CREATE SCHEMA rainfall_gap;" >> temp_weekly_gap.sql

while read -r line;
do
cat <<EOD >> temp_weekly_gap.sql

-- Work for Week Number $line - Create training set from existing data set and build model, then fill the gap based on linear prediction
CREATE TABLE rainfall_gap.training_week$line AS SELECT * FROM rainfall.weekly_data WHERE week_no=$line and valid=1;
CREATE TABLE rainfall_gap.predict_week$line AS SELECT * FROM rainfall.weekly_data WHERE week_no=$line and valid=0;
ALTER TABLE rainfall_gap.predict_week$line ADD COLUMN days_rained_predict numeric(3,2);
ALTER TABLE rainfall_gap.predict_week$line ADD COLUMN total_amount_predict numeric(7,2);
SELECT linear_Reg('model_days_rained_week$line', 'rainfall_gap.training_week$line','days_rained','year');
SELECT linear_Reg('model_total_amount_week$line', 'rainfall_gap.training_week$line','total_amount','year');
UPDATE rainfall_gap.predict_week$line SET days_rained_predict= PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_days_rained_week$line'), total_amount_predict=PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_total_amount_week$line');
DROP MODEL model_days_rained_week$line;
DROP MODEL model_total_amount_week$line;
EOD
done < gaplist_weekly.txt



