import matplotlib.pyplot as plt
import seaborn as sns
def generate_descriptive_stats(df, output_path):
    """
    Generate descriptive statistics, print them to the console, and save as a table image.

    Parameters:
    df (pd.DataFrame): Dataframe containing the variables.
    output_path (str or Path): Path where the table image will be saved.

    Returns:
    pd.DataFrame: Dataframe containing descriptive statistics.
    """
    # Updated columns dictionary to include all relevant variables
    columns = {
        "treated": "EE installed (any)",
        "lowcostdummy": "Low-cost EE installed",
        "highcostdummy": "High-cost EE installed",
        "whenbuilt2": "Age dwelling",
        "squarefootage": "Surface",
        "bedrooms": "Bedrooms",
        "hhsize": "Size",
        "tenure": "Tenure",
        "house_type2": "Type housing",
        "EPCrating": "EPC",
        "address_change_time": "Move date",
        "old75": "People >75",
        "minor16": "People <16",
        "profile_GOR": "Region",  # Include Region
        "income": "Income",
        "awarenessum": "Awareness",
        "AdoptionLikelihood_1": "Tax credits pref.",
        "AdoptionLikelihood_2": "Loan pref.",
        "AdoptionLikelihood_3": "Grant pref.",
        "AdoptionLikelihood_4": "Admin barrier pref.",
        "AdoptionLikelihood_5": "Utilities pref.",
        "CircumstancesLikelihood_1": "Info. Efficient use pref.",
        "CircumstancesLikelihood_2": "Info. Potential savings pref.",
        "CircumstancesLikelihood_3": "Info. Support schemes pref.",
        "CircumstancesLikelihood_4": "Higher EE standards pref.",
        "CircumstancesLikelihood_5": "Stronger EE standards pref.",
    }

    # Filter dataframe and rename columns
    filtered_df = df[list(columns.keys())].rename(columns=columns)
    print(columns.keys())
    print(df.columns)

    # Calculate descriptive statistics
    descriptive_stats = filtered_df.describe().transpose()
    descriptive_stats["Obs"] = filtered_df.notna().sum()
    descriptive_stats = descriptive_stats[["Obs", "mean", "std", "min", "max"]]
    descriptive_stats.columns = ["Obs", "Mean", "Std. Dev.", "Min", "Max"]

    # Print the stats to console
    print("Descriptive Statistics:")
    print(descriptive_stats)
    descriptive_stats.reset_index().to_csv(output_path.with_suffix('.csv'), index=False)

    # Plot the table with matplotlib
    fig, ax = plt.subplots(figsize=(10, len(descriptive_stats) * 0.5 + 1))
    ax.axis("off")
    table = plt.table(
        cellText=descriptive_stats.round(2).values,
        colLabels=descriptive_stats.columns,
        rowLabels=descriptive_stats.index,
        loc="center",
    )

    # Adjust table styling
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.auto_set_column_width(col=list(range(len(descriptive_stats.columns))))

    # Save the image
    output_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    print(f"Descriptive statistics table saved to {output_path}")
    return descriptive_stats




def plot_energy_measures(df, output_path):
    """
    Generate a grid of bar charts for binary energy efficiency measures.

    Parameters:
    df (pd.DataFrame): Dataframe containing the binary measures.
    output_path (str or Path): Path to save the output PNG image.

    Returns:
    None
    """
    # Define the measures and their corresponding labels
    measures = [
        "adoptedmeasures_2", "adoptedmeasures_5", "adoptedmeasures_3", "adoptedmeasures_4",
        "adoptedmeasures_13", "adoptedmeasures_11", "adoptedmeasures_1", "adoptedmeasures_7",
        "adoptedmeasures_12", "adoptedmeasures_10", "adoptedmeasures_9", "adoptedmeasures_8"
    ]
    labels = [
        "Cavity walls", "Central heating controls", "Hot water cylinder", "Cylinder thermostat",
        "Double glazing", "Heat pump", "Loft insulation", "Central heating boiler",
        "In-home energy display / Smart meter", "Solar PV", "Storage radiators", "Warm air heating units"
    ]

    # Create the figure and axes for subplots
    fig, axes = plt.subplots(3, 4, figsize=(12, 9), constrained_layout=True)
    axes = axes.ravel()

    # Loop over each measure and create the bar plot
    for idx, (measure, label) in enumerate(zip(measures, labels)):
        # Count "Yes" (1) and "No" (0) responses
        counts = df[measure].value_counts().sort_index()
        counts.index = ["No", "Yes"]  # Map 0/1 to "No"/"Yes"

        # Bar plot
        axes[idx].bar(counts.index, counts.values, color="gray", edgecolor="black")
        axes[idx].set_title(label, fontsize=10)
        axes[idx].set_ylim(0, 2000)
        axes[idx].tick_params(axis="x", labelrotation=0)

    # Turn off any unused subplot axes
    for idx in range(len(measures), len(axes)):
        axes[idx].axis("off")

    # Save and show the figure
    output_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path, dpi=300)
    plt.show()
    print(f"Bar chart saved to {output_path}")


def plot_policy_awareness(df, output_path):
    """
    Generate a grid of bar charts for binary policy awareness measures.

    Parameters:
    df (pd.DataFrame): Dataframe containing the binary awareness measures.
    output_path (str or Path): Path to save the output PNG image.

    Returns:
    None
    """
    # Define the measures and their corresponding labels
    measures = [
        "SchemesAwareness_1", "SchemesAwareness_2", "SchemesAwareness_3",
        "SchemesAwareness_4", "SchemesAwareness_5", "SchemesAwareness_6", "SchemesAwareness_7"
    ]
    labels = [
        "CERT", "CESP", "ECO", "EEC1 / EEC2", "Green Home Grants", "Green Deal", "Other"
    ]

    # Create the figure and axes for subplots
    fig, axes = plt.subplots(2, 4, figsize=(12, 6), constrained_layout=True)
    axes = axes.ravel()

    # Loop over each measure and create the bar plot
    for idx, (measure, label) in enumerate(zip(measures, labels)):
        if idx >= len(axes):  # Skip extra subplots
            break

        # Count "Yes" (1) and "No" (0) responses
        counts = df[measure].value_counts().sort_index()
        counts.index = ["No", "Yes"]  # Map 0/1 to "No"/"Yes"

        # Bar plot
        axes[idx].bar(counts.index, counts.values, color="gray", edgecolor="black")
        axes[idx].set_title(label, fontsize=10)
        axes[idx].set_ylim(0, 2000)
        axes[idx].tick_params(axis="x", labelrotation=0)

    # Turn off any unused subplot axes
    for idx in range(len(measures), len(axes)):
        axes[idx].axis("off")

    # Save and show the figure
    output_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path, dpi=300)
    plt.show()
    print(f"Policy awareness plot saved to {output_path}")


def corr_plot(df, outputpath):
    """
    Create the correlation plot in Appendix table A1
    """

    corrdf = df[['treated', 'lowcostdummy', 'highcostdummy', 'AdoptionLikelihood_1', 'AdoptionLikelihood_2',
 'AdoptionLikelihood_3', 'AdoptionLikelihood_4', 'AdoptionLikelihood_5',
 'CircumstancesLikelihood_1', 'CircumstancesLikelihood_2', 'CircumstancesLikelihood_3',
 'CircumstancesLikelihood_4', 'CircumstancesLikelihood_5', 'awarenessum', 'house_type2',
 'tenure', 'whenbuilt2', 'squarefootage', 'bedrooms', 'hhsize', 'income', 'old75', 'minor16', 'address_change_time', 'EPCrating', 'profile_GOR']]
    # Compute the correlation matrix
    corr_matrix = corrdf.corr()

    # Plot a heatmap of the correlation matrix
    plt.figure(figsize=(12, 8))
    sns.heatmap(corr_matrix, cmap='coolwarm', vmin=-1, vmax=1)
    plt.title("Correlation Matrix Heatmap")
    plt.tight_layout()
    plt.savefig(outputpath)
    plt.show()

    # save to .csv
    corr_matrix.reset_index().to_csv(outputpath.with_suffix('.csv'), index=False)
