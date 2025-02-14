import pandas as pd
from pathlib import Path

def make_table_1_comparison(new_table_1_path, old_table_1_path):
    # read the two summary tables
    old_table_1 = pd.read_csv(old_table_1_path)
    new_table_1 = pd.read_csv(new_table_1_path)

    # rename index to variable column
    new_table_1.rename(columns={'index': 'Variable'}, inplace=True)

    # convert Variable names to lowercase for easier comparison
    new_table_1.columns = new_table_1.columns.str.lower()
    old_table_1.columns = old_table_1.columns.str.lower()

    #sSort and set index
    new_table_1.sort_values(by=['variable'], inplace=True)
    old_table_1.sort_values(by=['variable'], inplace=True)
    new_table_1.set_index('variable', inplace=True)
    old_table_1.set_index('variable', inplace=True)

    # make sure everything is numeric in both tables
    for col in old_table_1.columns:
        old_table_1[col] = pd.to_numeric(old_table_1[col], errors='coerce')
    for col in new_table_1.columns:
        new_table_1[col] = pd.to_numeric(new_table_1[col], errors='coerce')

    # Compute difference
    remainder = new_table_1 - old_table_1

    # create new save path and name
    verify = old_table_1_path.parent.parent / 'outputs'
    verify.mkdir(exist_ok=True)
    rpath = verify / 'table_1_comparison.csv'

    # save data

    remainder.to_csv(rpath)

def make_table_3_comparisons(new_table_path, new_table_path_appendix, old_table_path):
    df_1 = pd.read_csv(old_table_path)
    df_2 = pd.read_csv(new_table_path)
    df_3 = pd.read_csv(new_table_path_appendix)
    keep = ['Grants', 'Higher EE. standards', 'Info. Efficient use', 'Info. Support schemes',
            'Loans', 'Release admin. barriers', 'Stronger EE. standards', 'Tax credits', 'Tenure (Other)',
            'Tenure (Renter)','Utilities involvement', 'Info. potential savings']

    df_1['Lower CI Cloglog'] = df_1['Cloglog Marginal Effect'] - 1.96 * df_1['Cloglog SE']
    df_1['Upper CI Cloglog'] = df_1['Cloglog Marginal Effect'] + 1.96 * df_1['Cloglog SE']
    df_1['Lower CI Logit'] = df_1['Logit Marginal Effect'] - 1.96 * df_1['Logit SE']
    df_1['Upper CI Logit'] = df_1['Logit Marginal Effect'] + 1.96 * df_1['Logit SE']

    df_2['Lower CI Cloglog'] = df_2['Cloglog Marginal Effect'] - 1.96 * df_2['Cloglog SE']
    df_2['Upper CI Cloglog'] = df_2['Cloglog Marginal Effect'] + 1.96 * df_2['Cloglog SE']
    df_2['Lower CI Logit'] = df_2['Logit Marginal Effect'] - 1.96 * df_2['Logit SE']
    df_2['Upper CI Logit'] = df_2['Logit Marginal Effect'] + 1.96 * df_2['Logit SE']

    df_3['Lower CI Cloglog'] = df_3['Cloglog Coefficient'] - 1.96 * df_3['Cloglog SE']
    df_3['Upper CI Cloglog'] = df_3['Cloglog Coefficient'] + 1.96 * df_3['Cloglog SE']
    df_3['Lower CI Logit'] = df_3['Logit Coefficient'] - 1.96 * df_3['Logit SE']
    df_3['Upper CI Logit'] = df_3['Logit Coefficient'] + 1.96 * df_3['Logit SE']

    df_1['result cloglog'] = ((df_1['Lower CI Cloglog'] > 0 ) & (df_1['Upper CI Cloglog'] > 0 )) | ((df_1['Lower CI Cloglog'] < 0 ) & (df_1['Upper CI Cloglog'] < 0 ))
    df_2['result cloglog'] = ((df_2['Lower CI Cloglog'] > 0) & (df_2['Upper CI Cloglog'] > 0)) | ((df_2['Lower CI Cloglog'] < 0) & (df_2['Upper CI Cloglog'] < 0))
    df_1['result logit'] = ((df_1['Lower CI Logit'] > 0 ) & (df_1['Upper CI Logit'] > 0 )) | ((df_1['Lower CI Logit'] < 0 ) & (df_1['Upper CI Logit'] < 0 ))
    df_2['result logit'] = ((df_2['Lower CI Logit'] > 0 ) & (df_2['Upper CI Logit'] > 0 )) | ((df_2['Lower CI Logit'] < 0 ) & (df_2['Upper CI Logit'] < 0 ))
    df_3['result cloglog'] = ((df_3['Lower CI Cloglog'] > 0) & (df_3['Upper CI Cloglog'] > 0)) | ((df_3['Lower CI Cloglog'] < 0) & (df_3['Upper CI Cloglog'] < 0))
    df_3['result logit'] = ((df_3['Lower CI Logit'] > 0 ) & (df_3['Upper CI Logit'] > 0 )) | ((df_3['Lower CI Logit'] < 0 ) & (df_3['Upper CI Logit'] < 0 ))

    df_1.to_csv(new_table_path.parent / 'table_3_sig.csv')
    df_2.to_csv(new_table_path.parent / 'table_3_sig_book.csv')
    df_3.to_csv(new_table_path.parent / 'table_3a_sig.csv')

    print('made comparison table 1')