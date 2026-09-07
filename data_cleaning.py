import pandas as pd

# Load the raw data
df = pd.read_excel("data/sales_dataset.xlsx")

print(df.head())
print(df.shape)
print(df.info())

print(df.isnull().sum())
print(df['Status'].unique())
print(df['Fulfilment'].unique())
print(df.duplicated().sum())

print(df[df['Amount'].isnull()]['Status'].value_counts())
print(df[df['Courier Status'].isnull()]['Status'].value_counts())
print(df[df['fulfilled-by'].isnull()]['Fulfilment'].value_counts())




# %%
# Load the raw data
df = pd.read_excel("data/sales_dataset.xlsx")
print(df.shape)
print(df.head())

# %%
# Drop the junk unnamed column (export artifact, no real data)
df = df.drop(columns=['Unnamed: 22'])
print(df.shape)

# %%
# Drop exact duplicate rows
before = df.shape[0]
df = df.drop_duplicates()
print(f"Dropped {before - df.shape[0]} duplicate rows")
print(df.shape)

# %%
# Drop the 33 rows missing shipping info (tiny fraction, likely data entry errors)
before = df.shape[0]
df = df.dropna(subset=['ship-city', 'ship-state', 'ship-postal-code', 'ship-country'])
print(f"Dropped {before - df.shape[0]} rows missing shipping info")
print(df.shape)

# %%
# Amount/currency: nulls are mostly Cancelled orders (structural, not errors).
# Keeping cancelled orders in the dataset so cancellation patterns can be analyzed later.
# Flag them clearly instead of guessing a fill value.
df['is_cancelled'] = df['Status'] == 'Cancelled'
print(df['is_cancelled'].value_counts())

# Sanity check: how many non-cancelled orders still have missing Amount?
leftover_nulls = df[(df['Amount'].isnull()) & (~df['is_cancelled'])]
print(f"Non-cancelled orders with missing Amount: {leftover_nulls.shape[0]}")
print(leftover_nulls['Status'].value_counts())

# %%
# Courier Status and fulfilled-by nulls are structural — leave them as NaN.
# (Courier Status: mostly Cancelled orders never reached a courier.
#  fulfilled-by: only populated for Merchant-fulfilled orders.)

# %%
# promotion-ids: fill nulls with 'None' for clarity instead of leaving blank
df['promotion-ids'] = df['promotion-ids'].fillna('None')

# %%
# Fix column types / clean up column names for easier downstream use
df.columns = df.columns.str.strip().str.replace('-', '_').str.replace(' ', '_')
print(df.columns.tolist())

# %%
# Final check before saving
print(df.info())
print(df.isnull().sum())

# %%
# Save the cleaned dataset
df.to_csv("data/amazon_sales_cleaned.csv", index=False)
print("Saved amazon_sales_cleaned.csv")