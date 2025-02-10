import pandas as pd
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
from pathlib import Path
import statsmodels.api as sm
import numpy as np
from statsmodels.stats.outliers_influence import variance_inflation_factor


def run_policy_interactions_logit(df: pd.DataFrame, labels: dict, output_path_main: Path, output_path_diag: Path) -> pd.DataFrame:
    """
    Run logit regression for policy interactions, calculate marginal effects,
    and generate diagnostics for policy mixes. Interaction terms are specified using *.

    Parameters:
    df (pd.DataFrame): The dataset with relevant variables.
    labels (dict): Dictionary of variable labels.
    output_path_main (str): Path to save the main results table.
    output_path_diag (str): Path to save diagnostics.

    Returns:
    pd.DataFrame: A summary table of marginal effects and diagnostics.
    """
    # Define the predictors with interaction terms
    predictors = [
        "AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3",
        "AdoptionLikelihood_4", "AdoptionLikelihood_5", "CircumstancesLikelihood_1",
        "CircumstancesLikelihood_2", "CircumstancesLikelihood_3", "CircumstancesLikelihood_4",
        "CircumstancesLikelihood_5", "awarenessum", "C(tenure)", "C(whenbuilt2)",
        "squarefootage", "bedrooms", "hhsize", "old75", "minor16", "income",
        "C(address_change_time)", "C(EPCrating)", "C(profile_GOR)",
        "AdoptionLikelihood_1*C(CircumstancesLikelihood_2)", "AdoptionLikelihood_2*C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_3*C(CircumstancesLikelihood_2)", "AdoptionLikelihood_4*C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_5*C(CircumstancesLikelihood_2)", "AdoptionLikelihood_1*C(CircumstancesLikelihood_3)",
        "AdoptionLikelihood_2*C(CircumstancesLikelihood_3)", "AdoptionLikelihood_3*C(CircumstancesLikelihood_3)"
    ]
    formula = f"treated ~ {' + '.join(predictors)}"

    # Run logit model
    logit_model = smf.logit(formula, data=df).fit(cov_type='HC0')
    logit_mfx = logit_model.get_margeff(at='mean', method='dydx')

    # Extract variable names dynamically from the logit model
    var_names = logit_mfx.summary_frame().index.tolist()

    # Map variable names to labels using the extracted labels
    labeled_var_names = [labels.get(var, var) for var in var_names]

    # Create the results DataFrame
    results_df = pd.DataFrame({
        "Variable": labeled_var_names,
        "Logit Marginal Effect": logit_mfx.margeff,
        "Logit SE": logit_mfx.margeff_se
    })

    # Diagnostics (Logit specific)
    diagnostics = pd.DataFrame({
        "Statistic": ["N", "Pseudo R²", "AIC", "BIC"],
        "Logit": [logit_model.nobs, logit_model.prsquared, logit_model.aic, logit_model.bic]
    })

    # Save results as an image using matplotlib
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

    output_path_main.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path_main, dpi=300, bbox_inches="tight")
    plt.close(fig)

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

    return results_df


