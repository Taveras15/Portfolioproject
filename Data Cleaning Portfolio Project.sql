/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
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
  FROM [PortfolioProject].[dbo].['Nashville Housing$']

  --SQL Data CLeaning
  select * from PortfolioProject..Sheet1$

  --Standarize Data Format
  select SaleDateConverted, CONVERT(Date,SaleDate) from PortfolioProject..Sheet1$

  update Sheet1$ SET SaleDate = CONVERT(Date,SaleDate)

  select SaleDate From PortfolioProject..Sheet1$

  Alter Table Sheet1$ add SaleDateConverted Date;

  Update Sheet1$ Set SaleDateConverted= CONVERT(Date,SaleDate)

  --Populate Property Address Data

  select * from PortfolioProject..Sheet1$ 
  --where PropertyAddress is null
  Order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Sheet1$ a
JOIN PortfolioProject..Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> a.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Sheet1$ a
JOIN PortfolioProject..Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> a.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

 select PropertyAddress from PortfolioProject..Sheet1$ 
  --where PropertyAddress is null
  --Order by ParcelID

  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
  From PortfolioProject..Sheet1$

  Alter Table Sheet1$ add PropertySplitAddress Nvarchar(255);

  Update Sheet1$ Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  Alter Table Sheet1$ add PropertySplitCity Nvarchar(255);

  Update Sheet1$ Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
  
  Select * from PortfolioProject..Sheet1$

  Select OwnerAddress from PortfolioProject..Sheet1$

  Select 
  Parsename(Replace(OwnerAddress, ',', '.'),3),
  Parsename(Replace(OwnerAddress, ',', '.'),2),
  Parsename(Replace(OwnerAddress, ',', '.'),1)
  From PortfolioProject..Sheet1$

  
  Alter Table Sheet1$ add OwnerSplitAddress Nvarchar(255);

  Update Sheet1$ Set OwnerSplitAddress= Parsename(Replace(OwnerAddress, ',', '.'),3)

  Alter Table Sheet1$ add OwnerSplitState Nvarchar(255);

  Update Sheet1$ Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'),2)

  Select * from PortfolioProject..Sheet1$

  --Changing Y and N to Yes and No

  Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject..Sheet1$
  Group by SoldAsVacant
  Order by 2

  Select SoldAsVacant
  , CASE When SoldAsVacant= 'Y' THEN 'Yes'
  When SoldAsVacant= 'N' Then 'No'
  ELSE SoldAsVacant
  END
  From PortfolioProject..Sheet1$

  UPDATE Sheet1$
  SET SoldAsVacant= CASE When SoldAsVacant= 'Y' THEN 'Yes'
  When SoldAsVacant= 'N' Then 'No'
  ELSE SoldAsVacant
  END

  --Remove Duplicates from Data
  With RowNumCTE AS(
  Select *,
  ROW_NUMBER() Over(
  Partition BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order By
					UniqueID
					) row_num 
From PortfolioProject..Sheet1$
--Order By ParcelID
)
Delete from RowNumCTE
Where row_num > 1

With RowNumCTE AS(
  Select *,
  ROW_NUMBER() Over(
  Partition BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order By
					UniqueID
					) row_num 
From PortfolioProject..Sheet1$
--Order By ParcelID
)
Select * from RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Deleting Unused Columns 

Alter table PortfolioProject..Sheet1$
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Alter table PortfolioProject..Sheet1$
Drop Column SaleDate

Select * From PortfolioProject..Sheet1$