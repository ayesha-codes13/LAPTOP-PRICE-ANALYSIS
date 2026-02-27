import pandas as pd

# Load your dataset
df = pd.read_csv(r"C:\Users\Public\laptop prices analysis\laptops2_export.csv")

# ----------------------------
# 1. Remove unnecessary columns
# ----------------------------
if "price_per_gb" in df.columns:
    df.drop(columns=["price_per_gb"], inplace=True)

# ----------------------------
# 2. Standardize text columns
# ----------------------------
# Screen resolution
df["screen"] = df["screen"].astype(str).str.lower().str.replace(" ", "").str.replace("hd", "HD")

# Yes/No columns
for col in ["touchscreen", "retina", "ipspanel"]:
    if col in df.columns:
        df[col] = df[col].astype(str).str.strip().str.capitalize()
        df[col] = df[col].replace({"Yes": "Yes", "No": "No", "1": "Yes", "0": "No"})

# CPU and GPU brands
for col in ["cpu_brand", "gpu_brand"]:
    if col in df.columns:
        df[col] = df[col].astype(str).str.strip().str.capitalize()

# ----------------------------
# 3. Convert numeric columns
# ----------------------------
numeric_cols = ["price", "ram", "inches", "weight", "cpu_freq", "total_storage_gb", "primary_storage", "secondary_storage"]
for col in numeric_cols:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

# ----------------------------
# 4. Fix total_storage_gb
# ----------------------------
if "primary_storage" in df.columns and "secondary_storage" in df.columns:
    df["total_storage_gb"] = df["primary_storage"] + df["secondary_storage"]

# ----------------------------
# 5. Remove duplicates
# ----------------------------
df.drop_duplicates(inplace=True)

# ----------------------------
# 6. Save cleaned dataset
# ----------------------------
df.to_csv(r"C:\Users\Public\laptop prices analysis\laptops2_export_clean.csv", index=False)

print("Cleaning done! Saved as 'laptops2_export_clean.csv'")

import pandas as pd

df = pd.read_csv(r"C:\Users\Public\laptop prices analysis\laptops2_export_clean.csv")


import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

plt.style.use('ggplot')

# 1. Average price by CPU brand
plt.figure(figsize=(10,6))
avg_price_cpu = df.groupby('cpu_brand')['price'].mean().sort_values(ascending=False)
sns.barplot(x=avg_price_cpu.index, y=avg_price_cpu.values, palette='viridis')
plt.xticks(rotation=45)
plt.title('Average Laptop Price by CPU Brand')
plt.ylabel('Average Price')
plt.show()

# 2. Price vs RAM scatter plot
plt.figure(figsize=(10,6))
sns.scatterplot(data=df, x='ram', y='price', hue='cpu_brand', palette='tab10', s=100)
plt.title('Price vs RAM by CPU Brand')
plt.xlabel('RAM (GB)')
plt.ylabel('Price')
plt.show()

# 3. Laptop count by OS
plt.figure(figsize=(8,5))
sns.countplot(data=df, x='os', palette='Set2')
plt.title('Laptop Count by OS')
plt.xticks(rotation=30)
plt.show()
#4. Adding interactivity
Option 1: Plotly

python
Copy code
import plotly.express as px

fig = px.scatter(df, x='ram', y='price', color='cpu_brand', size='total_storage_gb',
                 hover_data=['product', 'os'])
fig.show()
Option 2: ipywidgets + matplotlib/seaborn

python
Copy code
from ipywidgets import interact

def plot_price_vs_ram(cpu_brand):
    data = df[df['cpu_brand']==cpu_brand]
    plt.figure(figsize=(8,5))
    sns.scatterplot(data=data, x='ram', y='price', hue='os', s=100)
    plt.title(f'Price vs RAM for {cpu_brand}')
    plt.show()

interact(plot_price_vs_ram, cpu_brand=df['cpu_brand'].unique())
