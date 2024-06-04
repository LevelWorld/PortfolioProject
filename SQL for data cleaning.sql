-- The purpose of the file is to show compentency in data cleaning using SQL

-- Standartize Date format
SELECT SalesDate, Convert(Date, SaleDate)
From Projects..NashvilleHousing

update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table  NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)


update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

-- Populate Propert Address data

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From Projects..NashvilleHousing A
JOIN Projects..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> b.[UniqueID ]
Where A.PropertyAddress is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From Projects..NashvilleHousing A
JOIN Projects..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> b.[UniqueID ]

--Breaking out Address into Indivudal Columns (Address, City, State)

SELECT PropertyAddress
From Projects..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))  as City

From Projects..NashvilleHousing

Alter Table  NashvilleHousing
add PropertySplitAddress  Nvarchar(255);


update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

Alter Table  NashvilleHousing
add PropertySplitCity Nvarchar(255);


update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitCity, PropertySplitAddress
From Projects..NashvilleHousing

-- Another strategy for the same objective for a different Column

Alter Table  NashvilleHousing
add Owner_PropertySplitAddress  Nvarchar(255);


update NashvilleHousing
Set Owner_PropertySplitAddress = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table  NashvilleHousing
add Owner_PropertySplitCity Nvarchar(255);


update NashvilleHousing
Set Owner_PropertySplitCity = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table  NashvilleHousing
add Owner_PropertySplitState Nvarchar(255);


update NashvilleHousing
Set Owner_PropertySplitState = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)

-- Change 'Y' and 'N' to 'Yes', and 'No' in 'Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVAcant)
From Projects..NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
,	CASE when SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'NO'
		 ELSE SoldAsVacant
		 END
From Projects..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant =	CASE when SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'NO'
		 ELSE SoldAsVacant
		 END
-- Remove Dupilcates

WITH RowNumCTE as ( 
SELECT *,
	ROW_NUMBER() OVER (	
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num
From Projects..NashvilleHousing
)
SELECT *
FROM RowNumCTE 
Where row_num > 1
order by PropertyAddress

-- Delete unused Columns
Alter Table Projects..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

