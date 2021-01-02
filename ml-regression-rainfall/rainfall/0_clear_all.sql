--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- written by Ken Lee(litkhai@gmail.com) on 2018-02-05
-- Clearing All SCHEMA, MODELS Built

--\! sh p_delete_gap_prediction_dow.sh
--\! sh q_delete_gap_prediction_week.sh
--\i temp_drop_gap_model.sql

\! sh s_delete_ml_prediction_dow.sh
\! sh t_delete_ml_prediction_week.sh
\i temp_drop_ml_model.sql

\! rm temp*sql
\! rm *txt
\! rm rainfall.csv_raw
\! rm -rf output

DROP SCHEMA rainfall_ml CASCADE;
DROP SCHEMA rainfall_gap CASCADE;
DROP SCHEMA rainfall CASCADE;
