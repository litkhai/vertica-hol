#!/bin/bash

echo "--Merge filled Gaps to the init dataset " > temp_merge_data_set.sql
echo "CREATE SCHEMA rainfall_ml;" >> temp_merge_data_set.sql
echo "CREATE TABLE rainfall_ml.daily_data AS SELECT * FROM rainfall.daily_data;" >> temp_merge_data_set.sql

while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r year week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"

cat <<EOD >> temp_merge_data_set.sql

UPDATE rainfall_ml.daily_data AS ld SET rained = pdq.rained, amount = pdq.amount, valid=1
FROM (SELECT pd.year as year, pd.week_no as week_no, pd.dow as dow, pd.rained as rained, pd.amount as amount FROM rainfall_gap.predict_$pstfix AS pd WHERE year = $year and week_no = $week ) AS pdq
WHERE ld.year = $year and ld.week_no = $week and ld.dow = $dow and valid=0;

EOD
done < gaplist_whole.txt

echo "COMMIT;" >> temp_merge_data_set.sql



