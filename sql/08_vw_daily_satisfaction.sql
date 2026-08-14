CREATE OR REPLACE VIEW warehouse.vw_daily_satisfaction AS

WITH daily_metrics AS (

    SELECT
        dd.fulldate,

        COUNT(*) AS passenger_count,

        ROUND(
            100.0 *
            SUM(
                CASE
                    WHEN f.overallsatisfaction = 'Satisfied'
                    THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        ) AS daily_satisfaction_rate

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_date dd
        ON f.datekey = dd.datekey

    GROUP BY
        dd.fulldate
),

rolling_metrics AS (

    SELECT
        fulldate,
        passenger_count,
        daily_satisfaction_rate,

        ROUND(
            AVG(daily_satisfaction_rate) OVER (
                ORDER BY fulldate
                RANGE BETWEEN INTERVAL '29 days' PRECEDING
                AND CURRENT ROW
            ),
            2
        ) AS rolling_30_day_satisfaction

    FROM daily_metrics
)

SELECT
    fulldate,
    passenger_count,
    daily_satisfaction_rate,
    rolling_30_day_satisfaction

FROM rolling_metrics

ORDER BY fulldate;

SELECT *
FROM warehouse.vw_daily_satisfaction
ORDER BY fulldate;