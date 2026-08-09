--1. Load dim_passenger table---
---Cleaned and transformed passenger data from staging (trim spaces, standardize text, handle NULLs, derive AgeGroup).

INSERT INTO warehouse.dim_passenger
(
    PassengerID,
    Age,
    AgeGroup,
    Gender,
    CustomerType,
    LoyaltyTier,
    TravelType,
    Country
)

SELECT

    PassengerID,

    Age,

    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END,

    INITCAP(TRIM(Gender)),

    TRIM(CustomerType),

    COALESCE(NULLIF(TRIM(LoyaltyTier), ''), 'None'),

    TRIM(TravelType),

    TRIM(Country)

FROM staging.stg_passengers;


--2. Load DimAirport: Extracting unique airports from flight data and enrich with airport metadata.

INSERT INTO warehouse.dim_airport
(
    AirportCode,
    AirportName,
    City,
    State,
    Country,
    AirportType
)

SELECT DISTINCT
    AirportCode,

    CASE AirportCode
        WHEN 'DEL' THEN 'Indira Gandhi International Airport'
        WHEN 'BOM' THEN 'Chhatrapati Shivaji Maharaj International Airport'
        WHEN 'BLR' THEN 'Kempegowda International Airport'
        WHEN 'HYD' THEN 'Rajiv Gandhi International Airport'
        WHEN 'MAA' THEN 'Chennai International Airport'
        WHEN 'CCU' THEN 'Netaji Subhas Chandra Bose International Airport'
        WHEN 'AMD' THEN 'Sardar Vallabhbhai Patel International Airport'
        WHEN 'GOI' THEN 'Manohar International Airport'
        WHEN 'LKO' THEN 'Chaudhary Charan Singh International Airport'
        WHEN 'PNQ' THEN 'Pune Airport'
        WHEN 'IXC' THEN 'Chandigarh Airport'
        WHEN 'COK' THEN 'Cochin International Airport'
        WHEN 'DXB' THEN 'Dubai International Airport'
        WHEN 'SIN' THEN 'Singapore Changi Airport'
        WHEN 'LHR' THEN 'London Heathrow Airport'
        WHEN 'DOH' THEN 'Hamad International Airport'
        WHEN 'BKK' THEN 'Suvarnabhumi Airport'
        WHEN 'MCT' THEN 'Muscat International Airport'
        WHEN 'KTM' THEN 'Tribhuvan International Airport'
        WHEN 'CMB' THEN 'Bandaranaike International Airport'
    END AS AirportName,

    CASE AirportCode
        WHEN 'DEL' THEN 'New Delhi'
        WHEN 'BOM' THEN 'Mumbai'
        WHEN 'BLR' THEN 'Bengaluru'
        WHEN 'HYD' THEN 'Hyderabad'
        WHEN 'MAA' THEN 'Chennai'
        WHEN 'CCU' THEN 'Kolkata'
        WHEN 'AMD' THEN 'Ahmedabad'
        WHEN 'GOI' THEN 'Goa'
        WHEN 'LKO' THEN 'Lucknow'
        WHEN 'PNQ' THEN 'Pune'
        WHEN 'IXC' THEN 'Chandigarh'
        WHEN 'COK' THEN 'Kochi'
        WHEN 'DXB' THEN 'Dubai'
        WHEN 'SIN' THEN 'Singapore'
        WHEN 'LHR' THEN 'London'
        WHEN 'DOH' THEN 'Doha'
        WHEN 'BKK' THEN 'Bangkok'
        WHEN 'MCT' THEN 'Muscat'
        WHEN 'KTM' THEN 'Kathmandu'
        WHEN 'CMB' THEN 'Colombo'
    END AS City,

    CASE AirportCode
        WHEN 'DEL' THEN 'Delhi'
        WHEN 'BOM' THEN 'Maharashtra'
        WHEN 'BLR' THEN 'Karnataka'
        WHEN 'HYD' THEN 'Telangana'
        WHEN 'MAA' THEN 'Tamil Nadu'
        WHEN 'CCU' THEN 'West Bengal'
        WHEN 'AMD' THEN 'Gujarat'
        WHEN 'GOI' THEN 'Goa'
        WHEN 'LKO' THEN 'Uttar Pradesh'
        WHEN 'PNQ' THEN 'Maharashtra'
        WHEN 'IXC' THEN 'Chandigarh'
        WHEN 'COK' THEN 'Kerala'
        WHEN 'DXB' THEN 'Dubai'
        WHEN 'SIN' THEN 'Singapore'
        WHEN 'LHR' THEN 'England'
        WHEN 'DOH' THEN 'Doha'
        WHEN 'BKK' THEN 'Bangkok'
        WHEN 'MCT' THEN 'Muscat'
        WHEN 'KTM' THEN 'Bagmati'
        WHEN 'CMB' THEN 'Western Province'
    END AS State,

    CASE
        WHEN AirportCode IN ('DEL','BOM','BLR','HYD','MAA','CCU','AMD','GOI','LKO','PNQ','IXC','COK')
            THEN 'India'
        WHEN AirportCode = 'DXB' THEN 'UAE'
        WHEN AirportCode = 'SIN' THEN 'Singapore'
        WHEN AirportCode = 'LHR' THEN 'United Kingdom'
        WHEN AirportCode = 'DOH' THEN 'Qatar'
        WHEN AirportCode = 'BKK' THEN 'Thailand'
        WHEN AirportCode = 'MCT' THEN 'Oman'
        WHEN AirportCode = 'KTM' THEN 'Nepal'
        WHEN AirportCode = 'CMB' THEN 'Sri Lanka'
    END AS Country,

    CASE
        WHEN AirportCode IN ('DEL','BOM','BLR','HYD','MAA','CCU')
            THEN 'Hub'
        WHEN AirportCode IN ('AMD','GOI','LKO','PNQ','IXC','COK')
            THEN 'Domestic'
        WHEN AirportCode IN ('DXB','SIN','LHR','DOH','BKK','MCT','KTM','CMB')
            THEN 'International'
    END AS AirportType

