--Cleaning Data in SQL

Select * 
From Portfolio.dbo.NashvilleHousing

--Select SaleDateConverted, CONVERT(Date, SaleDate)
--From Portfolio..NashvilleHousing

--Update NashvilleHousing
--Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)

--Populate Property Address

--Finds Property addresses filled with NULL and the correct address
Select A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Fills Property addresses with the correct address
Update A
set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Breaking Address into individual columns(address, city, state)
--Selects part of address separated by the comma, -1 Removes one char which is the comma in this case
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

Select *
From Portfolio.dbo.NashvilleHousing

--Break Owners Address in different columns
Select OwnerAddress
From Portfolio..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From Portfolio.dbo.NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant"
--Using CASE

Select Distinct(SoldAsVacant)
From Portfolio..NashvilleHousing

Select SoldAsVacant, 
CASE When SoldAsVacant ='Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From Portfolio..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From Portfolio..NashvilleHousing

--Remove Duplicates
;WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Portfolio..NashvilleHousing
--Order By ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

Select *
From Portfolio.dbo.NashvilleHousing

--Delete Unused Columns

Alter Table Portfolio.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict