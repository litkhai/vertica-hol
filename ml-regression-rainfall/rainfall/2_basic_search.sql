-- Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-01

\! echo [$(date +"%Y-%m-%d %T")][TASK] Check how many data are missing
select count(*) as missing_data from rainfall.raw where rainfall is NULL;

\! echo [$(date +"%Y-%m-%d %T")][TASK] Check how many are on year 1999
select count(*) as missing_data from rainfall.raw where rainfall is NULL and year=1999;
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Most missing data relies on year 1999 and few on other years
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Decided to drop inital missing data of 1999 since they are meaningless to fill the gaps

DELETE FROM rainfall.raw WHERE rainfall is NULL and (year=1999 and month < 12);
DELETE FROM rainfall.raw WHERE rainfall is NULL and (year=1999 and month = 12 and day <= 10);
COMMIT;

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] The first NULL values dropped
\! echo [$(date +"%Y-%m-%d %T")][TASK] Create to a separate table of gaps- rainfall.missing_data

-- CREATE TABLE rainfall.missing_data AS SELECT to_date((year::int * 10000 + month::int * 100 + day::int)::varchar,'YYYYMMDD') AS date, rainfall FROM rainfall.raw WHERE rainfall is NULL;

CREATE TABLE rainfall.missing_data AS SELECT * from rainfall.raw where rainfall is NULL;

\! echo [$(date +"%Y-%m-%d %T")][TASK] Check the number of missing data
SELECT count(*) FROM rainfall.missing_data;

\! echo [$(date +"%Y-%m-%d %T")][TASK] Drill-down to Week-Level to check is there any week with more than a missing datum exists

SELECT m.year, m.month, m.day FROM rainfall.missing_data as m, (SELECT year, month, count(*) FROM rainfall.missing_data WHERE year != 1999 GROUP BY 1 , 2 ORDER BY 3 DESC Limit 7) as t WHERE m.year=t.year AND m.month=t.month;

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] The data missing for more than a day per week is quite rare