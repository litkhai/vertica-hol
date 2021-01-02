--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- written by Ken Lee(litkhai@gmail.com) on 2018-02-05

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Prepare for dividing of tables for week / dow

\a
\pset tuples_only on

\o datalist_weekly.txt
select distinct(week_no) from rainfall_ml.weekly_data;
\o

\o datalist_daily.txt
select DISTINCT week_no, dow from rainfall.daily_data;
\o

\a
\pset tuples_only off
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Create seperate tables

\! sh e_separate_week_divide_ml.sh
\i temp_weekly_ml.sql
\! sh f_separate_dow_divide_ml.sh
\i temp_daily_ml.sql
