CREATE TABLE staging.stg_passengers (

    PassengerID VARCHAR(20) PRIMARY KEY,

    Age INT,

    Gender VARCHAR(20),

    CustomerType VARCHAR(50),

    LoyaltyTier VARCHAR(50),

    TravelType VARCHAR(50),

    Country VARCHAR(100)

);


CREATE TABLE staging.stg_flights (

    FlightID VARCHAR(20) PRIMARY KEY,

    Route VARCHAR(100),

    Origin VARCHAR(10),

    Destination VARCHAR(10),

    DepartureTime TIMESTAMP,

    ArrivalTime TIMESTAMP,

    Duration INT,

    Distance INT,

    Aircraft VARCHAR(100),

    Delay INT

);

CREATE TABLE staging.stg_bookings
(
    BookingID VARCHAR(20),

    PassengerID VARCHAR(20),

    FlightID VARCHAR(20),

    BookingDate TIMESTAMP,

    Fare DECIMAL(10,2),

    CabinClass VARCHAR(50),

    BookingChannel VARCHAR(50),

    AncillaryRevenue DECIMAL(10,2)
);


CREATE TABLE staging.stg_service
(
    BookingID VARCHAR(20),

    PassengerID VARCHAR(20),

    FlightID VARCHAR(20),

    CheckInRating INT,

    BoardingRating INT,

    CrewRating INT,

    SeatComfort INT,

    WiFi INT,

    Entertainment INT,

    Food INT,

    Cleanliness INT,

    BaggageHandling INT
);

CREATE TABLE staging.stg_feedback
(
    BookingID VARCHAR(20),

    PassengerID VARCHAR(20),

    FlightID VARCHAR(20),

    OverallSatisfaction VARCHAR(20),

    NPS INT,

    Complaint VARCHAR(100),

    Review TEXT
);