FROM
(
    SELECT TRIM(Origin) AS AirportCode
    FROM staging.stg_flights

    UNION

    SELECT TRIM(Destination)
    FROM staging.stg_flights
) airports

ORDER BY AirportCode;



--3. Load DimAircraft: Extracting unique aircraft and derive manufacturer and aircraft family.

INSERT INTO warehouse.dim_aircraft
(
    AircraftName,
    Manufacturer,
    AircraftFamily
)

SELECT DISTINCT

    TRIM(Aircraft) AS AircraftName,

    CASE
        WHEN Aircraft LIKE 'Airbus%' THEN 'Airbus'
        WHEN Aircraft LIKE 'Boeing%' THEN 'Boeing'
        WHEN Aircraft LIKE 'ATR%' THEN 'ATR'
    END,

    CASE

        WHEN Aircraft LIKE '%A320%' THEN 'A320 Series'

        WHEN Aircraft LIKE '%A321%' THEN 'A320 Series'

        WHEN Aircraft LIKE '%A350%' THEN 'A350 Series'

        WHEN Aircraft LIKE '%737%' THEN '737 MAX Series'

        WHEN Aircraft LIKE '%777%' THEN '777 Series'

        WHEN Aircraft LIKE '%787%' THEN '787 Dreamliner'

        WHEN Aircraft LIKE 'ATR%' THEN 'ATR 72 Series'

    END

FROM staging.stg_flights

ORDER BY AircraftName;


-- 4. Load DimCabin: Loading standardized cabin classes from booking data.

INSERT INTO warehouse.dim_cabin
(
    CabinClass
)

SELECT DISTINCT
    INITCAP(TRIM(CabinClass)) AS CabinClass

FROM staging.stg_bookings

ORDER BY CabinClass;


--5. Load DimDate: Generate calendar dimension from flight dates

INSERT INTO warehouse.dim_date
(
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    DayName,
    IsWeekend
)

