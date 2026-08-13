CREATE VIEW warehouse.vw_route_priority AS

WITH route_metrics AS (

    SELECT

        df.route,
        df.routetype,

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
        ) AS satisfaction_rate,

        ROUND(
            100.0 *
            SUM(
                CASE
                    WHEN f.complainttype IS NOT NULL
                    THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        ) AS complaint_rate,

        ROUND(
            AVG(f.delay),
            2
        ) AS average_delay,

        ROUND(
            SUM(f.fare + f.ancillaryrevenue),
            2
        ) AS total_revenue

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_flight df
        ON f.flightkey = df.flightkey

    GROUP BY
        df.route,
        df.routetype

    HAVING COUNT(*) >= 50
),

normalized AS (

    SELECT

        *,

        PERCENT_RANK() OVER (
            ORDER BY satisfaction_rate ASC
        ) AS dissatisfaction_score,

        PERCENT_RANK() OVER (
            ORDER BY complaint_rate ASC
        ) AS complaint_score,

        PERCENT_RANK() OVER (
            ORDER BY average_delay ASC
        ) AS delay_score,

        PERCENT_RANK() OVER (
            ORDER BY passenger_count ASC
        ) AS volume_score

    FROM route_metrics
),

scored AS (

    SELECT

        *,

        (
            0.40 * dissatisfaction_score
            + 0.25 * complaint_score
            + 0.20 * delay_score
            + 0.15 * volume_score
        ) AS raw_priority_score

    FROM normalized
)

SELECT

    route,
    routetype,
    passenger_count,
    satisfaction_rate,
    complaint_rate,
    average_delay,
    total_revenue,

    ROUND(
        (100 * raw_priority_score)::numeric,
        2
    ) AS priority_score,

    CASE

        WHEN raw_priority_score >= 0.75
            THEN 'Critical Priority'

        WHEN raw_priority_score >= 0.50
            THEN 'High Priority'

        WHEN raw_priority_score >= 0.25
            THEN 'Medium Priority'

        ELSE 'Low Priority'

    END AS priority_category

FROM scored;

SELECT *
FROM warehouse.vw_route_priority
ORDER BY priority_score DESC;
