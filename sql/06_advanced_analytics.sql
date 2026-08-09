-- ============================================================
-- SKYLINE AIRLINES
-- ADVANCED SQL ANALYTICS
-- ============================================================


-- ============================================================
-- 1. EXECUTIVE KPIs
-- Overall business performance
-- ============================================================

SELECT

    COUNT(*) AS total_passengers,

    -- Satisfaction Rate
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS satisfaction_rate,

    -- Average NPS
    ROUND(
        AVG(nps),
        2
    ) AS average_nps,

    -- Complaint Rate
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN complainttype IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS complaint_rate,

    -- Average Delay
    ROUND(
        AVG(delay),
        2
    ) AS average_delay,

    -- Total Fare Revenue
    ROUND(
        SUM(fare),
        2
    ) AS total_fare_revenue,

    -- Total Ancillary Revenue
    ROUND(
        SUM(ancillaryrevenue),
        2
    ) AS total_ancillary_revenue,

    -- Total Revenue
    ROUND(
        SUM(fare + ancillaryrevenue),
        2
    ) AS total_revenue,

    -- Revenue per Passenger
    ROUND(
        AVG(fare + ancillaryrevenue),
        2
    ) AS revenue_per_passenger

FROM warehouse.fact_passenger_experience;


-- ============================================================
-- 2. ROUTE PERFORMANCE
-- Identify routes with low satisfaction and high delays
-- ============================================================

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
        AVG(f.nps),
        2
    ) AS average_nps,

    ROUND(
        AVG(f.delay),
        2
    ) AS average_delay,

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
        AVG(f.fare + f.ancillaryrevenue),
        2
    ) AS revenue_per_passenger

FROM warehouse.fact_passenger_experience f

INNER JOIN warehouse.dim_flight df
    ON f.flightkey = df.flightkey

GROUP BY
    df.route,
    df.routetype

ORDER BY
    satisfaction_rate ASC;

-- ============================================================
-- 3. ROUTE RANKING
-- Rank routes by satisfaction performance
-- ============================================================

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
            AVG(f.delay),
            2
        ) AS average_delay

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_flight df
        ON f.flightkey = df.flightkey

    GROUP BY
        df.route,
        df.routetype
)

SELECT

    route,
    routetype,
    passenger_count,
    satisfaction_rate,
    average_delay,

    DENSE_RANK() OVER (
        ORDER BY satisfaction_rate ASC
    ) AS satisfaction_rank

FROM route_metrics

ORDER BY
    satisfaction_rank,
    passenger_count DESC;




-- ============================================================
-- 4. AIRPORT PERFORMANCE
-- Analyze passenger satisfaction at origin and destination
-- airports separately.
-- ============================================================

WITH airport_experience AS (

    -- Origin airport experience
    SELECT
        da.airportkey,
        da.airportcode,
        da.airportname,
        'Origin' AS airport_role,
        f.overallsatisfaction,
        f.nps,
        f.delay,
        f.complainttype

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_flight df
        ON f.flightkey = df.flightkey

    INNER JOIN warehouse.dim_airport da
        ON df.originairportkey = da.airportkey


    UNION ALL


    -- Destination airport experience
    SELECT
        da.airportkey,
        da.airportcode,
        da.airportname,
        'Destination' AS airport_role,
        f.overallsatisfaction,
        f.nps,
        f.delay,
        f.complainttype

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_flight df
        ON f.flightkey = df.flightkey

    INNER JOIN warehouse.dim_airport da
        ON df.destinationairportkey = da.airportkey
)

SELECT

    airportcode,
    airportname,
    airport_role,

    COUNT(*) AS passenger_count,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS satisfaction_rate,

    ROUND(
        AVG(nps),
        2
    ) AS average_nps,

    ROUND(
        AVG(delay),
        2
    ) AS average_delay,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN complainttype IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS complaint_rate

FROM airport_experience

GROUP BY
    airportcode,
    airportname,
    airport_role

ORDER BY
    satisfaction_rate ASC;

-- ============================================================
-- 5. CABIN PERFORMANCE
-- Compare passenger satisfaction across cabin classes
-- ============================================================

