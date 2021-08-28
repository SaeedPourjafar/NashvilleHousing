SELECT TOP(10) * FROM PortfolioProject..NashvilleHousing
SELECT SaleDate FROM PortfolioProject..NashvilleHousing

-- Since all SaleDate are literally a date and not a datetime, so let's convert it to date
ALTER TABLE NashvilleHousing
ADD SDConverted DATE

UPDATE NashvilleHousing
SET SDConverted = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

EXEC sp_rename 'NashvilleHousing.SDConverted', 'SaleDate', 'COLUMN' -- Renaming the column

-- Imputing the NULLs in PropertyAddress using self join
SELECT *
FROM NashvilleHousing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT n1.ParcelID, 
	n1.PropertyAddress,
	n2.ParcelID,
	n2.PropertyAddress,
	ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
ON n1.ParcelID = n2.ParcelID
AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL

UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
ON n1.ParcelID = n2.ParcelID
AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL

SELECT COUNT(PropertyAddress) 
FROM NashvilleHousing 
WHERE PropertyAddress IS NULL

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- An easier way to substring address
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) Address,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) City,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Changing Y/N to Yes/No
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant 
		END
FROM PortfolioProject..NashvilleHousing

-- Removing duplicates
WITH TempRowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[PropertySplitAddress]
      ,[PropertySplitCity]
      ,[OwnerSplitAddress]
      ,[OwnerSplitCity]
      ,[OwnerSplitState]
	ORDER BY UniqueID) Dup
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM TempRowNumCTE 
WHERE Dup > 1

-- Deleting unused columns
ALTER TABLE PortfolioProject.. NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress