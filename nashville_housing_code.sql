-- This SQL query selects all columns from the 'nashville_housing' table, 
-- but limits the result to the first 100 records. 
-- It's useful for getting a quick overview of the data without loading the entire table.

SELECT *
FROM nashville_housing
LIMIT 100;

-- This SQL query retrieves the column names and their respective data types 
-- for the 'nashville_housing' table from the information_schema.columns view. 
-- This is useful to understand the structure and data types of the table.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'nashville_housing';

-- This SQL query selects all records from the 'nashville_housing' table 
-- where the 'propertyaddress' column is NULL. 
-- This can be used to identify records with missing address information.
SELECT *
FROM nashville_housing
WHERE propertyaddress IS NULL;


-- This SQL query updates the 'nashville_housing' table. For each record 'a' in the table where the 'propertyaddress' is NULL, 
-- it sets 'a.propertyaddress' to the 'propertyaddress' of another record 'b' in the same table with the same 'parcelid', 
-- a different 'uniqueid', and a non-null 'propertyaddress'. 
-- As a result, it effectively fills missing 'propertyaddress' values with existing 'propertyaddress' values from different 
-- records with the same 'parcelid'.

UPDATE nashville_housing a
SET propertyaddress = b.propertyaddress
FROM nashville_housing b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL
AND b.propertyaddress IS NOT NULL;


-- This block of code selects two substrings from the `propertyaddress` column:
-- `address` - the substring from the beginning of `propertyaddress` to the character before the first comma,
-- `state` - the substring from the first character after the first comma to the end of `propertyaddress`.
SELECT 
SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) -1) AS address,
SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1 FOR LENGTH(propertyaddress)) AS state
FROM nashville_housing;


-- This statement adds a new column `address` of type VARCHAR(255) to the `nashville_housing` table.
ALTER TABLE nashville_housing
ADD address VARCHAR(255);

-- This statement adds a new column `city` of type VARCHAR(255) to the `nashville_housing` table.
ALTER TABLE nashville_housing
ADD city VARCHAR(255);

-- This statement updates the `address` column in the `nashville_housing` table with the substring from the `propertyaddress` 
-- starting at the beginning of `propertyaddress` and ending at the character before the first comma.
UPDATE nashville_housing
SET address = SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress)-1);


-- This statement updates the `city` column in the `nashville_housing` table with the substring from the `propertyaddress` 
-- starting at the first character after the first comma and continuing to the end of the string.
UPDATE nashville_housing
SET city = SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress)+1 FOR LENGTH(propertyaddress));

-- Adding new columns (owner_address, owner_city, owner_state) to the 'nashville_housing' table
ALTER TABLE nashville_housing
ADD owner_address VARCHAR(255),
ADD owner_city VARCHAR(255),
ADD owner_state VARCHAR(255);

-- Updating the newly added columns with respective parts of the 'owneraddress' column
-- 'owner_address' is set to the part before the first comma in 'owneraddress'
-- 'owner_city' is set to the part between the first and second comma in 'owneraddress'
-- 'owner_state' is set to the part after the second comma in 'owneraddress'
UPDATE nashville_housing
SET owner_address = SPLIT_PART('owneraddress', ',', 1),
	owner_city = SPLIT_PART('owneraddress', ',', 2),
	owner_state = SPLIT_PART('owneraddress', ',', 3);
	
	
SELECT soldasvacant,
CASE
	WHEN soldasvacant = 'N' THEN 'NO'
	WHEN soldasvacant = 'Y' THEN 'YES'
	ELSE soldasvacant
	END
FROM nashville_housing;

-- Updating the 'nashville_housing' table
UPDATE nashville_housing
SET soldasvacant = CASE 
						-- When the value of 'soldasvacant' is 'N', change it to 'No'
						WHEN soldasvacant = 'N' THEN 'No'
						-- When the value of 'soldasvacant' is 'Y' change it to 'Yes'
						WHEN soldasvacant = 'Y' THEN 'Yes'
						-- For other values, keep them as they are
						ELSE soldasvacant
						END;
						

-- This block of code deletes duplicate records in the `nashville_housing` table.
-- A record is considered duplicate if the `parcelid`, `propertyaddress`, `saleprice`, `saledate` and `legalreference` are identical to another record.
-- Among duplicates, the record with the lower `uniqueid` is kept, others are deleted.

DELETE FROM nashville_housing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM (
        SELECT uniqueid,
            ROW_NUMBER() OVER (
                PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
                ORDER BY uniqueid
            ) AS row_num
        FROM nashville_housing
    ) t
    WHERE t.row_num > 1
);


-- This block of code creates a temporary table called `RowNumCTE` that includes a new column `row_num`. This column gives a unique number to each record within each group of duplicates.
-- Then it selects all the records from `RowNumCTE` where `row_num` is greater than 1, i.e., all but one record from each group of duplicates. These records are ordered by `propertyaddress`.

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
            ORDER BY uniqueid
        ) AS row_num
    FROM nashville_housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress;

-- Dropping column 'OwnerAddress' from the table 'nashville_housing'
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;

-- Dropping column 'TaxDistrict' from the table 'nashville_housing'
ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict;

-- Dropping column 'PropertyAddress' from the table 'nashville_housing'
ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress;

-- Dropping column 'SaleDate' from the table 'nashville_housing'
ALTER TABLE nashville_housing
DROP COLUMN SaleDate;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'nashville_housing';

