SELECT

    dc.cabinclass,

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

    ROUND(AVG(f.nps), 2) AS average_nps,

    ROUND(AVG(f.delay), 2) AS average_delay,

    ROUND(AVG(f.fare), 2) AS average_fare,

    ROUND(AVG(f.ancillaryrevenue), 2) AS average_ancillary_revenue,

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
    ) AS complaint_rate

FROM warehouse.fact_passenger_experience f

INNER JOIN warehouse.dim_cabin dc
    ON f.cabinkey = dc.cabinkey

GROUP BY
    dc.cabinclass

ORDER BY
    satisfaction_rate ASC;


-- ============================================================
-- 6. CUSTOMER SEGMENTATION
-- Identify passenger segments with different satisfaction
-- and revenue patterns.
-- ============================================================

SELECT

    dp.customertype,
    dp.traveltype,
    dp.loyaltytier,
    dp.agegroup,

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
        AVG(f.nps),
        2
    ) AS average_nps,

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
        AVG(f.fare + f.ancillaryrevenue),
        2
    ) AS revenue_per_passenger,

    ROUND(
        AVG(f.delay),
        2
    ) AS average_delay

FROM warehouse.fact_passenger_experience f

INNER JOIN warehouse.dim_passenger dp
    ON f.passengerkey = dp.passengerkey

GROUP BY
    dp.customertype,
    dp.traveltype,
    dp.loyaltytier,
    dp.agegroup

HAVING COUNT(*) >= 20

ORDER BY
    satisfaction_rate ASC;


-- ============================================================
-- 7. SERVICE QUALITY ANALYSIS
-- Identify service dimensions associated with passenger
-- satisfaction.
-- ============================================================

SELECT

    'Check-In' AS service_category,

    ROUND(AVG(checkinrating), 2) AS average_rating,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN checkinrating <= 2
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS low_rating_rate,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN checkinrating >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN checkinrating >= 4
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS satisfaction_when_good

FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Boarding',
    ROUND(AVG(boardingrating), 2),
    ROUND(
        100.0 * SUM(CASE WHEN boardingrating <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN boardingrating >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN boardingrating >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Crew',
    ROUND(AVG(crewrating), 2),
    ROUND(
        100.0 * SUM(CASE WHEN crewrating <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN crewrating >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN crewrating >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Seat Comfort',
    ROUND(AVG(seatcomfort), 2),
    ROUND(
        100.0 * SUM(CASE WHEN seatcomfort <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN seatcomfort >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN seatcomfort >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'WiFi',
    ROUND(AVG(wifi), 2),
    ROUND(
        100.0 * SUM(CASE WHEN wifi <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN wifi >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN wifi >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Entertainment',
    ROUND(AVG(entertainment), 2),
    ROUND(
        100.0 * SUM(CASE WHEN entertainment <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN entertainment >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN entertainment >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Food',
    ROUND(AVG(food), 2),
    ROUND(
        100.0 * SUM(CASE WHEN food <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN food >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN food >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Cleanliness',
    ROUND(AVG(cleanliness), 2),
    ROUND(
        100.0 * SUM(CASE WHEN cleanliness <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN cleanliness >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN cleanliness >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

UNION ALL

SELECT
    'Baggage Handling',
    ROUND(AVG(baggagehandling), 2),
    ROUND(
        100.0 * SUM(CASE WHEN baggagehandling <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ),
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN baggagehandling >= 4
                     AND overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(CASE WHEN baggagehandling >= 4 THEN 1 ELSE 0 END),
            0
        ),
        2
    )
FROM warehouse.fact_passenger_experience

ORDER BY
    satisfaction_when_good DESC;


-- ============================================================
-- 8. DELAY IMPACT ANALYSIS
-- Measure the relationship between flight delays and
-- passenger satisfaction.
-- ============================================================

SELECT

    CASE
        WHEN delay <= 0 THEN 'On Time'
        WHEN delay <= 30 THEN 'Minor Delay'
        WHEN delay <= 60 THEN 'Moderate Delay'
        WHEN delay <= 120 THEN 'Major Delay'
        ELSE 'Severe Delay'
    END AS delay_category,

    COUNT(*) AS passenger_count,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS satisfaction_rate,

    ROUND(
        AVG(nps),
        2
    ) AS average_nps,

    ROUND(
        AVG(delay),
        2
    ) AS average_delay,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN complainttype IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS complaint_rate

FROM warehouse.fact_passenger_experience

GROUP BY
    CASE
        WHEN delay <= 0 THEN 'On Time'
        WHEN delay <= 30 THEN 'Minor Delay'
        WHEN delay <= 60 THEN 'Moderate Delay'
        WHEN delay <= 120 THEN 'Major Delay'
        ELSE 'Severe Delay'
    END

ORDER BY
    MIN(delay);


-- ============================================================
-- 9. COMPLAINT ANALYSIS
-- Identify the most common passenger complaint categories.
-- ============================================================

SELECT

    complainttype,

    COUNT(*) AS complaint_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS complaint_share,

    ROUND(
        AVG(delay),
        2
    ) AS average_delay,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN overallsatisfaction = 'Satisfied'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS satisfaction_rate

FROM warehouse.fact_passenger_experience

WHERE complainttype IS NOT NULL

GROUP BY
    complainttype

ORDER BY
    complaint_count DESC;


-- ============================================================
-- 9.1 COMPLAINTS BY ROUTE
-- Identify routes with unusually high complaint rates.
-- ============================================================

SELECT

    df.route,

    df.routetype,

    COUNT(*) AS passenger_count,

    COUNT(f.complainttype) AS complaint_count,

    ROUND(
        100.0 * COUNT(f.complainttype) / COUNT(*),
        2
    ) AS complaint_rate,

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
        AVG(f.delay),
        2
    ) AS average_delay

FROM warehouse.fact_passenger_experience f

INNER JOIN warehouse.dim_flight df
    ON f.flightkey = df.flightkey

GROUP BY
    df.route,
    df.routetype

HAVING COUNT(*) >= 50

ORDER BY
    complaint_rate DESC;


-- ============================================================
-- 10. MONTHLY SATISFACTION
-- Month-over-month analysis using LAG()
-- ============================================================

WITH monthly_metrics AS (

    SELECT

        DATE_TRUNC('month', dd.fulldate)::date AS month_start,

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

        ROUND(AVG(f.nps), 2) AS average_nps,

        ROUND(AVG(f.delay), 2) AS average_delay,

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
        ) AS complaint_rate

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_date dd
        ON f.datekey = dd.datekey

    GROUP BY
        DATE_TRUNC('month', dd.fulldate)
),

monthly_with_previous AS (

    SELECT

        *,
        
        LAG(satisfaction_rate) OVER (
            ORDER BY month_start
        ) AS previous_month_satisfaction

    FROM monthly_metrics
)

SELECT

    month_start,
    passenger_count,
    satisfaction_rate,
    previous_month_satisfaction,

    ROUND(
        satisfaction_rate - previous_month_satisfaction,
        2
    ) AS satisfaction_change_pp,

    average_nps,
    average_delay,
    complaint_rate

FROM monthly_with_previous

ORDER BY
    month_start;


	-- ============================================================
-- 11. ROLLING 30-DAY SATISFACTION
-- Smooth short-term fluctuations in satisfaction.
-- ============================================================

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
)

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

ORDER BY
    fulldate;


-- ============================================================
-- 12. REVENUE VS SATISFACTION
-- Compare route revenue with passenger experience.
-- ============================================================

WITH route_business_metrics AS (

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
            AVG(f.fare + f.ancillaryrevenue),
            2
        ) AS revenue_per_passenger,

        ROUND(
            SUM(f.fare + f.ancillaryrevenue),
            2
        ) AS total_revenue,

        ROUND(AVG(f.delay), 2) AS average_delay,

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
        ) AS complaint_rate

    FROM warehouse.fact_passenger_experience f

    INNER JOIN warehouse.dim_flight df
        ON f.flightkey = df.flightkey

    GROUP BY
        df.route,
        df.routetype
)

SELECT

    route,
    routetype,
    passenger_count,
    satisfaction_rate,
    revenue_per_passenger,
    total_revenue,
    average_delay,
    complaint_rate

FROM route_business_metrics

ORDER BY
    total_revenue DESC;

-- ============================================================
-- 13. ROUTE PRIORITY SCORING
-- Identify routes requiring the greatest business attention.
-- ============================================================

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

FROM scored

ORDER BY
    priority_score DESC;