#!/bin/bash

echo "Put the date you want to forecast of rainfall:"
read -p 'Year: ' year
read -p 'Month: ' month
read -p 'Day: ' day
pdate=$year
pdate+="-"
pdate+=$month
pdate+="-"
pdate+=$day
pdfilen="predict_rainfall_"
pdfilen+=$pdate
pdfilen+=".out"

cat <<EOD > temp_create_dateconvert.sql
\a
\t
\o dateconvert.out
SELECT week(to_date(($year::int * 10000 + $month::int * 100 + $day::int)::varchar,'YYYYMMDD')),
  dayofweek(to_date(($year::int * 10000 + $month::int * 100 + $day::int)::varchar,'YYYYMMDD'));
\o
\t
CREATE TABLE rainfall_ml.tmp (year numeric(4), month numeric(2), day numeric(2), week numeric(2), dow numeric(2));
INSERT INTO rainfall_ml.tmp VALUES ($year, $month, $day, week(to_date(($year::int * 10000 + $month::int * 100 + $day::int)::varchar,'YYYYMMDD')), dayofweek(to_date(($year::int * 10000 + $month::int * 100 + $day::int)::varchar,'YYYYMMDD')));
COMMIT;
\a
EOD

cat temp_create_dateconvert.sql | vsql -U dbadmin -w password

OLDIFS=$IFS
IFS='|' read -r week dow < dateconvert.out
IFS=$OLDIFS

pstfix="week$week"
pstfix+="dow$dow"

rm temp_create_dateconvert.sql
rm dateconvert.out

cat <<EOD > temp_rainfall_predict.sql
\o predict.out
SELECT to_date(($year::int * 10000 + $month::int * 100 + $day::int)::varchar,'YYYYMMDD') AS Predicting_date
, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_rained_$pstfix') as rained_predict_by_dow_pattern
, DECODE( SIGN($week -1), 0, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/$week,
            DECODE(SIGN($week -52), 1, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/$dow
            , PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/7)) as rained_predict_by_week_pattern
, (PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_rained_$pstfix') +
  (DECODE( SIGN($week -1), 0, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/$week,
            DECODE(SIGN($week -52), 1, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/$dow
            , PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_days_rained_week$week')/7))))/2  as mean_of_predictions_of_raining
, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_amount_$pstfix') as amount_predict_by_dow_pattern
, DECODE( SIGN($week -1), 0, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/$week,
            DECODE(SIGN($week -52), 1, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/$dow
            , PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/7)) as amount_predict_by_week_pattern
, (PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_amount_$pstfix') +
  (DECODE( SIGN($week -1), 0, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/$week,
            DECODE(SIGN($week -52), 1, PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/$dow
            , PREDICT_LINEAR_REG(year USING PARAMETERS model_name='model_ml_total_amount_week$week')/7))))/2 as mean_of_predictions_of_amount
FROM rainfall_ml.tmp where year=$year;
\o
DROP TABLE rainfall_ml.tmp;
EOD

cat temp_rainfall_predict.sql | vsql -U dbadmin -w password
cat predict.out
mv predict.out predict/$pdfilen

