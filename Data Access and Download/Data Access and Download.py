#!/usr/bin/env python
# coding: utf-8

# ## How to interact with icepyx to search, order, and download subsets of ICESat-2 data

# Import the package, including icepyx.

# In[1]:

# %load_ext autoreload
import icepyx as ipx
import geopandas as gpd
import os
import shutil
from pprint import pprint

# ##  Steps for Programmatic Data Access
# 
# 1.  Define parameters (space, time, datasets, etc.)
# 2.  Query the NSIDC API for more information about the datasets
# 3.  Log in to NASA Earthdata
# 4.  Define additional parameters (e.g., subset/custom options)
# 5.  Order the data
# 6.  Download the data

# ## Step 1: Create an ICESat-2 data object using the required search parameters.
# Three inputs are needed:
# 
# - The short name refers to the dataset of interest, known as its "abbreviation." For a list of available datasets, please refer to https://nsidc.org/data/icesat-2/data-sets. The short name or ID of the dataset can also be found at the top of each individual dataset landing page on the NSIDC website.
# 
# - spatial extent = the area of interest where the search is to be conducted. This can be input as a bounding box, polygon vertex coordinates, or polygon geospatial files (currently supports shp, kml, and gpkg, although gpkg has not yet been tested).
# 
# - Bounding box: The left bottom longitude, left bottom latitude, right top longitude, and right top latitude are expressed in decimal degrees. West longitudes and south latitudes should be provided as negative numbers.
# - Polygon vertices: Given as pairs of longitude and latitude coordinates in degrees, with the last entry repeating the first entry.
# - Polygon file: A string that contains the complete file path and name.
# - date_range= The date range for the results you want to search. It must be formatted as a set of comma-separated 'YYYY-MM-DD' strings.
# There are several optional inputs that allow users to better control their searches.
# 
# - start_time= Start date for the data search. If no input is provided, it defaults to 00:00:00.
# - end_time= The end time for the end date of the time search parameter. If no input is provided, it defaults to 23:59:59. The time must be entered as a 'HH:mm:ss' string.
# - version= The version of the dataset to be used, input as a digital string. If no input is provided, this value defaults to the latest version of the dataset specified by short_name.
# 
# - spatial extent：Spatial extent is a necessary input for data access. Please refer to Figure 1 in the NSIDC programming access guide for examples of the concepts of spatial filtering (particles that overlap with the input spatial extent based on particle metadata) and spatial subsetting (trimming or extracting data values within each particle based on the input spatial extent).
# 
# - Version warnings：In the cell below, use version 001 as an example to illustrate the warnings issued when the latest version is not used. However, using it can lead to 'no results' errors in the granularity sorting of certain search parameters. These issues have been resolved in higher versions of the dataset, so it is best to use the latest version whenever possible.

# Taking dayanshanxian.shp as an example

# In[2]:


short_name = 'ATL03'
# spatial_extent = [-83.66, 35.56, -83.34, 35.7]  # [-180, -80, -140, -70]
date_range = ['2021-01-01', '2024-01-01']
spatial_extent = "F:/2023shuju/USAmap/danyanshan/dayanshanxian.shp"

# In[3]:

region_a = ipx.Query(short_name, spatial_extent, date_range, start_time='00:00:00', end_time='23:59:59', version='006')

print(region_a.product)  # dataset
print(region_a.dates)
print(region_a.start_time)
print(region_a.end_time)
print(region_a.product_version)
# print(region_a.spatial_extent)

# In[4]:

region_a.visualize_spatial_extent()

# In[5]:

print(region_a.latest_version())
region_a.product_summary_info()

# In[6]:
# All available data
filelist = region_a.avail_granules(ids=True)[0]
filelist
# ## Step 2: Query the dataset

# In[7]:
# Establish parameter dictionary
region_a.CMRparams

# In[8]:
# Search for available data and calculate storage information.
region_a.avail_granules()

# In[9]:

# Get data list
region_a.avail_granules(ids=True)

# In[10]:

# Output detailed information of search results
region_a.granules.avail

# ## 第 3 步：Login NASA Earthdata
# In order to download any data from NSIDC, you need to use a valid Earthdata login to verify yourself. This will start an active login session to enable data downloading.

# In[13]:

# Fill in the login information
# ## Step 4: Additional parameters and subsets
# - page_size= 10。
# - page_num= 1.
# - request_mode= 'async'
# - include_meta='Y'

# In[14]:

print(region_a.reqparams)

# In[16]:
region_a.subsetparams()

# In[17]:
region_a.show_custom_options(dictview=True)

# In[18]:

# region_a.order_vars.avail(options=True)
# the option is to remove:
# - all（默认 False）- Reset region_a.order_vars.wanted is None
# - var_list
# - beam_list
# - keyword_list
# **Example 1: Create a default variable list **

# In[19]:


# region_a.order_vars.append(defaults=True)
# pprint(region_a.order_vars.wanted)


# **Example 2: Clear variable list**

# In[20]:


# region_a.order_vars.remove(all=True)
# pprint(region_a.order_vars.wanted)


# **Example 3: Select Variables**

# In[21]:


# Latitude adds all variables in all six beam groups. Note that additional required variables for time and spacecraft orientation are included by default.

# region_a.order_vars.append(var_list=['latitude'])
# pprint(region_a.order_vars.wanted)


# **Example 4: Add/Delete Selected Beams (GTL Strong and Weak Tracks) + Variables **

# In[22]:


# Add the longitude attribute for gt1l and gt3l, and remove the latitude attribute for gt2l.

# region_a.order_vars.append(beam_list=['gt1l', 'gt3l'],var_list=['longitude'])
# region_a.order_vars.remove(beam_list=['gt2l'], var_list=['latitude'])
# pprint(region_a.order_vars.wanted)


# **Example 5: Download orders using default variables**

# In[23]:
# region_a.order_vars.remove(all=True)
# region_a.order_vars.append(defaults=True)
# pprint(region_a.order_vars.wanted)
# region_a.subsetparams(Coverage=region_a.order_vars.wanted)


# ## Step 5: Send the data order
# order_granules()
# In[24]:
region_a.order_granules()
# region_a.order_granules(Coverage=region_a.order_vars.wanted)


# ##Step 6: Download Order
# Finally, we can download our orders to a specified directory (the full path is required but does not need to point to an existing directory), and the download status will be printed out while the program is running.
# In[25]:
path = 'D:/Download/OPIC_test_data/data/d'
region_a.download_granules(path)
# region_a.download_granules(Coverage=region_a.order_vars.wanted)
# In[57]:
# If the data download is interrupted, you can redownload it.
# region_a.download_granules(path,restart=True)
# In[ ]:
