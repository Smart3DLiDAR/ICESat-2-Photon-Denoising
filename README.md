# ICESat-2-Photon-Denoising
This code is a method for progressive noise photon removal from ICESat-2 data based on different types of noise characteristics; this method includes three main steps: ⅰ) Isolated noise photons removal based on a multi-thresholding strategy, ⅱ) Adaptive calculation of terrain slopes and removal of low-density clustered noise photons, and  ⅲ) Outer clustered noise photons removal based on the box plots analysis.

More detailed information about the code can be found in the article " Progressive noise photons removal from ICESAT-2 data based on the characteristics of different types of noise"

If you use this code, please remember to cite this paper.

# Code structure

Data Access and Download：This directory contains Python files for data access and download, mainly improved based on the Python download code provided by NASA.

Main.m:The main function.

Data_preprocessing: This directory contains the basic functionalities and toolbox for preprocessing the original ICESat-2  data (.h5), converting it into two-dimensional profiles to obtain the along-track distance and height of photons. Data extraction can also be completed using the software PhoReal_v3.30.exe. This toolbox was originally developed by Lonesome Malambo. Our method has been modified and improved based on this technology.

h5_data: The directory contains the provided ICESat-2  data, including ATL03 and ATL08.

Photon_Denoising: This directory contains basic functional code related to photon noise removal, including the Douglas–Peucker algorithm, basic functional code for Minpts calculation, and basic functional code for photon ellipse counting.

Sample : This directory holds the test data in '.csv' format.

Result : This directory stores the modeling results of the test data.

The code is written in Matlab R2023a and Python 3.13.