def run_policy_interactions_cloglog(df: pd.DataFrame, labels: dict, output_path_main: Path,
                                    output_path_diag: Path) -> pd.DataFrame:
    """
    Run cloglog regression for policy interactions, calculate coefficients,
    and generate diagnostics for policy mixes. Interaction terms are included.

    Parameters:
    df (pd.DataFrame): The dataset.
    labels (dict): Dictionary of variable labels.
    output_path_main (str): Path to save the main results table.
    output_path_diag (str): Path to save diagnostics.

    Returns:
    pd.DataFrame: A summary table of coefficients and diagnostics.
    """

    # Define the predictors with interaction terms
    predictors = [
        "AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3",
        "AdoptionLikelihood_4", "AdoptionLikelihood_5", "CircumstancesLikelihood_1",
        "CircumstancesLikelihood_2", "CircumstancesLikelihood_3", "CircumstancesLikelihood_4",
        "CircumstancesLikelihood_5", "awarenessum", "C(tenure)", "C(whenbuilt2)",
        "squarefootage", "bedrooms", "hhsize", "old75", "minor16", "income",
        "C(address_change_time)", "C(EPCrating)", "C(profile_GOR)",
        "AdoptionLikelihood_1 * C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_2 * C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_3 * C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_4 * C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_5 * C(CircumstancesLikelihood_2)",
        "AdoptionLikelihood_1 * C(CircumstancesLikelihood_3)",
        "AdoptionLikelihood_2 * C(CircumstancesLikelihood_3)",
        "AdoptionLikelihood_3 * C(CircumstancesLikelihood_3)"
    ]
    formula = f"treated ~ {' + '.join(predictors)}"

    # Run cloglog model
    cloglog_model = smf.glm(formula, data=df, family=sm.families.Binomial(sm.families.links.cloglog())).fit()

    # Extract coefficients
    results_df = cloglog_model.summary2().tables[1]

    # Compute pseudo R² manually
    pseudo_r2 = 1 - (cloglog_model.llf / cloglog_model.llnull)

    # Create the diagnostics table
    diagnostics = pd.DataFrame({
        "Statistic": ["N", "Pseudo R²", "AIC", "BIC"],
        "Cloglog": [cloglog_model.nobs, pseudo_r2, cloglog_model.aic, cloglog_model.bic]
    })


    # Map variable names to labels
    results_df.index.name = 'Variable'
    results_df.reset_index(inplace=True)
    results_df["Variable"] = results_df.Variable.map(labels).fillna(results_df.Variable)

    # Save results and diagnostics
    results_df.to_csv(output_path_main, index=True)
    diagnostics.to_csv(output_path_diag, index=False)

    # Plot results
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
    plt.savefig(output_path_main)
    plt.close(fig)

    # Save diagnostics as image
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
    plt.savefig(output_path_diag)
    plt.close(fig_diag)

    print(f"Results saved to {output_path_main}")
    print(f"Diagnostics saved to {output_path_diag}")


def plot_marginal_effects_logit(df: pd.DataFrame, output_path: Path) -> pd.DataFrame:
    """
    Plot marginal effects from a logit model for different levels of AdoptionLikelihood_1.

    Parameters:
    df (pd.DataFrame): The dataset.
    output_path (Path): Path object to save the plot.

    Returns:
    pd.DataFrame: A summary table of marginal effects.
    """

    # Define the formula WITHOUT the interaction term
    formula = (
        "treated ~ AdoptionLikelihood_1 + "
        "AdoptionLikelihood_2 + AdoptionLikelihood_3 + AdoptionLikelihood_4 + AdoptionLikelihood_5 + "
        "CircumstancesLikelihood_1 + CircumstancesLikelihood_2 + CircumstancesLikelihood_3 + "
        "CircumstancesLikelihood_4 + CircumstancesLikelihood_5 + awarenessum + "
        "C(tenure) + C(whenbuilt2) + squarefootage + bedrooms + hhsize + old75 + minor16 + income + "
        "C(address_change_time) + C(EPCrating) + C(profile_GOR)"
    )

    # Fit the logit model
    logit_model = smf.logit(formula, data=df).fit(cov_type="HC0")

    # Generate different values for AdoptionLikelihood_1
    at_values = np.arange(1, 11, 1)  # From 1 to 10
    marginal_effects = []

    # Compute marginal effects at different levels of AdoptionLikelihood_1
    mean_values = df.mean(numeric_only=True)  # Hold numeric variables at their mean

    # Set categorical variables to their most frequent (mode) category
    categorical_vars = ["tenure", "whenbuilt2", "address_change_time", "EPCrating", "profile_GOR"]
    mode_values = df[categorical_vars].mode().iloc[0]  # Get most common category

    for value in at_values:
        at_exog = mean_values.copy()
        at_exog["AdoptionLikelihood_1"] = value  # Vary AdoptionLikelihood_1
        at_exog.update(mode_values)  # Ensure categorical variables are valid
        at_exog = pd.DataFrame([at_exog])  # Convert to DataFrame

        # Predict probabilities at each level
        pred_prob = logit_model.predict(at_exog)[0]

        # Compute finite difference approximation of marginal effect
        if value > 1:
            prev_exog = mean_values.copy()
            prev_exog["AdoptionLikelihood_1"] = value - 1
            prev_exog.update(mode_values)  # Ensure categorical variables are valid
            prev_exog = pd.DataFrame([prev_exog])
            prev_prob = logit_model.predict(prev_exog)[0]
            marg_effect = pred_prob - prev_prob  # Approximate dydx
        else:
            marg_effect = np.nan  # Can't compute for first point

        marginal_effects.append([value, marg_effect, pred_prob])

    # Convert results into a DataFrame
    mfx_df = pd.DataFrame(marginal_effects,
                          columns=["AdoptionLikelihood_1", "Marginal_Effect", "Predicted_Probability"])

    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Plot the marginal effects
    plt.figure(figsize=(8, 6))
    plt.plot(mfx_df["AdoptionLikelihood_1"], mfx_df["Marginal_Effect"], marker="o", linestyle="-",
             label="Marginal Effect")
    plt.fill_between(mfx_df["AdoptionLikelihood_1"], mfx_df["Predicted_Probability"] - 0.01,
                     mfx_df["Predicted_Probability"] + 0.01, color="gold", alpha=0.3, label="95% CI")
    plt.xlabel("Info Potential Saving (AdoptionLikelihood_1)")
    plt.ylabel("Marginal Effect on Adoption")
    plt.title("Marginal Effects of AdoptionLikelihood_1 with 95% CI")
    plt.legend()
    plt.grid(True)

    # Save plot with Path handling
    plt.savefig(output_path, dpi=300, bbox_inches="tight")
    plt.close()

    print(f"Plot saved to {output_path}")

    return mfx_df



