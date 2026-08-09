--1. Check Row Counts

SELECT COUNT(*) FROM staging.stg_passengers;
SELECT COUNT(*) FROM staging.stg_flights;
SELECT COUNT(*) FROM staging.stg_bookings;
SELECT COUNT(*) FROM staging.stg_service;
SELECT COUNT(*) FROM staging.stg_feedback;

--2. Checking for Duplicate Passengers

SELECT
    PassengerID,
    COUNT(*)
FROM staging.stg_passengers
GROUP BY PassengerID
HAVING COUNT(*) > 1;

--3. Checking for Missing Values

---Missing values in Passenger table---
SELECT
COUNT(*) FILTER (WHERE LoyaltyTier IS NULL) AS Missing_Loyalty,
COUNT(*) FILTER (WHERE Gender IS NULL) AS Missing_Gender,
COUNT(*) FILTER (WHERE Country IS NULL) AS Missing_Country
FROM staging.stg_passengers;

---Missing values in Service table---
SELECT
COUNT(*) FILTER (WHERE WiFi IS NULL) AS Missing_WiFi,
COUNT(*) FILTER (WHERE Entertainment IS NULL) AS Missing_Entertainment
FROM staging.stg_service;

---Missing values in Feedback table---
SELECT
COUNT(*) FILTER (WHERE Review IS NULL) AS Missing_Review
FROM staging.stg_feedback;

--4. Checking for Distinct values (for checking data inconsistencies)

---Gender Column
SELECT DISTINCT Gender
FROM staging.stg_passengers
ORDER BY Gender;

---Travel Type
SELECT DISTINCT TravelType
FROM staging.stg_passengers;

---Customer Type
SELECT DISTINCT CustomerType
FROM staging.stg_passengers;

---Cabin Class
SELECT DISTINCT CabinClass
FROM staging.stg_bookings;


--5. Checking Rating Ranges

SELECT
MIN(CheckInRating),
MAX(CheckInRating),

MIN(BoardingRating),
MAX(BoardingRating),

MIN(CrewRating),
MAX(CrewRating)
FROM staging.stg_service;

--6. Delay Distribution

SELECT
MIN(Delay),
MAX(Delay),
AVG(Delay)
FROM staging.stg_flights;

--7. Fare Distribution

SELECT
MIN(Fare),
MAX(Fare),
AVG(Fare)
FROM staging.stg_bookings;

--8. Satisfaction Distribution

SELECT
OverallSatisfaction,
COUNT(*)
FROM staging.stg_feedback
GROUP BY OverallSatisfaction;