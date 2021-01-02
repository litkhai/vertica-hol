--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- written by Ken Lee(litkhai@gmail.com) on 2018-02-05

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Provide predictions and evaluations of models as txt file

\! sh g_create_results_for_dow.sh
\! sh h_create_results_for_week.sh
\i temp_create_output.sql

\! echo [$(date +"%Y-%m-%d %T")][MESSAGE] Result has been written to /output directory
