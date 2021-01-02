--Script for Predictive Rainfall Forcast on Vertica Analytic Platform
-- wrtten by Ken Lee(litkhai@gmail.com) on 2018-02-04

\! sh a_create_weekly_gap_tables.sh
\i temp_weekly_gap.sql
\! sh b_create_daily_gap_tables.sh
\i temp_daily_gap.sql
\! sh c_calculate_and_fill_gaps.sh
\i temp_calculate_and_fill_gap.sql
