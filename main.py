import pandas as pd
from pathlib import Path
import data_prep, basic_viz, results
import interactions, table_comparisons


def prep():
    """This function prepares the data following the instructions in lines 17 to lines 107 of the file PIREES55 1_var recode_submission.do
    """

    # this is the required transformed data
    path = Path.cwd() / 'data' / 'transformed_data.csv'

    # check if exists
    if not path.exists():
        # create it from data_prep.py file
        data_prep.prepare_data()

    # read the file now we know its there
    df = pd.read_csv(path)

    return df


def main():
    """
    Main function to run the replication script.

    Runs the remainder of the replication code that is reproduced here.

    :return: None
    """

    save_path = Path.cwd() / 'outputs'
    save_path.mkdir(exist_ok=True)

    # deal with labels as best we can
    lpath = Path.cwd() / 'data' / 'Labels.do'
    labels = results.extract_labels(lpath)

    df = prep()
    print("Data loaded and ready for analysis!")

    # make summary table in Table 1
    t1path = Path.cwd() / 'outputs' / 'table_1.png'
    old_t1path = Path.cwd() / 'data' / 'table_1_data.csv'
    if not t1path.exists():
        basic_viz.generate_descriptive_stats(df, t1path)
        # create checking table in outputs / verify
        table_comparisons.make_table_1_comparison(t1path.with_suffix('.csv'), old_t1path)

    # make correlation plot in Table A1
    cpath = Path.cwd() / 'outputs' / 'corrplot.png'
    if not cpath.exists():
        basic_viz.corr_plot(df,cpath)

    # make variance inflation factor data for comparison
    vpath = Path.cwd() / 'outputs' / 'variance_inflation_factor.csv'
    if not vpath.exists():
        basic_viz.check_variance_inflation_factor(df,vpath)

    f1path = Path.cwd() / 'outputs' / 'figure_1.png'

    # make figure 1
    if not f1path.exists():
        basic_viz.plot_energy_measures(df, f1path)

    # make figure 3
    f3path = Path.cwd() / 'outputs' / 'figure_3.png'
    if not f3path.exists():
        basic_viz.plot_policy_awareness(df, f3path)

    # make table 3

    # main table 3
    t3path = Path.cwd() / 'outputs' / 'table_3.png'
    # table 3 model diagnostics
    t3path_diag = Path.cwd() / 'outputs' / 'table_3_diag.png'

    # odd ratio plots from table 3 data
    f4path = Path.cwd() / 'outputs' / 'figure_4.png'

    # table 3 in appendix
    t3apath = Path.cwd() / 'outputs' / 'table_3a.png'
    old_t3path = Path.cwd() / 'data' / 'table_3_data.csv'

    t3apath_pylogit = Path.cwd() / 'outputs' / 'table_3a_pylogit.png'


    if not t3path.exists():
        rdf = results.run_regression(df, t3path, t3apath, t3path_diag, labels)
        results.plot_odds_ratios(rdf, f4path)
        table_comparisons.make_table_3_comparisons(t3path.with_suffix('.csv'), t3apath.with_suffix('.csv'), old_t3path)
    try:
        results.run_regression_pylogit(df, t3path, t3apath_pylogit, t3path_diag, labels)
    except Exception as e:
        print('***** known error occured. Singular Matrix for pylogit *****')
        print(e)
    results.run_regression_scikit_learn(df, Path.cwd() / 'outputs' / 'sklearn_coeffs.csv')
    # make table 4 - main path, diagnostics path, table 4 appendix path, figure 5 path
    t4path = Path.cwd() / 'outputs' / 'table_4.csv'
    t4path_diag = Path.cwd() / 'outputs' / 'table_4_diag.csv'
    t4apath = Path.cwd() / 'outputs' / 'table_4a.csv'
    f5path = 'outputs'

    # check if it exists
    if not t4path.exists():
        # run the regressions, get the coefficients and the marginal likelihoodss
        tdf = results.run_regressions_high_low(df, labels, t4path, t4apath, t4path_diag)
        results.plot_odds_ratios_by_type(tdf, f5path)

    # now the same for table 5a in the appendix
    t5apath = Path.cwd() / 'outputs' / 'table_5a.png'
    t5apath_diag = Path.cwd() / 'outputs' / 'table_5a_diag.png'

    if not t5apath.exists():
        results.run_multinomial_logit(df, labels, t5apath, t5apath_diag)

    # now the same for table 6a in the appendix
    t6apath = Path.cwd() / 'outputs' / 'table_6a.png'
    t6apath_diag = Path.cwd() / 'outputs' / 'table_6a_diag.png'
    if not t6apath.exists():
        interactions.run_policy_interactions_logit(df, labels, t6apath, t6apath_diag)

    # now for table 7a in the appendix
    t7apath = Path.cwd() / 'outputs' / 'table_7a.png'
    t7apath_diag = Path.cwd() / 'outputs' / 'table_7a_diag.png'
    if not t7apath.exists():
        interactions.run_policy_interactions_cloglog(df, labels, t7apath, t7apath_diag)

    # now for figure 6
    f6apath = Path.cwd() / 'outputs' / 'figure_6.png'
    if not f6apath.exists():
        interactions.plot_marginal_effects_logit(df, f6apath)

    diag = interactions.run_logit_cloglog_diagnostics(df)


    print('done')

main()