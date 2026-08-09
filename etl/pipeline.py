from pathlib import Path

from extract import extract_data
from transform import transform_data
from load import create_db_engine, load_data


def run_pipeline():

    print("\n")
    print("=" * 60)
    print("SKYLINE AIRLINES ETL PIPELINE")
    print("=" * 60)

    # ---------------------------------------------------------
    # 1. Determine project paths
    # ---------------------------------------------------------

    project_root = Path(__file__).resolve().parent.parent

    data_path = project_root / "data"

    # ---------------------------------------------------------
    # 2. Extract
    # ---------------------------------------------------------

    print("\n[1/3] Extracting raw data...")

    datasets = extract_data(data_path)

    for name, df in datasets.items():

        print(
            f"  {name:<12}: "
            f"{len(df):,} rows"
        )

    # ---------------------------------------------------------
    # 3. Transform
    # ---------------------------------------------------------

    print("\n[2/3] Transforming data...")

    transformed_data = transform_data(datasets)

    print("  Transformation completed.")

    # ---------------------------------------------------------
    # 4. Load
    # ---------------------------------------------------------

    print("\n[3/3] Loading data into PostgreSQL...")

    engine = create_db_engine()

    load_data(
        transformed_data,
        engine
    )

    # ---------------------------------------------------------
    # Complete
    # ---------------------------------------------------------

    print("\n")
    print("=" * 60)
    print("ETL PIPELINE COMPLETED SUCCESSFULLY")
    print("=" * 60)


if __name__ == "__main__":

    try:

        run_pipeline()

    except Exception as error:

        print("\n")
        print("=" * 60)
        print("ETL PIPELINE FAILED")
        print("=" * 60)
        print(f"Error: {error}")

        raise