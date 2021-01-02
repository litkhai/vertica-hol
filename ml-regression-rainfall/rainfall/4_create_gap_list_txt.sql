--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-03

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Find gap values and create text list

\a
\pset tuples_only on

\o gaplist_weekly.txt
select distinct(week_no) from rainfall.weekly_data where valid=0;
\o
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Weekly gaplist created as gaplist_weekly.txt


\o gaplist_daily.txt
select DISTINCT week_no, dow from rainfall.daily_data where valid=0;
\o
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Daily gaplist created as gaplist_daily.txt


\o gaplist_whole.txt
select DISTINCT year, week_no, dow from rainfall.daily_data where valid=0;
\o

\a
\pset tuples_only off
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Whole gaplist created as gaplist_whole.txt
