-- =============================================
-- Author:		Dai Nguyen
-- Create date: 6/11/2014
-- Description:	Resolve Item
-- =============================================

declare	@input_item	nvarchar(50) = 'ac393',
		@customer_id decimal = 119492

declare	@inv_mast_uid	int = 0,
		@item_id		nvarchar(50) = ''

if (@customer_id <> 0)
begin
	-- assume input is customer part number
	goto customer;
end

if (@inv_mast_uid = 0)
begin
	goto supplier;
end

goto finish;

customer:	
	select	top 1
			@inv_mast_uid = m.inv_mast_uid,
			@item_id = m.item_id
	from	p21_view_inv_xref r
			join p21_view_customer c on r.customer_id = c.customer_id
			join p21_view_inv_mast m on r.inv_mast_uid = m.inv_mast_uid
	where	r.delete_flag = 'N'
			and c.delete_flag = 'N'
			and m.delete_flag = 'N'
			and r.customer_id = @customer_id
			and r.their_item_id = @input_item

supplier:
	select	top 1
			@inv_mast_uid = m.inv_mast_uid,
			@item_id = m.item_id
	from	p21_view_inventory_supplier ivs
			join p21_view_supplier s on ivs.supplier_id = s.supplier_id
			join p21_view_inv_mast m on ivs.inv_mast_uid = m.inv_mast_uid
	where	m.delete_flag = 'N'
			and ivs.delete_flag = 'N'
			and s.delete_flag = 'N'
			and ivs.supplier_part_no = @input_item

finish:
	if (isnull(@inv_mast_uid, 0) <> 0)
	begin
		select	inv_mast_uid = @inv_mast_uid,
				item_id = @item_id
	end
	else
	begin
		select	top 1
				inv_mast_uid,
				item_id
		from	p21_view_inv_mast
		where	item_id = @input_item
				and delete_flag = 'N'
	end