def run_logit_cloglog_diagnostics(df: pd.DataFrame):
    """
    Run diagnostics for Logit and Cloglog models:
    - Check significance of AdoptionLikelihood_1
    - Check for multicollinearity (VIF)
    - Check outcome distribution
    - Compare model fit (AIC, BIC, Pseudo R²)

    Parameters:
    df (pd.DataFrame): The dataset.

    Returns:
    dict: Diagnostics summary for both models.
    """

    # Define the formula
    formula = (
        "treated ~ AdoptionLikelihood_1 + AdoptionLikelihood_2 + AdoptionLikelihood_3 + AdoptionLikelihood_4 + AdoptionLikelihood_5 + "
        "CircumstancesLikelihood_1 + CircumstancesLikelihood_2 + CircumstancesLikelihood_3 + "
        "CircumstancesLikelihood_4 + CircumstancesLikelihood_5 + awarenessum + "
        "C(tenure) + C(whenbuilt2) + squarefootage + bedrooms + hhsize + old75 + minor16 + income + "
        "C(address_change_time) + C(EPCrating) + C(profile_GOR)"
    )

    # Fit Logit Model
    logit_model = smf.logit(formula, data=df).fit(cov_type="HC0")

    # Fit Cloglog Model
    cloglog_model = smf.glm(formula, data=df, family=sm.families.Binomial(sm.families.links.cloglog())).fit(cov_type="HC0")

    # Extract significance of AdoptionLikelihood_1
    logit_p = logit_model.pvalues.get("AdoptionLikelihood_1", np.nan)
    cloglog_p = cloglog_model.pvalues.get("AdoptionLikelihood_1", np.nan)

    # Compute Variance Inflation Factor (VIF) to check multicollinearity
    X = df[["AdoptionLikelihood_1", "AdoptionLikelihood_2", "AdoptionLikelihood_3", "CircumstancesLikelihood_2"]].dropna()
    vif_data = pd.DataFrame()
    vif_data["Variable"] = X.columns
    vif_data["VIF"] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]

    # Check outcome distribution (is it mostly 0s or 1s?)
    treated_mean = df["treated"].mean()
    treated_dist = df["treated"].value_counts(normalize=True)

    # Compute Pseudo R² for logit and cloglog
    logit_pseudo_r2 = 1 - (logit_model.llf / logit_model.llnull)
    cloglog_pseudo_r2 = 1 - (cloglog_model.llf / cloglog_model.llnull)

    # Create diagnostics summary
    diagnostics = {
        "Logit": {
            "Pseudo R²": logit_pseudo_r2,
            "AIC": logit_model.aic,
            "BIC": logit_model.bic,
            "p-value (AdoptionLikelihood_1)": logit_p
        },
        "Cloglog": {
            "Pseudo R²": cloglog_pseudo_r2,
            "AIC": cloglog_model.aic,
            "BIC": cloglog_model.bic,
            "p-value (AdoptionLikelihood_1)": cloglog_p
        },
        "VIF": vif_data.to_dict(orient="records"),
        "Treated Distribution": treated_dist.to_dict(),
        "Treated Mean": treated_mean
    }

    return diagnostics
