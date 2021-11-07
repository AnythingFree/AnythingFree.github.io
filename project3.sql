select *
from nd;


UPDATE ND C
    SET CUST_ID = (SELECT MAX(C2.CUST_ID)
                   FROM CUST_VW C2
                   WHERE C.REQUEST_NUM = C2.REQUEST_NUM AND
                          C2.CUST_ID IS NOT NULL
                  )
    WHERE CUST_ID IS NULL ; 


select 
substr(OwnerAddress,1,instr(OwnerAddress, ',')-1) as Adress,
substr(OwnerAddress,instr(OwnerAddress, ',')+1, instr(OwnerAddress, ',',-1,1)-instr(OwnerAddress, ',')-1) as Adress,
substr(OwnerAddress,instr(OwnerAddress, ',',-1,1)+1,length(OwnerAddress)-instr(OwnerAddress, ',',-1,1)) as Adress
from nd;

alter table nd
add OwnerSplitAddress varchar2(255);

update nd
set OwnerSplitAddress = substr(OwnerAddress,1,instr(OwnerAddress, ',')-1);

alter table nd
add OwnerSplitCity varchar2(255);

update nd
set OwnerSplitCity = substr(OwnerAddress,instr(OwnerAddress, ',')+1, instr(OwnerAddress, ',',-1,1)-instr(OwnerAddress, ',')-1);

alter table nd
add OwnerSplitState varchar2(255);

update nd
set OwnerSplitState = substr(OwnerAddress,instr(OwnerAddress, ',',-1,1)+1,length(OwnerAddress)-instr(OwnerAddress, ',',-1,1));

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from nd
group by soldasvacant
order by 2;


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from nd;

Update nd
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end;

--get rid of duplicates

with rowNumCTE as (
select ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference,
    ROW_NUMBER() OVER (
        partition by ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    order by 
                        UniqueID
                    ) as row_num 
from nd
)
select *
from rowNumCTE
where row_num>1;



delete
from rowNumCTE
where (row_num>1)
in (with rowNumCTE as (
select ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference,
    ROW_NUMBER() OVER (
        partition by ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    order by 
                        UniqueID
                    ) as row_num 
from nd
)
);






--


--delete unused columns

select *
from nd;

alter table nd
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;














