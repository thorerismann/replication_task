import re

import pandas as pd
import numpy as np
from pathlib import Path

def prepare_data():
    # Load the raw Stata data
    df = pd.read_stata(Path.cwd() / "data" / "Database_f.dta")

    # Recoding variables
    schemes_vars = [f"SchemesAwareness_{i}" for i in range(1, 8)]
    adopted_measures_vars = [f"adoptedmeasures_{i}" for i in range(1, 15)]
    df[schemes_vars + adopted_measures_vars] = df[schemes_vars + adopted_measures_vars].replace({2: 0})

    # Generate income
    df["income"] = df["profile_gross_household"].replace({16: np.nan, 17: np.nan})

    # Generate tenure
    df["tenure"] = np.select(
        [
            df["profile_house_tenure"].isin([1, 2, 3]),
            df["profile_house_tenure"].isin([4, 5, 6]),
            df["profile_house_tenure"].isin([7, 8, 9]),
        ],
        [1, 2, 3],
        default=np.nan
    )

    # Generate minor16 and old75
    df["minor16"] = np.where(df["under16sinhousehold"].isin([2, 3, 4, 5, 6]), 1, 0)
    df["old75"] = np.where(df["over75sinhousehold"].isin([2, 3, 4, 5, 6]), 1, 0)

    # Generate hhsize
    df["hhsize"] = df["profile_household_size"].replace({9: np.nan, 10: np.nan})

    # Generate whenbuilt2
    df["whenbuilt2"] = df["whenbuilt"].where(df["whenbuilt"] <= 5, np.nan)

    # Generate awarenessum
    df["awarenessum"] = df[schemes_vars].sum(axis=1)

    # Generate house_type2
    df["house_type2"] = df["house_type"].where(df["house_type"] <= 6, np.nan)

    # Function to fix strings by removing spaces
    def fix_strings(x):
        if isinstance(x, str):  # Check if it's a string
            return x.replace(' ', '').strip().replace('’', '')  # Remove spaces and problematic characters
        return x

    # Apply the fix_strings function to both `EPCrating` and `profile_GOR`
    df['EPCrating'] = df['EPCrating'].apply(fix_strings)
    df['profile_GOR'] = df['profile_GOR'].apply(fix_strings)

    # Recode EPCrating: Replace 'Don’t Know' with 9
    df['EPCrating'] = df['EPCrating'].replace({"Don'tknow": 9})

    # Convert the EPCrating values into numeric categories (1=A*, 2=B, ..., 8=G)
    df['EPCrating'] = df['EPCrating'].replace({
        'A*': 1, 'A': 2, 'B': 3, 'C': 4, 'D': 5, 'E': 6, 'F': 7, 'G': 8
    })


    # Recode profile_GOR with region names
    df['profile_GOR'] = df['profile_GOR'].replace({
        'NorthEast': 1, 'NorthWest': 2, 'YorkshireandtheHumber': 3,
        'EastMidlands': 4, 'WestMidlands': 5, 'EastofEngland': 6,
        'London': 7, 'SouthEast': 8, 'SouthWest': 9, 'Wales': 10, 'Scotland': 11
    })
    # Recode address_change_time categories into numeric values
    df['address_change_time'] = df['address_change_time'].replace({
        '> 10 years': 7,
        '> 5 years & <=10 years': 6,
        '>1 month & <=6 months': 2,
        '<=1 month': 1,
        '>1 year & <=2 years': 4,
        '>6 months & <=12 months': 3,
        '>2 years & <=5 years': 5,
        np.nan: np.nan
    })

    # Generate treated
    df["treated"] = (df[adopted_measures_vars] == 1).any(axis=1).astype(int)

    # Generate treatedsum
    df["treatedsum"] = df[adopted_measures_vars].sum(axis=1)

    # Generate sumlowcost and lowcostdummy
    lowcost_measures = ["adoptedmeasures_1", "adoptedmeasures_2", "adoptedmeasures_3", "adoptedmeasures_12"]
    df["sumlowcost"] = df[lowcost_measures].sum(axis=1)
    df["lowcostdummy"] = (df["sumlowcost"] > 0).astype(int)

    # Generate sumhighcost and highcostdummy
    highcost_measures = [
        "adoptedmeasures_4", "adoptedmeasures_5", "adoptedmeasures_6", "adoptedmeasures_7",
        "adoptedmeasures_8", "adoptedmeasures_9", "adoptedmeasures_10", "adoptedmeasures_11",
        "adoptedmeasures_13", "adoptedmeasures_14"
    ]
    df["sumhighcost"] = df[highcost_measures].sum(axis=1)
    df["highcostdummy"] = (df["sumhighcost"] > 0).astype(int)

    # Generate treatedmulti
    df["treatedmulti"] = np.select(
        [
            (df["lowcostdummy"] == 0) & (df["highcostdummy"] == 0),
            (df["lowcostdummy"] == 1) & (df["highcostdummy"] == 0),
            (df["lowcostdummy"] == 0) & (df["highcostdummy"] == 1),
            (df["lowcostdummy"] == 1) & (df["highcostdummy"] == 1),
        ],
        [0, 1, 2, 3],
        default=np.nan
    )

    # make sure whenbuilt2 is categorical and first categories correspond to same Beta_0 (stata notation ib5 requires 5th category to be the baseline category)

    # Remove NaN values before creating categories
    df = df.dropna(subset=['whenbuilt2', 'EPCrating'], how='any')
    df['whenbuilt2'] = pd.Categorical(df['whenbuilt2'], categories=df['whenbuilt2'].unique(), ordered=False)

    # Reorder categories to put the 5th one at the start (reference category)
    df['whenbuilt2'] = df['whenbuilt2'].cat.reorder_categories(
        df['whenbuilt2'].cat.categories[[4] + list(range(4)) + list(range(5, len(df['whenbuilt2'].cat.categories)))],
        ordered=False
    )

    # make sure epcrating is categorical and first categories correspond to same Beta_0 (stata notation ib9 requires 9th category to be the baseline category)

    df['EPCrating'] = pd.Categorical(df['EPCrating'], categories=df['EPCrating'].unique(), ordered=False)

    # Reorder EPCrating categories to put the 9th one at the start (reference category)
    df['EPCrating'] = df['EPCrating'].cat.reorder_categories(
        df['EPCrating'].cat.categories[[4] + list(range(4)) + list(range(5, len(df['EPCrating'].cat.categories)))],
        ordered=False
    )

    # Ensure the data directory exists
    data_dir = Path.cwd() / 'data'
    data_dir.mkdir(exist_ok=True)

    # Save the transformed dataset
    df.to_csv(data_dir / "transformed_data.csv", index=False)

def extract_labels(file_path: Path) -> dict:
    """
    Extract variable labels from a .do file.

    Parameters:
    file_path (str): Path to the .do file.

    Returns:
    dict: Dictionary of variable labels.
    """
    labels = {}
    with open(file_path, "r") as file:
        for line in file:
            match = re.match(r'label variable (\w+) "(.*)"', line)
            if match:
                variable, label = match.groups()
                labels[variable] = label
    return labels