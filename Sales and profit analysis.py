#!/usr/bin/env python
# coding: utf-8

# ## Import libraries and load dataset

# In[2]:


import pandas as pd
import matplotlib.pyplot as plt


# In[3]:


df=pd.read_excel("C:/Users/dizej/Downloads/data.xlsx")


# In[4]:


df.head()


# ## Explore dataset

# In[5]:


df.info()


# In[6]:


df.describe()


# In[7]:


df.isnull().sum()


# In[32]:


#Number of unique values in each column
col=df.columns
for i in col:
    print( str(i) +": " + str(df[i].nunique()))


# In[34]:


## Duplicates check / it was obvious from previous code as well, number of unique values in Row ID column is equal to number of rows in dataset
df[df.duplicated(subset="Row ID")]


# ## Data preparation and analysis

# #### What was the highest Sale in 2020?

# In[44]:


df["Order Date"].max()
df["Order Date"].min()


# In[45]:


df[df["Sales"]==df["Sales"].max()]


# #### What is average discount rate of chairs?

# In[48]:


chairs=df[df["Sub-Category"]=="Chairs"]
chairs["Discount"].mean()


# #### Add extra columns to seperate Year & Month from the Order Date

# In[52]:


df["Order Date Year"]=df["Order Date"].dt.year
df["Order Date Month"]=df["Order Date"].dt.month
df.head()


# #### Add a new column to calculate the Profit Margin for each sales record

# In[53]:


df["Profit Margin"] = df["Profit"] / df["Sales"]
df.head()


# #### Export manipulated dataframe to Excel

# In[54]:


df.to_excel("C:/Users/dizej/Downloads/data_updated.xlsx")


# #### Create a new dataframe to reflect total Profit & Sales by Sub-Category

# In[81]:


df_by_sub_category=df.groupby("Sub-Category")[["Profit", "Sales"]].sum()
df_by_sub_category.reset_index(inplace=True)
df_by_sub_category


# ## Visualization

# #### Sales distribution

# In[65]:


df["Sales"].describe()


# In[73]:


plt.hist(df["Sales"], bins=30)
plt.title("Sales Distribution")
plt.xlabel("Sales")
plt.xticks([0,5000,10000,15000], [0, "5k", "10k", "15k"])
plt.show()


# #### Show the distribution and skewness of Sales

# In[ ]:


## Boxplot with outliers included
plt.boxplot(df["Sales"])
plt.show()


# In[76]:


## Boxplot without outliers
plt.boxplot(df["Sales"], showfliers=False)
plt.show()


# #### Plot Sales by Sub-Category

# In[88]:


plt.barh(df_by_sub_category["Sub-Category"], df_by_sub_category["Sales"], color="r")
plt.title("Sales by Sub-Category", fontsize=20)
plt.show()


# #### Plot Profit by Sub-Category

# In[95]:


plt.bar(df_by_sub_category["Sub-Category"], df_by_sub_category["Profit"], color="r")
plt.title("Sales by Sub-Category", fontsize=20)
plt.xticks(rotation=90)
plt.show()


# In[111]:


plt.scatter(df["Sales"], df["Profit"], c=df["Discount"])
plt.show()


# #### Check Discount mean by Sub Category

# In[117]:


df_discount=df.groupby("Sub-Category").agg({"Discount": "mean", "Profit": "sum"})
df_discount.reset_index(inplace=True)
df_discount.head()


# #### Plot Sales & Profit Development for the year 2020

# In[120]:


df_sorted=df.sort_values("Order Date")
df_sorted.head(20)


# In[124]:


df_sorted["Cumulative Sales"]= df_sorted["Sales"].cumsum()
df_sorted["Cumulative Profit"]= df_sorted["Profit"].cumsum()
df_sorted.head()
df_sorted["Cumulative Sales"].max()


# In[130]:


plt.plot(df_sorted["Order Date"], df_sorted["Cumulative Sales"], label="Sales")
plt.plot(df_sorted["Order Date"], df_sorted["Cumulative Profit"], label="Profit")
plt.title("Sales vs. Profit Development")
plt.legend()
plt.show()


# In[ ]:




