--/*

--Cleaning Data in SQL Queries

--/*

select*
from PortfolioProject..NashvilleHousing$


-----------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing$

alter table NashvilleHousing$
add SaleDateConverted Date;

update NashvilleHousing$
set SaleDateConverted = convert(date,SaleDate)

----------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from PortfolioProject..NashvilleHousing$
where PropertyAddress is Null
order by ParcelID

-- Self-join the table

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,IsNull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing$ a
join PortfolioProject..NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is Null

update a
set PropertyAddress = IsNull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing$ a
join PortfolioProject..NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is Null

--------------------------------------------------------------------------------

-- Breaking down Address into Individual Columns (Address, City, State)

-- 1. Property Address

select PropertyAddress
from PortfolioProject..NashvilleHousing$
--where PropertyAddress is Null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing$

alter table NashvilleHousing$
add PropertySplitAddress nvarchar(255);

update NashvilleHousing$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing$
add PropertySplitCity nvarchar(255);

update NashvilleHousing$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing$


-- 2. Ownner Address

select OwnerAddress
from PortfolioProject..NashvilleHousing$


select
PARSENAME(replace(OwnerAddress, ',', '.'),3)
,PARSENAME(replace(OwnerAddress, ',', '.'),2)
,PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject..NashvilleHousing$


alter table NashvilleHousing$
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing$
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing$
add OwnerSplitCity nvarchar(255);

update NashvilleHousing$
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing$
add OwnerSplitState nvarchar(255);

update NashvilleHousing$
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)


select *
from PortfolioProject..NashvilleHousing$

------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count (SoldAsVacant)
from PortfolioProject..NashvilleHousing$
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject..NashvilleHousing$


update NashvilleHousing$
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END

-----------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Writing CTE

WITH RowNumCTE AS (
select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing$
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing$

ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress


------------------------------------------------------------------------------------------------------