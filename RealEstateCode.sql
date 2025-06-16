/* Create a new database called Residential_Properties */
.open --new "c:/ucf_classes/eco_4443/sql/databases/Residential_Properties.db"



/*  PART B: Create new tables called Characteristics, Sales, Locations */

/* Starting with the Sales Table */

CREATE TABLE Sales
(
    pid                TEXT ,
    saledatelatest     TEXT , 
    salepricelatest    REAL ,
PRIMARY KEY            (pid)
)
;

/* Import the data into the Sales table */

.mode csv
.headers on
.separator
.import c:/ucf_classes/eco_4443/sql/data/sales_dates_and_prices.csv Sales 
.mode column
;

/* Create the Locations Table */

CREATE TABLE Locations
(
    pid            TEXT ,
    situscity      TEXT ,
    situszip       INTEGER ,
    PRIMARY KEY    (pid)
)
;

/* Import the data into the Locations table */

.mode csv
.headers on
.separater ;
.import c:/ucf_classes/eco_4443/sql/data/cities_and_zipcodes.csv Locations
.mode column

/* Lastly the Characteristics Table */

CREATE TABLE Characteristics
(
pid                     TEXT ,
propertyusecode         TEXT ,
totalareasqft          REAL ,
totalcameraareasqft     REAL ,
totalbedroom            INTEGER ,
totalbathroom           INTEGER ,
datebuilt               TEXT ,
PRIMARY KEY             (pid)
)
;

/* Import data into Characteristics table */
mode csv
.headers on
.separator ,
.import c:/ucf_classes/eco_4443/sql/data/property_characteristics.csv Characteristics
.mode column


/* Query the database with all 3 tables */
SELECT 
C.pid ,
C.totalareasqft ,
C.totalbedroom ,
C.totalbathroom ,
C.propertyusecode ,
C.totalcameraareasqft ,
C. datebuilt ,
S.salepricelatest ,
L.situscity ,
L.situszip

FROM Characteristics AS C
JOIN Sales as S
ON C.pid = S.pid
JOIN Locations AS L
ON C.pid = L.pid
LIMIT 20
;

/* PART C: Query the database to determine the total number of sale associated with each of the property types/use codes in descending order by number of sales */

SELECT C.propertyusecode ,
COUNT(S.pid) AS "Number of Sales"

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
GROUP BY C.propertyusecode
ORDER BY "Number of Sales"
DESC
LIMIT 10
;

/* PART D: Replace the use codes with their titles, then repeat the query in PART C */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/property_type_sales_summary.csv

SELECT C.propertyusecode, 

CASE
WHEN CAST(C.propertyusecode AS INTEGER) BETWEEN 100 AND 106 THEN "Single-Family"
WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
WHEN CAST(C.propertyusecode AS INTEGER) = 135 THEN "Lake View"
WHEN CAST(C.propertyusecode AS INTEGER) = 140 THEN "Golf"
ELSE "Other"
END AS "Property Type", 
COUNT(S.pid) AS "Number of Sales"

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
GROUP BY C.propertyusecode
ORDER BY "Number of Sales"
DESC
;
.output stdout

/* PART E ----> Query the database to find the following for all property types:
                1. Average
                2. Minimum
                3. maximum

            FOR:
                1. total square footage
                2. square footage under central air
                3. number of bedrooms
                4. number of bathrooms
*/

/* First Query will report Total Sqft and Sqft A.H. */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/property_type_size_summary.csv

SELECT
    CASE
        WHEN CAST(C.propertyusecode AS INTEGER) BETWEEN 100 AND 106 THEN "Single-Family"
        WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 135 THEN "Lake View"
        WHEN CAST(C.propertyusecode AS INTEGER) = 140 THEN "Golf"
    ELSE "Other"
    END AS "Property Type", 
    COUNT(S.pid) AS "Number of Sales" ,

    ROUND(AVG(CAST(totalareasqft AS REAL)), 2) AS "Avg. Sqft." ,
    MIN(CAST(totalareasqft AS REAL), 2) AS "Min. Sqft." ,
    MAX(CAST(totalareasqft AS REAL), 2) AS "Max. Sqft.",

    ROUND(AVG(CAST(totalcameraareasqft AS REAL)), 2) AS "Avg. A.H.",
    MIN(CAST(totalcameraareasqft AS REAL), 2) AS "Min. A.H.",
    MAX(CAST(totalcameraareasqft AS REAL), 2) AS "Max. A.H."

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
GROUP BY "Property Type"
ORDER BY "Number of Sales"
DESC
;
.output stdout

