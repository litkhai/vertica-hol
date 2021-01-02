--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-04

\! sh d_merge_gap_data.sh
\i temp_merge_data_set.sql


\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] The gap-filled daily table created as rainfall_ml.daily_data

-- Create Weekly Aggregated Data
CREATE TABLE rainfall_ml.weekly_data (year numeric(4), week_no numeric(2), days_rained numeric(1), days_total numeric(1), total_amount numeric(7,2), valid numeric(1));

INSERT INTO rainfall_ml.weekly_data (year, week_no, days_rained, total_amount)
  SELECT year, week_no, sum(rained), sum(amount) FROM rainfall_ml.daily_data GROUP BY 1, 2;

-- Update total days
UPDATE rainfall_ml.weekly_data AS rd SET days_total = crw.count, valid = 1
FROM (SELECT rw.year, rw.week_no, count(rw.dow) AS count from rainfall_ml.daily_data AS rw GROUP BY rw.year, rw.week_no) AS crw
WHERE rd.year = crw.year and rd.week_no = crw.week_no;

COMMIT;
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] The gap-filled weekly table created as rainfall_ml.weekly_data
