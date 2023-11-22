CREATE TABLE Nashville_property (UniqueID VARCHAR(85) NULL, ParcelID VARCHAR(85)  NULL,	
LandUse VARCHAR(45) NULL,   PropertyAddress VARCHAR(45) NULL,SaleDate VARCHAR(85) NULL, 	SalePrice VARCHAR(85) NULL,
	LegalReference VARCHAR(85) NULL,	SoldAsVacant VARCHAR(85) NULL,	OwnerName VARCHAR(85) NULL,	OwnerAddress VARCHAR(85) NULL,	
    Acreage VARCHAR(80) NULL,	TaxDistrict VARCHAR(85),	LandValue VARCHAR(85) NULL,	BuildingValue VARCHAR(85) NULL,
	TotalValue VARCHAR(45) NULL, YearBuilt VARCHAR(45) NULL,	Bedrooms VARCHAR(45) NULL,	FullBath VARCHAR(85) NULL,	
    HalfBath VARCHAR(45) NULL);

SELECT * FROM nashville_propertY;
 -- we have 56,477 records in our dataset
/* We want to count the number of  emptyrows we have in our dataset 
Parcelid   (0), Landuse  (0),    propertyaddress  (29), saledate   (0),  saleprice  (0),   legalreference     (0),    Soldasvacant  (0)
Ownername     (31,216),owneraddress   (30,462) Acreage (30,462), Taxdistrict  (30,462), landvalue (30,462), buildingvalue     (30,462), 
totalvalue (30,462),     yearbuilt   (32,314),     bedrooms   (32,320)  ,   fullbath      (32,202),     halfbath (32,333)
*/

# we need to chek if our empty row is greater than 40%
SELECT (30462/56477)*100 AS EMPTY_ROW_PERCENT;   # = 53.9370%

-- NOW WE WILL NEED TO REPLACE THE EMPTY RECORDS WITH NOT AVAILABLE
UPDATE nashville_property
SET taxdistrict  = 'N/A'
WHERE taxdistrict = "";

/* The next is to replace the digit columns with a value which doesnot exist in that particular column
so, to be able to do this, I will use a unique value which isn't existing in the columns to replace the empty records.
After having checked, I set gthe columns to the following numbers
 Acreage = 99.99,    Landvalue = 0,  Buildingvalue = 1, TOTALVALUE = 0, YEARBUILT = 0, 
 BEDROOMS = 99, Fullbath = 99, halfbath = 99 
*/

SELECT * FROM nashville_property
WHERE fullbath = 99;

UPDATE nashville_property
SET halfbath = 99
WHERE halfbath = "";

SELECT * FROM nashville_property;

# Now, I want to change my column datatype to their respective datatypes after having cleaned it.

ALTER TABLE nashville_property
ADD (NEW_ownername VARCHAR (85), new_acreage DECIMAL (5,2), new_landvalue integer, new_buildingvalue integer,
new_Totalvalue integer, new_yearbuilt integer, new_bedrooms integer, new_fullbath integer,
new_halfbath integer);

ALTER TABLE nashville_property
ADD NEW_ownername VARCHAR (85);

-- note; In the process of copying my values into the acreage, I encountered a problem 
UPDATE nashville_property
SET NEW_ownername = Ownername;

-- NOW, I want to correct the date column also, so I will create a new column called new_saledate, 
-- then I will make this to be in Date datatype.
ALTER TABLE nashville_property
ADD new_saledate date;

-- Now, let's update the new table with the values from the previous date
UPDATE nashville_property
SET new_saledate = STR_TO_DATE(saledate, '%Y-%m-%d');

-- Add a new column with the DATE datatype
ALTER TABLE your_table
ADD new_date_column DATE;

-- convert the date from dd-mmm-yy to 
UPDATE nashville_property
SET new_saledate = STR_TO_DATE(saledate, '%d-%b-%y');

Select * from nashville_property;

-- Now we create a view for our new columns
CREATE VIEW NashvilleProperty
AS
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, new_saledate, saleprice, LegalReference, SoldASVacant, ownername,
owneraddress, new_acreage, TaxDistrict, new_buildingvalue, new_landvalue, new_Totalvalue, New_yearbuilt, new_bedrooms,
new_fullbath, new_halfbath
FROM Nashville_property;

SELECT * FROM nashvilleproperty;

/* Now, I want to find the average of each of the columns and fix them in the value, I used in replacing the empty records
Acreage = 99.99,    Landvalue = 0,  Buildingvalue = 1, TOTALVALUE = 0, YEARBUILT = 0, 
 BEDROOMS = 99, Fullbath = 99, halfbath = 99 */

SELECT ROUND(AVG(new_LandValue),2) FROM nashville_property WHERE Landvalue <> 0;  -- 69,068.56  d
SELECT ROUND(AVG(new_halfbath),2) FROM nashville_property WHERE new_halfbath <> 99; -- 0.28; d
SELECT ROUND(AVG(new_fullbath),2) FROM nashville_property WHERE new_fullbath <> 99;  -- 1.89 d
SELECT ROUND(AVG(new_bedrooms),2) FROM nashville_property WHERE new_bedrooms <> 99;  -- 3.09 d
SELECT ROUND(AVG(new_totalValue),2) FROM nashville_property WHERE new_Totalvalue <> 0;  -- 232,375.40 d
SELECT ROUND(AVG(new_buildingvalue),2) FROM nashville_property WHERE new_buildingvalue <> 1;  -- 160,784.68 d
SELECT ROUND(AVG(Acreage),2) FROM nashville_property WHERE new_acreage <> 99.99;  -- 0.5

SELECT* FROM nashville_property  where new_acreage = 99.99;
/* Now, what I need do is to use ALTER statement to replace my values with their respective averages */
UPDATE nashville_property
SET new_acreage = 0.5
where new_acreage = 99.99;

SELECT * FROM nashvilleproperty; 


