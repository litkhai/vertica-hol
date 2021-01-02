-- Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-01

\! echo [$(date +"%Y-%m-%d %T")][TASK] Create Schema rainfall and table for initial load
CREATE SCHEMA rainfall;
CREATE FLEX TABLE rainfall.csv_raw();

\! echo [$(date +"%Y-%m-%d %T")][TASK] Data Loading
\! echo [$(date +"%Y-%m-%d %T")][TASK]  INITIAL CSV FILE -> rainfall.csv_raw as flex table
COPY rainfall.csv_raw FROM '/home/dbadmin/rainfall/IDCJAC0009_040913_1800_Data.csv' PARSER fcsvparser();

\! echo [$(date +"%Y-%m-%d %T")][TASK] Build keys and create a view
SELECT compute_flextable_keys('rainfall.csv_raw');
SELECT build_flextable_view('rainfall.csv_raw');

-- SELECT * FROM rainfall.csv_raw_view
\! echo [$(date +"%Y-%m-%d %T")][TASK] Create Table rainfall.raw from flex table
CREATE TABLE rainfall.raw AS SELECT year, month, day, rainfall FROM rainfall.csv_raw_view;

\d rainfall.raw
\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] CSV File loading Complete