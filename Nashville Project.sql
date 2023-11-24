CREATE DATABASE Nashville;
USE Nashville;

CREATE TABLE Nashville_property (UniqueID VARCHAR(85) NULL, ParcelID VARCHAR(85)  NULL,	LandUse VARCHAR(45) NULL,   
PropertyAddress VARCHAR(45) NULL,SaleDate VARCHAR(85) NULL, 	SalePrice VARCHAR(85) NULL, LegalReference VARCHAR(85) NULL,	
    SoldAsVacant VARCHAR(85) NULL,	OwnerName VARCHAR(85) NULL,	OwnerAddress VARCHAR(85) NULL,	Acreage VARCHAR(80) NULL,	
    TaxDistrict VARCHAR(85),	LandValue VARCHAR(85) NULL,	BuildingValue VARCHAR(85) NULL,	TotalValue VARCHAR(45) NULL, 
    YearBuilt VARCHAR(45) NULL,	Bedrooms VARCHAR(45) NULL,	FullBath VARCHAR(85) NULL,    HalfBath VARCHAR(45) NULL);

-- We want to explore our dataset
SELECT * FROM nashville_propertY;

 -- we want to count the number of rows we have, it shows we have 56,477 records in our dataset
 SELECT COUNT(*) FROM nashville_propertY; 
 
-- From the exploration it shows I have some empty records in my dataset, so I want to count the number of empty records in each column
 SELECT COUNT(*) 
 FROM nashville_property
 WHERE Ownername = "";
 
/* After counting the empty rows in each of the columns, this is the number of empty records in each of the columns.
Parcelid (0), Landuse  (0), propertyaddress  (29), saledate   (0),  saleprice  (0),   legalreference(0), Soldasvacant (0)
Ownername     (31,216),  owneraddress   (30,462) Acreage (30,462), Taxdistrict  (30,462), landvalue (30,462), buildingvalue (30,462), 
totalvalue (30,462), yearbuilt  (32,314), bedrooms   (32,320), fullbath (32,202), halfbath (32,333)
*/

# Now, I want to chek if my empty rows are greater than 40% of my total rows.
SELECT (30462/56477)*100 AS EMPTY_ROW_PERCENT;   # = 53.9370%

-- I want to replace  the empty rows in (Taxdistrict, ownername, owneraddress, property address) with N/A
UPDATE nashville_property
SET PropertyAddress  = 'N/A'
WHERE PropertyAddress = "";

/* Here, I want to replace the digit columns with a value which does not exist in that particular column.
To be able to do this, I will use a unique value which is not existing in the columns to replace the empty records.
After having checked, I set the the empty rows in each of the columns to the following numbers
 Acreage = 99.99,    Landvalue = 0,  Buildingvalue = 1, TOTALVALUE = 0, YEARBUILT = 0, 
 BEDROOMS = 99, Fullbath = 99, halfbath = 99 
*/
UPDATE nashville_property
SET halfbath = 99
WHERE halfbath = "";

# Now, I want to create a replica of each of the column with their respective Datatype.
ALTER TABLE nashville_property
ADD (new_acreage DECIMAL (5,2), new_landvalue integer, new_buildingvalue integer,
new_Totalvalue integer, new_yearbuilt integer, new_bedrooms integer, new_fullbath integer,
new_halfbath integer);

-- NOTE; Now, I will copy all the values in the old columns to their respective new column
UPDATE nashville_property
SET NEW_acreage = acreage;

-- I want to correct the saleprice datatype
ALTER TABLE nashville_property
MODIFY COLUMN saleprice int;
/* It throw an error saying this  " Error Code: 1265. Data truncated for column 'New_saleprice' at row 188", 
 so it was from their I notice I have some wrong input in my Saleprice column, However most of my values are 6 digits.
 What I did now is to check which of my column has more than 6 digit using the code below  */

select * from nashville_property
WHERE LENGTH(SALEPRICE) > 6;
-- it shows I have some value which contain a comma and a dollar sign

select * from nashville_property
where saleprice  REGEXP ","OR "$";

/* so, after using REGEXP to find the values in this dataset, these are what I saw in the column saleprice
 $120,000     $362,500,  159,900  $195,500  $1,124,900   $195,000  119,000  $178,500     35,000  
 Now, the next thing is to replace them, so that we will be able to change saleprice to integer datatype */
 
UPDATE nashville_property
SET saleprice = 120000
where saleprice = "$120,000";

/* In the process of updating my value, I encountered another problem which made me know that, there is probably
some whitespace in my Value, so I thought of using LENGTH fnct to know the number of value I have in my saleprice column
*/
SELECT LENGTH(SalePrice), SALEPRICE, PropertyAddress FROM nashville_property
WHERE SalePrice LIKE "$%" OR "%,%";

-- Having know the values in my Saleprice, the next is to update my saleprice and correct those errors.
UPDATE nashville_property
SET SalePrice = 1124900
WHERE SalePrice = "$1,124,900 ";

-- Now, I need to verify if I have removed all the figures with $ and ,
SELECT LENGTH(SalePrice), SALEPRICE, PropertyAddress FROM nashville_property
WHERE SalePrice LIKE "$%" OR "%,%";

-- This shows I don't have any value with $ and , again, so I can nw modify my table and correct the Datatype
ALTER TABLE nashville_property
MODIFY COLUMN saleprice int;

-- It throw another error again, so what I want to do now is to check all the columns that contain any character different from 0-9
SELECT *
FROM nashville_property
WHERE saleprice REGEXP '[^0-9]';

-- Now,I want to check their length
Select LENGTH(Saleprice), saleprice FROM nashville_property
WHERE saleprice REGEXP '[^0-9]';
-- 119,000   35,000

-- It's time to update the value and correct those errors.
UPDATE nashville_property
SET SalePrice = 35000
WHERE SalePrice = "35,000";

-- Let's verify
SELECT *
FROM nashville_property
WHERE saleprice REGEXP '[^0-9]';

-- It's time to update the datatype
ALTER TABLE nashville_property
MODIFY COLUMN saleprice int;      -- It has updated successfully 

/* NOW, I want to correct the Saledate datatype date column also, so I will create a new column called new_saledate, 
 then I will make this to be in Date datatype. */

ALTER TABLE nashville_property
ADD new_saledate date;

-- The initial date is in the form DD-MMM-YYY, but I need to convert the date from dd-mmm-yy to yyyy-mm-dd
UPDATE nashville_property
SET new_saledate = STR_TO_DATE(saledate, '%d-%b-%y');

-- Now we create a view for our new columns
CREATE VIEW NashvilleProperty
AS
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, new_saledate, saleprice, LegalReference, SoldASVacant, ownername,
owneraddress, new_acreage, TaxDistrict, new_buildingvalue, new_landvalue, new_Totalvalue, New_yearbuilt, new_bedrooms,
new_fullbath, new_halfbath
FROM Nashville_property;

-- Checking my View
SELECT * FROM nashvilleproperty;

/* Now, I want to find the average of each of the columns and fix them in the value, I used in replacing the empty records
Acreage = 99.99,    Landvalue = 0,  Buildingvalue = 1, TOTALVALUE = 0, YEARBUILT = 0, 
 BEDROOMS = 99, Fullbath = 99, halfbath = 99 */

SELECT ROUND(AVG(new_LandValue),2) FROM nashville_property WHERE Landvalue <> 0;  -- 69068.56 
SELECT ROUND(AVG(new_halfbath),2) FROM nashville_property WHERE new_halfbath <> 99; -- 0.28; 
SELECT ROUND(AVG(new_fullbath),2) FROM nashville_property WHERE new_fullbath <> 99;  -- 1.89 
SELECT ROUND(AVG(new_bedrooms),2) FROM nashville_property WHERE new_bedrooms <> 99;  -- 3.09 
SELECT ROUND(AVG(new_totalValue),2) FROM nashville_property WHERE new_Totalvalue <> 0;  -- 232375.40 
SELECT ROUND(AVG(new_buildingvalue),2) FROM nashville_property WHERE new_buildingvalue <> 1;  -- 160784.68 
SELECT ROUND(AVG(Acreage),2) FROM nashville_property WHERE new_acreage <> 99.99;  -- 0.5


/* Now, what I need do is to use ALTER statement to replace my values with their respective averages */
UPDATE nashville_property
SET new_acreage = 0.5
where new_acreage = 99.99;

-- Now, it's time to change the column names in our views
CREATE OR REPLACE VIEW Nashvilleproperty AS
SELECT 
	UniqueID, ParcelID, LandUse, PropertyAddress, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, TaxDistrict,
    new_buildingvalue AS buildingvalue,
    new_landvalue     AS landvalue,
    new_totalvalue    AS Totalvalue,
    New_yearbuilt     AS Yearbuilt,
    new_bedrooms      AS Bedrooms,
    new_fullbath      AS fullbath,
    new_halfbath      AS Halfbath,
    new_saledate      AS Saledate,
    new_acreage       AS Acreage
FROM nashville_property;

SELECT * FROM nashvilleproperty;


-- ANALYSIS
