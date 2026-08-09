import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


def create_db_engine():
    """
    Create a SQLAlchemy engine using credentials
    stored in the project's .env file.
    """

    project_root = Path(__file__).resolve().parent.parent

    load_dotenv(project_root / ".env")

    db_url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        database=os.getenv("DB_NAME")
    )

    return create_engine(db_url)


def prepare_for_staging(datasets):
    """
    Select only columns that belong to the existing
    PostgreSQL staging tables.

    Analytical features created by transform.py are
    intentionally not loaded into staging yet.
    """

    staging_columns = {

        "passengers": [
            "PassengerID",
            "Age",
            "Gender",
            "CustomerType",
            "LoyaltyTier",
            "TravelType",
            "Country"
        ],

        "flights": [
            "FlightID",
            "Route",
            "Origin",
            "Destination",
            "RouteType",
            "DepartureTime",
            "ArrivalTime",
            "Duration",
            "Distance",
            "Aircraft",
            "Delay"
        ],

        "bookings": [
            "BookingID",
            "PassengerID",
            "FlightID",
            "BookingDate",
            "Fare",
            "CabinClass",
            "BookingChannel",
            "AncillaryRevenue"
        ],

        "service": [
            "BookingID",
            "PassengerID",
            "FlightID",
            "CheckInRating",
            "BoardingRating",
            "CrewRating",
            "SeatComfort",
            "WiFi",
            "Entertainment",
            "Food",
            "Cleanliness",
            "BaggageHandling"
        ],

        "feedback": [
            "BookingID",
            "PassengerID",
            "FlightID",
            "OverallSatisfaction",
            "NPS",
            "Complaint",
            "Review"
        ]
    }

    prepared = {}

    for dataset_name, columns in staging_columns.items():

        prepared[dataset_name] = (
            datasets[dataset_name][columns]
            .copy()
        )

    return prepared


def clear_staging_tables(engine):
    """
    Clear existing staging data before a full refresh.
    """

    truncate_sql = """
    TRUNCATE TABLE
        staging.stg_service,
        staging.stg_feedback,
        staging.stg_bookings,
        staging.stg_flights,
        staging.stg_passengers;
    """

    with engine.begin() as connection:
        connection.execute(text(truncate_sql))


def load_data(datasets, engine):
    """
    Load transformed datasets into PostgreSQL staging tables.
    """

    staging_data = prepare_for_staging(datasets)

    table_mapping = {
        "passengers": "stg_passengers",
        "flights": "stg_flights",
        "bookings": "stg_bookings",
        "service": "stg_service",
        "feedback": "stg_feedback"
    }

    # Full refresh of staging
    clear_staging_tables(engine)

    print("\nLoading data into PostgreSQL staging...")
    print("=" * 50)

    for dataset_name, table_name in table_mapping.items():

        df = staging_data[dataset_name].copy()
        df.columns = df.columns.str.lower()

        df.to_sql(
            name=table_name,
            con=engine,
            schema="staging",
            if_exists="append",
            index=False,
            method="multi"
        )

        print(
            f"{table_name:<20} "
            f"{len(df):,} rows loaded"
        )

    print("=" * 50)
    print("Staging load completed successfully.")


if __name__ == "__main__":

    print("Testing PostgreSQL staging load...")

    from extract import extract_data
    from transform import transform_data

    project_root = Path(__file__).resolve().parent.parent
    data_path = project_root / "data"

    datasets = extract_data(data_path)

    transformed = transform_data(datasets)

    engine = create_db_engine()

    load_data(transformed, engine)