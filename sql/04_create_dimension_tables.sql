CREATE TABLE warehouse.dim_passenger (

    PassengerKey SERIAL PRIMARY KEY,

    PassengerID VARCHAR(20) UNIQUE NOT NULL,

    Age INT NOT NULL,

    AgeGroup VARCHAR(20) NOT NULL,

    Gender VARCHAR(20) NOT NULL,

    CustomerType VARCHAR(50) NOT NULL,

    LoyaltyTier VARCHAR(50) NOT NULL,

    TravelType VARCHAR(50) NOT NULL,

    Country VARCHAR(100) NOT NULL
);


CREATE TABLE warehouse.dim_airport (

    AirportKey SERIAL PRIMARY KEY,

    AirportCode VARCHAR(10) UNIQUE NOT NULL,

    AirportName VARCHAR(100) NOT NULL,

    City VARCHAR(100) NOT NULL,

    State VARCHAR(100) NOT NULL,

    Country VARCHAR(100) NOT NULL
);

CREATE TABLE warehouse.dim_aircraft (

    AircraftKey SERIAL PRIMARY KEY,

    AircraftName VARCHAR(100) UNIQUE NOT NULL,

    Manufacturer VARCHAR(50) NOT NULL,

    AircraftFamily VARCHAR(50) NOT NULL
);

CREATE TABLE warehouse.dim_cabin (

    CabinKey SERIAL PRIMARY KEY,

    CabinClass VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE warehouse.dim_date (

    DateKey INT PRIMARY KEY,

    FullDate DATE NOT NULL,

    DayNumber INT NOT NULL,

    MonthNumber INT NOT NULL,

    MonthName VARCHAR(20) NOT NULL,

    QuarterNumber INT NOT NULL,

    YearNumber INT NOT NULL,

    DayName VARCHAR(20) NOT NULL,

    IsWeekend BOOLEAN NOT NULL
);


CREATE TABLE warehouse.dim_flight (

    FlightKey SERIAL PRIMARY KEY,

    FlightID VARCHAR(20) UNIQUE NOT NULL,

    Route VARCHAR(100) NOT NULL,

    OriginAirportKey INT NOT NULL,

    DestinationAirportKey INT NOT NULL,

    AircraftKey INT NOT NULL,

    Duration INT NOT NULL,

    Distance INT NOT NULL,

    FOREIGN KEY (OriginAirportKey)
        REFERENCES warehouse.dim_airport(AirportKey),

    FOREIGN KEY (DestinationAirportKey)
        REFERENCES warehouse.dim_airport(AirportKey),

    FOREIGN KEY (AircraftKey)
        REFERENCES warehouse.dim_aircraft(AircraftKey)
);


CREATE TABLE warehouse.dim_booking
(
    BookingKey SERIAL PRIMARY KEY,

    BookingID VARCHAR(20) UNIQUE NOT NULL,

    PassengerID VARCHAR(20) NOT NULL,

    FlightID VARCHAR(20) NOT NULL,

    BookingDate TIMESTAMP NOT NULL,

    BookingChannel VARCHAR(50) NOT NULL
);


CREATE TABLE warehouse.fact_passenger_experience
(

    ExperienceKey SERIAL PRIMARY KEY,

    PassengerKey INT NOT NULL,

    FlightKey INT NOT NULL,

    BookingKey INT NOT NULL,

    CabinKey INT NOT NULL,

    DateKey INT NOT NULL,

    Delay INT,

    Fare DECIMAL(10,2),

    AncillaryRevenue DECIMAL(10,2),

    CheckInRating INT,

    BoardingRating INT,

    CrewRating INT,

    SeatComfort INT,

    WiFi INT,

    Entertainment INT,

    Food INT,

    Cleanliness INT,

    BaggageHandling INT,

    NPS INT,

    OverallSatisfaction VARCHAR(20),

    FOREIGN KEY (PassengerKey)
        REFERENCES warehouse.dim_passenger(PassengerKey),

    FOREIGN KEY (FlightKey)
        REFERENCES warehouse.dim_flight(FlightKey),

    FOREIGN KEY (BookingKey)
        REFERENCES warehouse.dim_booking(BookingKey),

    FOREIGN KEY (CabinKey)
        REFERENCES warehouse.dim_cabin(CabinKey),

    FOREIGN KEY (DateKey)
        REFERENCES warehouse.dim_date(DateKey)
);