/* This query will report AVG number of bedrooms and bathrooms */
.mode column
.headers on
.width 20 20
SELECT
    CASE
        WHEN CAST(C.propertyusecode AS INTEGER) BETWEEN 100 AND 106 THEN "Single-Family"
        WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 135 THEN "Lake View"
        WHEN CAST(C.propertyusecode AS INTEGER) = 140 THEN "Golf"
    ELSE "Other"
    END AS "Property Type", 
    COUNT(S.pid) AS "Number of Sales" ,


    ROUND(AVG(CAST(totalbedroom AS INTEGER)), 2) AS "Avg. Bedrooms", 
    MIN(CAST(totalbedroom AS INTEGER), 2) AS "Min. Bedrooms", 
    MAX(CAST(totalbedroom AS INTEGER), 2) AS "Max. Bedrooms",

    ROUND(AVG(CAST(totalbathroom AS INTEGER)), 2) AS "Avg. Bathrooms",
    MIN(CAST(totalbathroom AS INTEGER), 2) AS "Min. Bathrooms", 
    MAX(CAST(totalbathroom AS INTEGER), 2) AS "Max. Bathrooms"

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
GROUP BY "Property Type"
ORDER BY "Number of Sales"
DESC
LIMIT 25
;


/* PART F: Modify PART E to compare 2 property types using the summary information */
/* I'm comparing Lake Front and Canal Front properties */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/lake_vs_canal_bed_bath_comparison.csv

SELECT 
    CASE
        WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
    END AS "Property Type", 
    COUNT(S.pid) AS "Number of Sales",

    ROUND(AVG(CAST(totalbedroom AS INTEGER)), 2) AS "Avg. Bedrooms", 
    ROUND(AVG(CAST(totalbathroom AS INTEGER)), 2) AS "Avg. Bathrooms",

    MIN(CAST(totalbedroom AS INTEGER), 2) AS "Min. Bedrooms", 
    MAX(CAST(totalbedroom AS INTEGER), 2) AS "Max. Bedrooms", 
     
    MAX(CAST(totalbathroom AS INTEGER), 2) AS "Max. Bathrooms",
    MIN(CAST(totalbathroom AS INTEGER), 2) AS "Min. Bathrooms"

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
WHERE CAST(C.propertyusecode AS INTEGER) = 130
OR CAST(C.propertyusecode AS INTEGER) = 131
GROUP BY "Property Type"
ORDER BY "Number or Sales"
DESC
;
.output stdout

/* PART G: Query database to obtain summary information on property age (datebuilt) in years as of 2023. */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/property_age_summary.csv

SELECT
    CASE 
        WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        END AS "Property Type", 
        
        
        COUNT(S.pid) AS "Number of Sales",
        ROUND(AVG(2023 - CAST(SUBSTR(CAST(datebuilt AS TEXT), 1, 4) AS INTEGER)), 2) AS "Avg. Age", 
        MIN(2023-CAST(SUBSTR(CAST(datebuilt AS TEXT), 1, 4) AS INTEGER)) AS "Newest",
        MAX(2023-CAST(SUBSTR(CAST(datebuilt AS TEXT), 1, 4) AS INTEGER)) AS "Oldest"

FROM Characteristics AS C
JOIN Sales AS S
ON C.pid = S.pid
WHERE datebuilt IS NOT NULL
    AND LENGTH(CAST(datebuilt AS TEXT)) = 8
    AND CAST(C.propertyusecode AS INTEGER) = 130
    OR CAST(C.propertyusecode AS INTEGER) = 131
GROUP BY "Property Type"
ORDER BY C.datebuilt
DESC
;
.output stdout

/* PART H: Obtain summary information on most recent sales prices including Average, Minimum, and Maximum */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/property_price_summary.csv

SELECT
    CASE 
        WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
        WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        END AS "Property Type",

        COUNT(S.pid) AS "Number of Sales",
        ROUND(AVG(CAST(salepricelatest AS REAL)), 2) AS "Avg. Price",
        ROUND(MIN(CAST(salepricelatest AS REAL)), 2) AS "Min. Price",
        ROUND(MAX(CAST(salepricelatest AS REAL)), 2) AS "Max. Price"
    
    FROM Characteristics AS C
    JOIN Sales AS S
    ON C.pid = S.pid
    WHERE CAST(C.propertyusecode AS INTEGER) = 130
    OR CAST(C.propertyusecode AS INTEGER) = 131
    GROUP BY "Property Type"
    ORDER BY "Number of Sales"
    DESC
    ;
.output stdout

/* PART I: Modify H to find the summary information on sales on properties between 2013-2018. Use saledatelatest and report results by year. */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/yearly_price_trends_lake_vs_canal.csv

SELECT  
    SUBSTR(CAST(saledatelatest AS TEXT), 1, 4) AS "Year",
        CASE   
            WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
            WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        END AS "Property Type",
        
        COUNT(S.pid) AS "Number of Sales",
        ROUND(AVG(CAST(salepricelatest AS REAL)), 2) AS "Avg. Price",
        ROUND(MIN(CAST(salepricelatest AS REAL)), 2) AS "Min. Price",
        ROUND(MAX(CAST(salepricelatest AS REAL)), 2) AS "Max. Price"

FROM Characteristics AS C
JOIN Sales AS S ON C.pid = S.pid
WHERE 
    SUBSTR(CAST(S.saledatelatest AS TEXT), 1, 4) BETWEEN '2013' AND '2018'
    AND CAST(C.propertyusecode AS INTEGER) IN (130, 131)

GROUP BY "Year", "Property Type"
ORDER BY "Year"
;
.output stdout

/* PART J: Modify PART I to report at the City Level and Zipcode Level within each city on a yearly basis */

.mode csv
.headers on
.output c:code_and_data/code_and_data/sqlite/real-estate-analysis/price_summary_by_year_city_zip.csv

SELECT 
    SUBSTR(CAST(S.saledatelatest AS TEXT), 1, 4) AS "Year",
    L.situscity AS "City",
    L.situszip AS "ZipCode",

        CASE 
            WHEN CAST(C.propertyusecode AS INTEGER) = 130 THEN "Lake Front"
            WHEN CAST(C.propertyusecode AS INTEGER) = 131 THEN "Canal Front"
        END AS "Property Type",

        
        COUNT(S.pid) AS "Number of Sales",
        ROUND(AVG(CAST(salepricelatest AS REAL)), 2) AS "Avg. Price",
        ROUND(MIN(CAST(salepricelatest AS REAL)), 2) AS "Min. Price",
        ROUND(MAX(CAST(salepricelatest AS REAL)), 2) AS "Max. Price"

    FROM Characteristics AS C 
    JOIN Sales AS S ON C.pid = S.pid
    JOIN Locations AS L ON C.pid = L.pid
    
    WHERE 
        CAST(C.propertyusecode AS INTEGER) IN (130, 131)
        AND SUBSTR(CAST(S.saledatelatest AS TEXT), 1, 4) BETWEEN '2013' AND '2018'
    GROUP BY "Year", "City", "ZipCode", "Property Type"
    ORDER BY "Year", "City", "ZipCode"
    ;
.output stdout

/* Conclusion: Based on the results, it looks like Lake Front sales price growth is inconsistent across various zipcodes in Orlando. 
    However, in wealthier zipcodes in cities like Winter Park and Windermere sales prices are consistently higher than those in Orlando. */

/* PART K: Compare Lake Front vs Canal Front Popularity by determining total number of sales for eahc across all years and locations */
/* Export query to a file called Residential_Properties */

.mode csv
.headers on
.output c:/code_and_data/code_and_data/sqlite/real-estate-analysis/lake_vs_canal_popularity_by_city.csv

SELECT 
    SUBSTR(CAST(S.saledatelatest AS TEXT), 1, 4) AS "Year",
    L.situscity AS "City",
        
        COUNT(C.pid) AS "Total Sales",
        SUM(CASE WHEN CAST(propertyusecode AS INTEGER) = 130 THEN 1 ELSE 0 END) AS "Lake Front Sales",
        SUM(CASE WHEN CAST(propertyusecode AS INTEGER) = 131 THEN 1 ELSE 0 END) AS "Canal Front Sales"
    
    FROM Characteristics AS C
    JOIN Sales AS S ON C.pid = S.pid
    JOIN Locations AS L ON C.pid = L.pid
    WHERE CAST(propertyusecode AS INTEGER) IN (130, 131)
    GROUP BY "Year", "City"
    ORDER BY "Year" DESC, "Total Sales"
    ;
.output stdout