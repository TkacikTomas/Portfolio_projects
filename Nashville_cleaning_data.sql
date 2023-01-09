SELECT *
FROM nashville


Select saleDate, CAST(saledate AS date)
From nashville

ALTER TABLE nashville
Add SaleDateConverted Date;

Update nashville
SET SaleDateConverted = CAST(saledate AS date)

---------------------------------------
Select *
From nashville
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
From nashville a
JOIN nashville b
	on a.ParcelID = b.ParcelID
	AND a.uniqueid <> b.uniqueid
WHERE a.uniqueid=15886

ALTER TABLE nashville
Add propertyaddresscleaned varchar;

Update nashville
SET propertyaddresscleaned = COALESCE(a.PropertyAddress,b.PropertyAddress)
From nashville a
JOIN nashville b
	on a.ParcelID = b.ParcelID
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
---------------------------------------------------------------------------
--Breaking out propertyAddress into Individual Columns (Address, City)

SELECT 
	propertyaddress,
	SUBSTRING(propertyaddress, 1, POSITION('.' IN propertyaddress)-1),
	SUBSTRING(propertyaddress, POSITION('.' IN propertyaddress)+1, LENGTH(propertyaddress))
FROM nashville

ALTER TABLE nashville
Add PropertySplitAddress VARCHAR;

Update nashville
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, POSITION('.' IN propertyaddress)-1)


ALTER TABLE nashville
Add PropertySplitCity VARCHAR;

Update nashville
SET PropertySplitCity = SUBSTRING(propertyaddress, POSITION('.' IN propertyaddress)+1, LENGTH(propertyaddress))

SELECT *
FROM nashville

--------------------------------------------------------------------
--Breaking out ownerAddress into Individual Columns (Address, City,state)

SELECT 
	owneraddress,
	SUBSTRING(owneraddress, 1, POSITION('.' IN owneraddress)-1),
	SPLIT_PART(owneraddress, '.', 2),
	SPLIT_PART(owneraddress, '.', 3)
FROM nashville


-------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT 
	soldasvacant,
	CASE WHEN soldasvacant='N' THEN 'No'
		 WHEN soldasvacant='Y' THEN 'Y'
		 ELSE soldasvacant
	END
FROM nashville

