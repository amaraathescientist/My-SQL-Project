# Data Cleaning

## Introduction
A faux dataset of club member information gathered via an online form.


## Problem Statement
- Create a key id.  
- Remove special characters, ensure all entries are lowercase and free of extra whitespace.  
- Convert the membership date data type to date.   
- Separate full name to individual columns (firstname, last_name).  
- Some ages have an extra digit at the end only show the first 2 digits.  
- Email addresses are unique. Use this column when searching for duplicates and remove duplicate entries.  
- Convert all empty fields to NULL.  
- Separate address to three different columns (street_address, city, state).  
- All membership_dates were in the 2000's.  

## Datasets used
This dataset contains one csv file named ['club_member_info.csv'](https://github.com/iweld/data_cleaning/blob/main/club_member_info/csv/club_member_info.csv).

The initial columns and their type in the provided CSV file are:  

full_name : text  
age : int  
martial_status : text  
email : text  
phone : text  
full_address : text  
job_title : text  
membership_date : text  
