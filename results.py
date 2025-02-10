import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import re
from pathlib import Path
import seaborn as sns

def run_regression(df, output_path_main, output_path_annex, output_path_diag, labels):
    """
    Run logit, cloglog, and poisson regressions with marginal effects, and create diagnostics using labels from a .do file.

    Parameters:
    df (pd.DataFrame): The dataset with relevant variables.
    output_path_main (str or Path): Path to save the main table (marginal effects).
    output_path_diag (str or Path): Path to save the diagnostics table.
    labels_path (str): Path to the .do file containing variable labels.

    Returns:
    pd.DataFrame: A summary table of marginal effects and diagnostics.
    """

    # Define the dependent variable and independent variables
    y = "treated"

    x_vars = [
        "AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3",
        "AdoptionLikelihood_4", "AdoptionLikelihood_5", "CircumstancesLikelihood_1",
        "CircumstancesLikelihood_2", "CircumstancesLikelihood_3", "CircumstancesLikelihood_4",
        "CircumstancesLikelihood_5", "awarenessum", "C(tenure)", "C(whenbuilt2)", "C(house_type2)",
        "squarefootage", "bedrooms", "hhsize", "income", "old75", "minor16", "C(address_change_time)",
        "C(EPCrating)", "C(profile_GOR)"
    ]
    formula = f"{y} ~ {' + '.join(x_vars)}"

    # Run logit model
    logit_model = smf.logit(formula, weights=df['Weight'], data=df).fit(cov_type='HC0')
    logit_mfx = logit_model.get_margeff(at='mean', method='dydx')
    logit_coef = logit_model.params
    logit_se = logit_model.bse

    # Run cloglog model
    cloglog_model = smf.glm(formula, weights=df['Weight'], data=df, family=sm.families.Binomial(sm.families.links.cloglog())).fit(cov_type='HC0')
    cloglog_mfx = cloglog_model.get_margeff(at='mean', method='dydx')
    cloglog_coef = cloglog_model.params
    cloglog_se = cloglog_model.bse

    # Run poisson model
    poisson_model = smf.poisson(formula, freq_weights=df['Weight'], data=df).fit(cov_type='HC0')
    poisson_mfx = poisson_model.get_margeff(at='mean', method='dydx')
    poisson_coef = poisson_model.params
    poisson_se = poisson_model.bse

    # Calculate pseudo R² for cloglog manually
    cloglog_pseudo_r2 = 1 - (cloglog_model.llf / cloglog_model.llnull)

    # Extract variable names dynamically from one of the models
    var_names = logit_mfx.summary_frame().index.tolist()

    # Map variable names to labels using the extracted labels
    labeled_var_names = [labels.get(var, var) for var in var_names]

    # Create the results DataFrame (Table 3 text)
    rdm = pd.DataFrame({
        "Variable": labeled_var_names,
        "Logit Marginal Effect": logit_mfx.margeff,
        "Logit SE": logit_mfx.margeff_se,
        "Cloglog Marginal Effect": cloglog_mfx.margeff,
        "Cloglog SE": cloglog_mfx.margeff_se,
        "Poisson Marginal Effect": poisson_mfx.margeff,
        "Poisson SE": poisson_mfx.margeff_se
    })

    rdm['Lower CI Cloglog'] = rdm['Cloglog Marginal Effect'] - 1.96 * rdm['Cloglog SE']
    rdm['Upper CI Cloglog'] = rdm['Cloglog Marginal Effect'] + 1.96 * rdm['Cloglog SE']
    rdm['Lower CI Logit'] = rdm['Logit Marginal Effect'] - 1.96 * rdm['Logit SE']
    rdm['Upper CI Logit'] = rdm['Logit Marginal Effect'] + 1.96 * rdm['Logit SE']

    rdm['result cloglog'] = ((rdm['Lower CI Cloglog'] > 0) & (rdm['Upper CI Cloglog'] > 0)) | (
                (rdm['Lower CI Cloglog'] < 0) & (rdm['Upper CI Cloglog'] < 0))
    rdm['result logit'] = ((rdm['Lower CI Logit'] > 0) & (rdm['Upper CI Logit'] > 0)) | (
                (rdm['Lower CI Logit'] < 0) & (rdm['Upper CI Logit'] < 0))

    # Create the coeffecient results DataFrame (Table 3 appendix)
    results_df_coeff = pd.DataFrame({
        "Variable": logit_coef.index,
        "Logit Coefficient": logit_coef,
        "Logit SE": logit_se,
        "Cloglog Coefficient": cloglog_coef,
        "Cloglog SE": cloglog_se,
        "Poisson Coefficient": poisson_coef,
        "Poisson SE": poisson_se
    })

    rdm.reset_index().to_csv(output_path_main.with_suffix('.csv'), index=False)
    results_df_coeff.reset_index().to_csv(output_path_annex.with_suffix('.csv'), index=False)

    # Create the diagnostics DataFrame
    diagnostics = pd.DataFrame({
        "Statistic": ["N", "Pseudo R²", "AIC", "BIC"],
        "Logit": [logit_model.nobs, logit_model.prsquared, logit_model.aic, logit_model.bic],
        "Cloglog": [cloglog_model.nobs, cloglog_pseudo_r2, cloglog_model.aic, cloglog_model.bic],
        "Poisson": [poisson_model.nobs, None, poisson_model.aic, poisson_model.bic]
    })

    # Save results as an image using matplotlib
    fig, ax = plt.subplots(figsize=(12, len(rdm) * 0.5 + 1))
    ax.axis("off")
    table = plt.table(
        cellText=rdm.round(3).values,
        colLabels=rdm.columns,
        loc="center",
        cellLoc="center",
    )
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.auto_set_column_width(col=list(range(len(rdm.columns))))

    output_path_main.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path_main, dpi=300, bbox_inches="tight")
    plt.close(fig)

    rdm.reset_index().to_csv(output_path_main.with_suffix('.csv'), index=False)

    # Save the diagnostics as a separate table
    fig_diag, ax_diag = plt.subplots(figsize=(8, 2))
    ax_diag.axis("off")
    table_diag = plt.table(
        cellText=diagnostics.round(3).values,
        colLabels=diagnostics.columns,
        loc="center",
        cellLoc="center",
    )
    table_diag.auto_set_font_size(False)
    table_diag.set_fontsize(10)
    table_diag.auto_set_column_width(col=list(range(len(diagnostics.columns))))

    plt.savefig(output_path_diag, dpi=300, bbox_inches="tight")
    plt.close(fig_diag)

    print(f"Table saved to {output_path_main}")
    print(f"Diagnostics saved to {output_path_diag}")

    return rdm

def plot_odds_ratios(results_df, output_path):
    """
    Generate an odds ratio plot with confidence intervals for the cloglog model.

    Parameters:
    results_df (pd.DataFrame): A DataFrame containing variables, coefficients, and standard errors.
    output_path (str or Path): Path to save the plot as an image.

    Returns:
    None
    """
    # Filter results for cloglog and policy variables
    plot_data = results_df[~results_df["Variable"].str.contains("Intercept|C\\(")]  # Exclude intercept and dummies

    # Convert cloglog marginal effects into odds ratios
    cloglog_effects = plot_data["Cloglog Marginal Effect"]
    cloglog_odds_ratios = cloglog_effects.apply(lambda x: 1 + x)
    cloglog_lower = cloglog_odds_ratios - 1.96 * plot_data["Cloglog SE"]
    cloglog_upper = cloglog_odds_ratios + 1.96 * plot_data["Cloglog SE"]

    # Add significance stars based on the p-value thresholds
    significance_stars = []
    for _, row in plot_data.iterrows():
        if abs(row["Cloglog Marginal Effect"] / row["Cloglog SE"]) > 2.576:  # p < 0.01
            significance_stars.append("***")
        elif abs(row["Cloglog Marginal Effect"] / row["Cloglog SE"]) > 1.960:  # p < 0.05
            significance_stars.append("**")
        elif abs(row["Cloglog Marginal Effect"] / row["Cloglog SE"]) > 1.645:  # p < 0.10
            significance_stars.append("*")
        else:
            significance_stars.append("")

    # Combine variable names with significance stars
    variables_with_stars = [
        f"{var} {star}" for var, star in zip(plot_data["Variable"], significance_stars)
    ]

    # Plot settings
    fig, ax = plt.subplots(figsize=(8, len(variables_with_stars) * 0.5))
    ax.errorbar(
        cloglog_odds_ratios,  # Odds ratios
        variables_with_stars,  # Variable names with stars
        xerr=[
            cloglog_odds_ratios - cloglog_lower,
            cloglog_upper - cloglog_odds_ratios
        ],  # Confidence intervals
        fmt="o",  # Point markers
        color="black",  # Marker color
        ecolor="black",  # Error bar color
        capsize=3  # Caps at ends of error bars
    )

    # Add a vertical dashed line at 1 (no effect)
    ax.axvline(x=1, linestyle="--", color="red", linewidth=1)

    # Label axes and set style
    ax.set_xlabel("Odds Ratio")
    ax.set_title("Odds Ratios for Policy Drivers (Cloglog Model)")
    plt.tight_layout()

    # Save the plot
    plt.savefig(output_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    print(f"Odds ratio plot saved to {output_path}")


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

def run_regressions_high_low(
    df: pd.DataFrame, labels: dict, output_path_main: Path, output_path_annex: Path, output_path_diag: Path
) -> pd.DataFrame:
    """
    Run cloglog and logit regressions for low-cost and high-cost measures, calculate marginal effects,
    and generate diagnostic tables.

    Parameters:
    df (pd.DataFrame): Dataset.
    labels (dict): Dictionary of variable labels.
    output_path_main (str): Path to save the main results table.
    output_path_diag (str): Path to save diagnostics.

    Returns:
    tuple: Marginal effects results (DataFrame), diagnostics (DataFrame).
    """
    # Define predictors and formulas
    predictors = [
        "AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3",
        "AdoptionLikelihood_4", "AdoptionLikelihood_5", "CircumstancesLikelihood_1",
        "CircumstancesLikelihood_2", "CircumstancesLikelihood_3", "CircumstancesLikelihood_4",
        "CircumstancesLikelihood_5", "awarenessum", "C(tenure)", "C(whenbuilt2)",
        "squarefootage", "bedrooms", "hhsize", "old75", "minor16", "income",
        "C(address_change_time)", "C(EPCrating)", "C(profile_GOR)"
    ]
    formula_low = f"lowcostdummy ~ {' + '.join(predictors)}"
    formula_high = f"highcostdummy ~ {' + '.join(predictors)}"

    results_marginal = {}
    results_coeff = {}
    diagnostics = []

    # Run regressions for low-cost and high-cost models
    for model_name, formula in [("Low-cost", formula_low), ("High-cost", formula_high)]:
        for link_name, link in [("Cloglog", sm.families.links.CLogLog()), ("Logit", sm.families.links.logit())]:
            model = smf.glm(formula, data=df, family=sm.families.Binomial(link)).fit()
            mfx = model.get_margeff(at="mean", method="dydx")
            # Store results and diagnostics
            results_marginal[(model_name, link_name)] = mfx.summary_frame()
            results_coeff[(model_name, link_name)] = model.summary2().tables[1]
            pseudo_r2 = 1 - (model.llf / model.llnull)
            diagnostics.append(
                {
                    "Model": f"{model_name} ({link_name})",
                    "N": model.nobs,
                    "pR2": pseudo_r2,
                    "AIC": model.aic,
                    "BIC": model.bic,
                }
            )

    # Combine results and reset index
    results_df = pd.concat(results_marginal, names=["Measure Type", "Link"]).reset_index().rename(columns={"level_2": "Variable"})
    results_df_coeff = pd.concat(results_coeff, names=["Measure Type", "Link"]).reset_index().rename(columns={"level_2": "Variable"})


    # Map variable names to labels using labels dictionary
    results_df["Variable"] = results_df["Variable"].map(labels)
    results_df_coeff['Variable'] = results_df_coeff['Variable'].map(labels)
    diagnostics_df = pd.DataFrame(diagnostics)

    # Save results and diagnostics
    results_df.to_csv(output_path_main, index=False)
    results_df_coeff.to_csv(output_path_annex, index=False)
    diagnostics_df.to_csv(output_path_diag, index=False)

    print(f"Results saved to {output_path_main}")
    print(f"Diagnostics saved to {output_path_diag}")

    return results_df

def plot_odds_ratios_by_type(results_df: pd.DataFrame, output_dir: str):
    """
    Generate four separate odds ratio plots with confidence intervals:
    - Low-cost (Cloglog)
    - Low-cost (Logit)
    - High-cost (Cloglog)
    - High-cost (Logit)

    Parameters:
    results_df (pd.DataFrame): DataFrame containing regression results.
    output_dir (str): Directory to save the four plots.

    Returns:
    None
    """
    # Ensure Variable column is string and drop NaNs
    results_df = results_df.dropna(subset=["Variable"]).copy()
    results_df["Variable"] = results_df["Variable"].astype(str)

    # Filter out intercepts and categorical dummies
    results_df = results_df[~results_df["Variable"].str.contains(r"Intercept|C\(", regex=True, na=False)]

    # Convert marginal effects into odds ratios
    results_df["Odds Ratio"] = 1 + results_df["dy/dx"]
    results_df["Lower CI"] = results_df["Odds Ratio"] - 1.96 * results_df["Std. Err."]
    results_df["Upper CI"] = results_df["Odds Ratio"] + 1.96 * results_df["Std. Err."]

    # Drop rows with NaN in key plotting columns
    results_df = results_df.dropna(subset=["Odds Ratio", "Lower CI", "Upper CI", "Variable"])

    # Add significance stars based on p-value thresholds
    def get_significance_stars(z_value):
        if abs(z_value) > 2.576:
            return "***"  # p < 0.01
        elif abs(z_value) > 1.960:
            return "**"  # p < 0.05
        elif abs(z_value) > 1.645:
            return "*"  # p < 0.10
        return ""

    results_df["Significance"] = results_df["dy/dx"] / results_df["Std. Err."]
    results_df["Variable"] = results_df.apply(lambda row: f"{row['Variable']} {get_significance_stars(row['Significance'])}", axis=1)

    # Final check: Drop any remaining NaNs
    results_df = results_df.dropna(subset=["Variable"])

    # Define subplots for the four models
    model_types = [
        ("Low-cost", "Cloglog"),
        ("Low-cost", "Logit"),
        ("High-cost", "Cloglog"),
        ("High-cost", "Logit"),
    ]

    for measure_type, link in model_types:
        subset = results_df[(results_df["Measure Type"] == measure_type) & (results_df["Link"] == link)]

        # Skip empty models
        if subset.empty:
            print(f"Skipping {measure_type} ({link}) - No data.")
            continue

        # Drop any residual NaNs
        subset = subset.dropna(subset=["Odds Ratio", "Lower CI", "Upper CI", "Variable"])

        # Create plot
        fig, ax = plt.subplots(figsize=(8, len(subset) * 0.5))
        ax.errorbar(
            subset["Odds Ratio"],
            subset["Variable"],
            xerr=[subset["Odds Ratio"] - subset["Lower CI"], subset["Upper CI"] - subset["Odds Ratio"]],
            fmt="o",
            color="black",
            ecolor="black",
            capsize=3,
        )

        # Add vertical line for reference at OR = 1
        ax.axvline(x=1, linestyle="--", color="red", linewidth=1)

        # Labels and title
        ax.set_xlabel("Odds Ratio")
        ax.set_title(f"Odds Ratios for {measure_type} ({link})")

        # Save figure
        plot_path = f"{output_dir}/{measure_type.lower()}_{link.lower()}_odds_ratios.png"
        plt.tight_layout()
        plt.savefig(plot_path, dpi=300, bbox_inches="tight")
        plt.close(fig)

        print(f"Saved plot: {plot_path}")

def run_multinomial_logit(
        df: pd.DataFrame, labels: dict, output_path_main: Path, output_path_diag: Path
) -> pd.DataFrame:
    """
    Run multinomial logit regression for classification (low, high, and low & high EE measures),
    calculate coefficients and marginal effects, and generate diagnostic tables.

    Parameters:
    df (pd.DataFrame): Dataset.
    labels (dict): Dictionary of variable labels.
    output_path_main (str): Path to save the main results table (coefficients).
    output_path_diag (str): Path to save diagnostics.

    Returns:
    tuple: Coefficients results (DataFrame), diagnostics (DataFrame).
    """
    # Define predictors and formulas
    predictors = [
        "AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3",
        "AdoptionLikelihood_4", "AdoptionLikelihood_5", "CircumstancesLikelihood_1",
        "CircumstancesLikelihood_2", "CircumstancesLikelihood_3", "CircumstancesLikelihood_4",
        "CircumstancesLikelihood_5", "awarenessum", "C(tenure)", "C(whenbuilt2)",
        "squarefootage", "bedrooms", "hhsize", "old75", "minor16", "income",
        "C(address_change_time)", "C(EPCrating)", "C(profile_GOR)"
    ]
    formula = f"treatedmulti ~ {' + '.join(predictors)}"

    # Fit the multinomial logit model
    mnl_model = smf.mnlogit(formula, data=df, weights=df.Weight).fit()

    # Get the summary of coefficients for each category
    results_df = mnl_model.summary2().tables[1]

    # Diagnostics - Pseudo R², AIC, BIC
    pseudo_r2 = 1 - (mnl_model.llf / mnl_model.llnull)
    diagnostics = {
        "Model": "Multinomial Logit",
        "N": mnl_model.nobs,
        "Pseudo R²": pseudo_r2,
        "AIC": mnl_model.aic,
        "BIC": mnl_model.bic,
    }

    diagnostics_df = pd.DataFrame([diagnostics])

    # Map variable names to labels using the labels dictionary
    results_df.index.name = 'Variable'
    results_df.reset_index(inplace=True)
    results_df["Variable"] = results_df.Variable.map(labels)

    # Save results and diagnostics to files
    results_df.to_csv(output_path_main.with_suffix('.csv'), index=True)
    diagnostics_df.to_csv(output_path_diag.with_suffix('.csv'), index=False)

    # Plot the results (optional)
    fig, ax = plt.subplots(figsize=(12, len(results_df) * 0.5 + 1))
    ax.axis("off")
    table = plt.table(
        cellText=results_df.round(3).values,
        colLabels=results_df.columns,
        loc="center",
        cellLoc="center",
    )
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.auto_set_column_width(col=list(range(len(results_df.columns))))
    plt.savefig(output_path_main, dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Save diagnostics table
    fig_diag, ax_diag = plt.subplots(figsize=(8, 2))
    ax_diag.axis("off")
    table_diag = plt.table(
        cellText=diagnostics_df.round(3).values,
        colLabels=diagnostics_df.columns,
        loc="center",
        cellLoc="center",
    )
    table_diag.auto_set_font_size(False)
    table_diag.set_fontsize(10)
    table_diag.auto_set_column_width(col=list(range(len(diagnostics_df.columns))))
    plt.savefig(output_path_diag, dpi=300, bbox_inches="tight")
    plt.close(fig_diag)

    print(f"Results saved to {output_path_main}")
    print(f"Diagnostics saved to {output_path_diag}")

    return results_df, diagnostics_df