SELECT

    TO_CHAR(d::DATE,'YYYYMMDD')::INT,

    d::DATE,

    EXTRACT(DAY FROM d),

    EXTRACT(MONTH FROM d),

    TRIM(TO_CHAR(d,'Month')),

    EXTRACT(QUARTER FROM d),

    EXTRACT(YEAR FROM d),

    TRIM(TO_CHAR(d,'Day')),

    CASE
        WHEN EXTRACT(ISODOW FROM d) IN (6,7)
        THEN TRUE
        ELSE FALSE
    END

FROM generate_series
(
    (
        SELECT MIN(DATE(DepartureTime))
        FROM staging.stg_flights
    ),

    (
        SELECT MAX(DATE(ArrivalTime))
        FROM staging.stg_flights
    ),

    INTERVAL '1 day'
) d;


--6. Load DimFlight: Transform flight data and map surrogate keys

INSERT INTO warehouse.dim_flight
(
    FlightID,
    Route,
    RouteType,
    OriginAirportKey,
    DestinationAirportKey,
    AircraftKey,
    DepartureTime,
    ArrivalTime,
    Duration,
    Distance
)

SELECT

    f.FlightID,

    TRIM(f.Route),

    INITCAP(TRIM(f.RouteType)),

    oa.AirportKey,

    da.AirportKey,

    ac.AircraftKey,

    f.DepartureTime,

    f.ArrivalTime,

    f.Duration,

    f.Distance

FROM staging.stg_flights f

INNER JOIN warehouse.dim_airport oa
ON UPPER(TRIM(f.Origin)) = oa.AirportCode

INNER JOIN warehouse.dim_airport da
ON UPPER(TRIM(f.Destination)) = da.AirportCode

INNER JOIN warehouse.dim_aircraft ac
ON TRIM(f.Aircraft) = ac.AircraftName;


--6. Load DimBooking

INSERT INTO warehouse.dim_booking
(
    BookingID,
    PassengerID,
    FlightID,
    BookingDate,
    BookingChannel
)

SELECT

    BookingID,

    PassengerID,

    FlightID,

    BookingDate,

    INITCAP(TRIM(BookingChannel))

FROM staging.stg_bookings;

-- ===========================================================
--7.  Load FactPassengerExperience
-- ===========================================================

INSERT INTO warehouse.fact_passenger_experience
(
    PassengerKey,
    FlightKey,
    BookingKey,
    CabinKey,
    DateKey,
    Delay,
    Fare,
    AncillaryRevenue,
    CheckInRating,
    BoardingRating,
    CrewRating,
    SeatComfort,
    WiFi,
    Entertainment,
    Food,
    Cleanliness,
    BaggageHandling,
    NPS,
    OverallSatisfaction
)

SELECT

    dp.PassengerKey,

    df.FlightKey,

    db.BookingKey,

    dc.CabinKey,

    dd.DateKey,

    sf.Delay,

    sb.Fare,

    sb.AncillaryRevenue,

    ss.CheckInRating,

    ss.BoardingRating,

    ss.CrewRating,

    ss.SeatComfort,

    ss.WiFi,

    ss.Entertainment,

    ss.Food,

    ss.Cleanliness,

    ss.BaggageHandling,

    fb.NPS,

    fb.OverallSatisfaction

FROM staging.stg_bookings sb

INNER JOIN warehouse.dim_passenger dp
ON sb.PassengerID = dp.PassengerID

INNER JOIN warehouse.dim_booking db
ON sb.BookingID = db.BookingID

INNER JOIN warehouse.dim_flight df
ON sb.FlightID = df.FlightID

INNER JOIN warehouse.dim_cabin dc
ON sb.CabinClass = dc.CabinClass

INNER JOIN warehouse.dim_date dd
ON DATE(sb.BookingDate) = dd.FullDate

INNER JOIN staging.stg_service ss
ON sb.BookingID = ss.BookingID

INNER JOIN staging.stg_feedback fb
ON sb.BookingID = fb.BookingID

INNER JOIN staging.stg_flights sf
ON sb.FlightID = sf.FlightID;

