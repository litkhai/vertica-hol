#!/bin/bash

echo "--Calculate and Fill Gaps" > temp_calculate_and_fill_gap.sql

while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r year week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"
cat <<EOD >> temp_calculate_and_fill_gap.sql

ALTER TABLE rainfall_gap.predict_$pstfix ADD COLUMN rained_predict_from_week_predict numeric(3,2);
ALTER TABLE rainfall_gap.predict_$pstfix ADD COLUMN amount_predict_from_week_predict numeric(7,2);
EOD
done < gaplist_whole.txt


while read -r line;
do
OLDIFS=$IFS
IFS='|' read -r year week dow <<< $line
IFS=$OLDIFS
pstfix="week$week"
pstfix+="dow$dow"
cat <<EOD >> temp_calculate_and_fill_gap.sql

UPDATE rainfall_gap.predict_$pstfix AS fp SET
rained_predict_from_week_predict = ((ppw.days_rained_predict - ppw.days_rained) / (ppw.days_total - ppw.days_valid))
, amount_predict_from_week_predict = DECODE(sign(ppw.total_amount_predict - ppw.total_amount), 0, 0, -1, 0, ((ppw.total_amount_predict - ppw.total_amount) / (ppw.days_total - ppw.days_valid)))
FROM (SELECT pw.year as year, pw.week_no as week_no, pw.days_total as days_total, pw.days_rained_predict as days_rained_predict, pw.days_rained as days_rained, pw.days_valid as days_valid, pw.total_amount_predict as total_amount_predict, pw.total_amount as total_amount FROM rainfall_gap.predict_week$week AS pw WHERE year = $year and week_no = $week ) AS ppw
WHERE fp.year = $year and fp.week_no = $week and fp.dow = $dow;

UPDATE rainfall_gap.predict_$pstfix AS fp SET
rained = DECODE(SIGN((rained_predict + rained_predict_from_week_predict)/2-1), -1, 0, 1)
, amount = DECODE(SIGN((rained_predict + rained_predict_from_week_predict)/2-1), -1, 0, (amount_predict_from_week_predict + amount_predict))
WHERE year = $year and week_no = $week and dow = $dow;
EOD
done < gaplist_whole.txt

echo "COMMIT;" >> temp_calculate_and_fill_gap.sql

