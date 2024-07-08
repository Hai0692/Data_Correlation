/* cleaning data in sql */

select *
from [Housing Data]..nashvilleHousing

---------------------------------------------------
--standard date format
select SaleDateConvered, convert(Date, saleDate)
from [Housing Data]..nashvilleHousing

update nashvilleHousing
set SaleDate = convert(Date, saleDate)


alter table nashvilleHousing
Add SaleDateConvered Date;

update nashvilleHousing
set SaleDateConvered = convert(Date, saleDate)

------------------------------------------------------------
--property address data
select *
from [Housing Data]..nashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull( a.PropertyAddress,b.PropertyAddress)
from [Housing Data]..nashvilleHousing a
join [Housing Data]..nashvilleHousing b
     on  a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,'No address')
from [Housing Data]..nashvilleHousing a
join [Housing Data]..nashvilleHousing b
      on  a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------
--breaking out address into individual  columns (address, city,state)
select PropertyAddress
from [Housing Data]..nashvilleHousing
--order by ParcelID

select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from [Housing Data]..nashvilleHousing

alter table nashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update nashvilleHousing
set PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table nashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update nashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from [Housing Data]..nashvilleHousing

--breaking out address of Owner into individual  columns (address, city,state)
select OwnerAddress
from [Housing Data]..nashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Housing Data]..nashvilleHousing


alter table nashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update nashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


alter table nashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update nashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashvilleHousing
Add OwnerSplitSate Nvarchar(255);

Update nashvilleHousing
set OwnerSplitSate = PARSENAME(replace(OwnerAddress,',','.'),1)


-----------------------------------------------------------
--change Y and N to Yes and No in "Sold in Vacant" 

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Housing Data]..nashvilleHousing
Group by SoldAsVacant
order by 2



select SoldAsVacant
,case when  SoldAsVacant = 'Y' Then 'Yes'
      when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   end
from [Housing Data]..nashvilleHousing


UPDATE [Housing Data]..nashvilleHousing
SET SoldAsVacant = case when  SoldAsVacant = 'Y' Then 'Yes'
                        when SoldAsVacant = 'N' Then 'No'
	                    else SoldAsVacant
	                    end

--------------------------------------------------------------
--remove duplicate

with RowNumCTE as(
select *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					order by UniqueID
	   )row_num
from [Housing Data]..nashvilleHousing
)
delete 
from RowNumCTE
where row_num >1
--order by PropertyAddress


with RowNumCTE as(
select *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					order by UniqueID
	   )row_num
from [Housing Data]..nashvilleHousing
)
select * 
from RowNumCTE
where row_num >1
--order by PropertyAddress



---------------------------------------------------------------------------
--delete unused columns 

select *
from [Housing Data]..nashvilleHousing

alter table [Housing Data]..nashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table [Housing Data]..nashvilleHousing
drop column SaleDate














