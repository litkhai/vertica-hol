#!/bin/bash
#!/bin/bash

echo "--Create Schema for Weekly Gap Filling" > temp_daily_gap.sql

while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"
cat <<EOD >> temp_daily_gap.sql

-- Work for Week Number $week and DOW $dow - Create training set from existing data set and build model, then fill the gap based on linear prediction
CREATE TABLE rainfall_gap.training_$pstfix AS SELECT * FROM rainfall.daily_data WHERE week_no=$week and dow=$dow and valid=1;
CREATE TABLE rainfall_gap.predict_$pstfix AS SELECT * FROM rainfall.daily_data WHERE week_no=$week and dow=$dow and valid=0;
ALTER TABLE rainfall_gap.predict_$pstfix ADD COLUMN rained_predict numeric(3,2);
ALTER TABLE rainfall_gap.predict_$pstfix ADD COLUMN amount_predict numeric(7,2);
-- Learn models
SELECT linear_Reg('model_rained_$pstfix', 'rainfall_gap.training_$pstfix','rained','year');
SELECT linear_Reg('model_amount_$pstfix', 'rainfall_gap.training_$pstfix','amount','year');
UPDATE rainfall_gap.predict_$pstfix SET rained_predict= PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_rained_$pstfix'), amount_predict=PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_amount_$pstfix');
DROP MODEL model_rained_$pstfix;
DROP MODEL model_amount_$pstfix;
EOD
done < gaplist_daily.txt
