SELECT * 
FROM club_member_info;

-- DUPLICATE TABLE --
CREATE TABLE club_member_info2
LIKE club_member_info;

INSERT club_member_info2
SELECT *
FROM club_member_info;

SELECT *
FROM club_member_info2;

-- RENAME MISPELLED COLUMNS--
ALTER TABLE club_member_info2
RENAME COLUMN `martial_status` TO `marital_status`;

-- IDENTIFY DUPLICATE ENTRIES --
SELECT *, ROW_NUMBER () OVER (
PARTITION BY 
full_name, 
age,
marital_status, 
email, 
phone, 
full_address, 
job_title, 
membership_date) AS row_num
FROM club_member_info2;

WITH cte_cmi AS (
SELECT *, ROW_NUMBER () OVER (
PARTITION BY 
full_name, 
age,
marital_status, 
email, 
phone, 
full_address, 
job_title, 
membership_date) AS row_num
FROM club_member_info2)
SELECT *
FROM cte_cmi
WHERE row_num > 1;

-- CREATE A NEW TABLE TO DROP DUPLICATES --
CREATE TABLE `club_member_info3` (
  `full_name` text,
  `age` int DEFAULT NULL,
  `marital_status` text,
  `email` text,
  `phone` text,
  `full_address` text,
  `job_title` text,
  `membership_date` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT club_member_info3
SELECT *, ROW_NUMBER () OVER (
PARTITION BY 
full_name, 
age,
marital_status, 
email, 
phone, 
full_address, 
job_title, 
membership_date) AS row_num
FROM club_member_info2;

DELETE
FROM club_member_info3
WHERE row_num > 1;

-- CHECK FOR MISPELLINGS AND UPDATE--
SELECT DISTINCT marital_status
FROM club_member_info3;

UPDATE club_member_info3
SET marital_status = 'divorced'
WHERE marital_status LIKE 'divored';

-- SET BLANK VALUES TO NULL --
SELECT * 
FROM club_member_info3;

UPDATE club_member_info3
SET marital_status = NULL
WHERE marital_status = '';

UPDATE club_member_info3
SET phone = NULL
WHERE phone = '';

UPDATE club_member_info3
SET job_title = NULL
WHERE job_title = '';

-- CHANGE DATE TYPE--
UPDATE club_member_info3
SET membership_date = STR_TO_DATE(membership_date, '%m/%d/%Y');

ALTER TABLE club_member_info3
MODIFY COLUMN membership_date DATE;

-- REMOVE WHITESPACE --
SELECT full_name, REPLACE (full_name, '???', '')
FROM club_member_info3;

UPDATE club_member_info3
SET full_name = REPLACE (full_name, '???', '');

UPDATE club_member_info3
SET full_name = TRIM(full_name);

-- CONVERT THE NAMES TO LOWER CASE --
SELECT full_name, LOWER(full_name)
FROM club_member_info3;

UPDATE club_member_info3
SET full_name = LOWER(full_name);

-- REMOVE INCONSISTENT DATES --
SELECT *
FROM club_member_info3
WHERE membership_date < '1999-01-01';

UPDATE club_member_info3
SET membership_date = NULL
WHERE membership_date < '1999-01-01';

-- REMOVE INCOMPLETE NUMBERS --
SELECT phone, LENGTH(phone)
FROM club_member_info3;

UPDATE club_member_info3
SET phone = NULL
WHERE LENGTH(phone) < 12;

-- REMOVE EXTRA VALUES FROM THE AGES --
SELECT *, LENGTH(age), SUBSTRING(age, 1, 2)
FROM club_member_info3
WHERE LENGTH(age) > 2;

UPDATE club_member_info3
SET age = SUBSTRING(age, 1, 2)
WHERE LENGTH(age) > 2;

-- MAKE A NEW TABLE FOR KEY ID--
CREATE TABLE `club_member_info4` (
  `full_name` text,
  `age` int DEFAULT NULL,
  `marital_status` text,
  `email` text,
  `phone` text,
  `full_address` text,
  `job_title` text,
  `membership_date` date DEFAULT NULL,
  `row_num` int DEFAULT NULL, 
   `key_id` int NOT NULL,
  PRIMARY KEY (key_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT club_member_info4
SELECT *, ROW_NUMBER () OVER () AS key_id
FROM club_member_info3
ORDER BY 1;  

SELECT *
FROM club_member_info4;

-- SPLIT NAMES INTO FIRST AND LAST --
SELECT *, SUBSTRING_INDEX(split.full_name, ' ', 1) AS first_name,
SUBSTRING_INDEX(split.full_name, ' ', -1) AS last_name
FROM club_member_info4 AS split
JOIN club_member_info4 AS together
ON split.key_id = together.key_id;

ALTER TABLE club_member_info4
ADD COLUMN first_name VARCHAR(50);

ALTER TABLE club_member_info4
ADD COLUMN last_name VARCHAR(50);

UPDATE club_member_info4
SET first_name = SUBSTRING_INDEX(full_name, ' ', 1);

UPDATE club_member_info4
SET last_name = SUBSTRING_INDEX(full_name, ' ', -1);

-- SPLIT ADRESS INTO STREET, CITY AND STATE--
SELECT SUBSTRING_INDEX(full_address, ',', 1) AS street,
    SUBSTRING(full_address, LOCATE(',', full_address) + 1,
              LOCATE(',', full_address, LOCATE(',', full_address) + 1) - LOCATE(',', full_address) - 1) AS city,
    SUBSTRING_INDEX(full_address, ',', -1) AS state
FROM club_member_info4;

ALTER TABLE club_member_info4
ADD COLUMN street VARCHAR(200);

ALTER TABLE club_member_info4
ADD COLUMN city VARCHAR(100);

ALTER TABLE club_member_info4
ADD COLUMN state VARCHAR(50);

UPDATE club_member_info4
SET street = SUBSTRING_INDEX(full_address, ',', 1);

UPDATE club_member_info4
SET city =  SUBSTRING(full_address, LOCATE(',', full_address) + 1,
              LOCATE(',', full_address, LOCATE(',', full_address) + 1) - LOCATE(',', full_address) - 1);

UPDATE club_member_info4
SET state = SUBSTRING_INDEX(full_address, ',', -1);

SELECT *
FROM club_member_info4;

-- CREATE A NEW TABLE AND INSERT THE CLEAN DATA--
CREATE TABLE `cleaned_club_member_info` (
  `key_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `marital_status` text,
  `email` text,
  `phone` text,
  `street` varchar(200) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `job_title` text,
  `membership_date` date DEFAULT NULL,
  PRIMARY KEY (`key_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO cleaned_club_member_info (
			first_name, 
            last_name, 
            age, 
            marital_status, 
            email,
            phone,
            street,
            city,
            state,
            job_title,
            membership_date)
SELECT first_name, 
            last_name, 
            age, 
            marital_status, 
            email,
            phone,
            street,
            city,
            state,
            job_title,
            membership_date
FROM club_member_info4;

SELECT *
FROM cleaned_club_member_info;