--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-02

\! echo [$(date +"%Y-%m-%d %T")][TASK] Create Daily and Weekly Tables to Use Analytic
CREATE TABLE rainfall.daily_data (date date, year numeric(4), month numeric(2), dom numeric(2), week_no numeric(2), dow numeric(1), rained numeric(1), amount numeric(7,2), valid numeric(1));

INSERT INTO rainfall.daily_data (date, year, month, dom, week_no, dow, rained, amount, valid)
  SELECT to_date((year::int * 10000 + month::int * 100 + day::int)::varchar,'YYYYMMDD'), year, month, day,
  week(to_date((year::int * 10000 + month::int * 100 + day::int)::varchar,'YYYYMMDD')),
  dayofweek(to_date((year::int * 10000 + month::int * 100 + day::int)::varchar,'YYYYMMDD')),
  decode(to_char(rainfall), '0.00', '0', NULL, NULL, '1')::int, rainfall, decode(to_char(rainfall),NULL, '0', '1')::int FROM rainfall.raw;

COMMIT;

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Daily table created as rainfall.daily_data

-- Create Weekly Aggregated Data
CREATE TABLE rainfall.weekly_data (year numeric(4), week_no numeric(2), days_rained numeric(1), days_total numeric(1), days_valid numeric(1), total_amount numeric(7,2), valid numeric(1));

INSERT INTO rainfall.weekly_data (year, week_no, days_rained, total_amount, valid)
  SELECT year, week_no, sum(rained), sum(amount), 1 FROM rainfall.daily_data GROUP BY 1, 2;

-- Update Missing data
UPDATE rainfall.weekly_data AS rd SET days_total = crw.count, days_valid = crw.count
FROM (SELECT rw.year, rw.week_no, count(rw.dow) AS count from rainfall.daily_data AS rw GROUP BY rw.year, rw.week_no) AS crw
WHERE rd.year = crw.year and rd.week_no = crw.week_no;

-- Update Vaildilaty
UPDATE rainfall.weekly_data AS rd SET valid = 0, days_valid = days_valid - crw.invaild
FROM (SELECT rw.year, week(to_date((year::int * 10000 + month::int * 100 + day::int)::varchar,'YYYYMMDD')) AS week_no, count(1) as invaild FROM rainfall.missing_data AS rw GROUP BY rw.year, week_no) AS crw
WHERE rd.year = crw.year and rd.week_no = crw.week_no;

COMMIT;
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Weekly table created as rainfall.weekly_data


