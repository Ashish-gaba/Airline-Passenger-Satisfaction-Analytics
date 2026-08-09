from pathlib import Path
import pandas as pd


def extract_data(data_path):
    """
    Extract Skyline Airlines raw CSV files.

    Parameters
    ----------
    data_path : str or Path
        Path to the data/raw directory.

    Returns
    -------
    dict
        Dictionary containing the five datasets as DataFrames.
    """

    data_path = Path(data_path)

    files = {
        "passengers": data_path / "passengers.csv",
        "flights": data_path / "flights.csv",
        "bookings": data_path / "bookings.csv",
        "service": data_path / "service.csv",
        "feedback": data_path / "feedback.csv"
    }

    datasets = {}

    for name, file_path in files.items():

        if not file_path.exists():
            raise FileNotFoundError(
                f"Required file not found: {file_path}"
            )

        datasets[name] = pd.read_csv(file_path)

    return datasets


if __name__ == "__main__":

    # Project root → data/raw
    raw_data_path = (
        Path(__file__).resolve().parent.parent / "data"
    )

    datasets = extract_data(raw_data_path)

    print("\nSkyline Airlines - Data Extraction")
    print("=" * 45)

    for name, df in datasets.items():

        print(
            f"{name:<12} : "
            f"{len(df):,} rows × {len(df.columns)} columns"
        )

    print("=" * 45)
    print("Extraction completed successfully.")