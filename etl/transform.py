import pandas as pd


def transform_passengers(df):
    """
    Prepare passenger data and create analytical features.
    """

    df = df.copy()

    # Standardize text fields
    text_columns = [
        "Gender",
        "CustomerType",
        "LoyaltyTier",
        "TravelType",
        "Country"
    ]

    for column in text_columns:
        df[column] = df[column].astype("string").str.strip()

    # Standardize Gender
    df["Gender"] = df["Gender"].str.title()

    # Create AgeGroup
    df["AgeGroup"] = pd.cut(
        df["Age"],
        bins=[0, 25, 35, 50, float("inf")],
        labels=["18-25", "26-35", "36-50", "51+"],
        include_lowest=True
    )

    return df


def transform_flights(df):
    """
    Prepare flight data and create operational features.
    """

    df = df.copy()

    # Standardize text
    text_columns = [
        "FlightID",
        "Route",
        "Origin",
        "Destination",
        "RouteType",
        "Aircraft"
    ]

    for column in text_columns:
        df[column] = df[column].astype("string").str.strip()

    df["Origin"] = df["Origin"].str.upper()
    df["Destination"] = df["Destination"].str.upper()
    df["RouteType"] = df["RouteType"].str.title()

    # Convert timestamps
    df["DepartureTime"] = pd.to_datetime(
        df["DepartureTime"],
        dayfirst=True,
        errors="coerce"
    )

    df["ArrivalTime"] = pd.to_datetime(
        df["ArrivalTime"],
        dayfirst=True,
        errors="coerce"
    )

    # Delay category
    df["DelayCategory"] = pd.cut(
        df["Delay"],
        bins=[-float("inf"), 0, 15, 60, 180, float("inf")],
        labels=[
            "Early",
            "On Time",
            "Minor Delay",
            "Major Delay",
            "Severe Delay"
        ],
        include_lowest=True
    )

    # Flight duration category
    df["FlightDurationCategory"] = pd.cut(
        df["Duration"],
        bins=[0, 120, 240, 360, float("inf")],
        labels=[
            "Short Haul",
            "Medium Haul",
            "Long Haul",
            "Ultra Long Haul"
        ],
        include_lowest=True
    )

    # Long-haul flag
    df["LongHaul"] = df["Duration"] >= 240

    return df


def transform_bookings(df):
    """
    Prepare booking data and create revenue features.
    """

    df = df.copy()

    text_columns = [
        "BookingID",
        "PassengerID",
        "FlightID",
        "CabinClass",
        "BookingChannel"
    ]

    for column in text_columns:
        df[column] = df[column].astype("string").str.strip()

    df["CabinClass"] = df["CabinClass"].str.title()
    df["BookingChannel"] = df["BookingChannel"].str.title()

    # Convert booking date
    df["BookingDate"] = pd.to_datetime(
        df["BookingDate"],
        dayfirst=True,
        errors="coerce"
    )

    # Fare bands
    df["FareBand"] = pd.cut(
        df["Fare"],
        bins=[0, 5000, 10000, 25000, float("inf")],
        labels=[
            "Low",
            "Medium",
            "High",
            "Premium"
        ],
        include_lowest=True
    )

    # High-value customer indicator
    df["HighValueCustomer"] = (
        df["Fare"] + df["AncillaryRevenue"]
    ) >= 25000

    return df


def transform_service(df):
    """
    Standardize service data and prepare rating features.
    """

    df = df.copy()

    text_columns = [
        "BookingID",
        "PassengerID",
        "FlightID"
    ]

    for column in text_columns:
        df[column] = df[column].astype("string").str.strip()

    rating_columns = [
        "CheckInRating",
        "BoardingRating",
        "CrewRating",
        "SeatComfort",
        "WiFi",
        "Entertainment",
        "Food",
        "Cleanliness",
        "BaggageHandling"
    ]

    # Ensure ratings are numeric
    for column in rating_columns:
        df[column] = pd.to_numeric(
            df[column],
            errors="coerce"
        )

    # Overall service score
    df["AverageServiceRating"] = (
        df[rating_columns]
        .mean(axis=1)
        .round(2)
    )

    return df


def transform_feedback(df):
    """
    Standardize feedback and satisfaction fields.
    """

    df = df.copy()

    text_columns = [
        "BookingID",
        "PassengerID",
        "FlightID",
        "OverallSatisfaction",
        "Complaint",
        "Review"
    ]

    for column in text_columns:
        df[column] = df[column].astype("string").str.strip()

    df["OverallSatisfaction"] = (
        df["OverallSatisfaction"]
        .str.title()
    )

    df["Complaint"] = (
        df["Complaint"]
        .fillna("None")
        .str.strip()
    )

    df["NPS"] = pd.to_numeric(
        df["NPS"],
        errors="coerce"
    )

    # Promoter / Passive / Detractor classification
    df["NPSCategory"] = pd.cut(
        df["NPS"],
        bins=[-1, 6, 8, 10],
        labels=[
            "Detractor",
            "Passive",
            "Promoter"
        ]
    )

    return df


def transform_data(datasets):
    """
    Transform all extracted Skyline Airlines datasets.
    """

    transformed = {}

    transformed["passengers"] = transform_passengers(
        datasets["passengers"]
    )

    transformed["flights"] = transform_flights(
        datasets["flights"]
    )

    transformed["bookings"] = transform_bookings(
        datasets["bookings"]
    )

    transformed["service"] = transform_service(
        datasets["service"]
    )

    transformed["feedback"] = transform_feedback(
        datasets["feedback"]
    )

    return transformed

if __name__ == "__main__":

    from pathlib import Path
    from extract import extract_data

    raw_data_path = (
        Path(__file__).resolve().parent.parent
        / "data"
    )

    datasets = extract_data(raw_data_path)

    transformed = transform_data(datasets)

    print("\nTransformation completed successfully.")
    print("=" * 50)

    for name, df in transformed.items():
        print(
            f"{name:<12} : "
            f"{len(df):,} rows × {len(df.columns)} columns"
        )

    print("\nNew analytical columns:")

    print(
        "Passengers:",
        [
            c for c in transformed["passengers"].columns
            if c not in datasets["passengers"].columns
        ]
    )

    print(
        "Flights:",
        [
            c for c in transformed["flights"].columns
            if c not in datasets["flights"].columns
        ]
    )

    print(
        "Bookings:",
        [
            c for c in transformed["bookings"].columns
            if c not in datasets["bookings"].columns
        ]
    )

    print(
        "Service:",
        [
            c for c in transformed["service"].columns
            if c not in datasets["service"].columns
        ]
    )

    print(
        "Feedback:",
        [
            c for c in transformed["feedback"].columns
            if c not in datasets["feedback"].columns
        ]
    )