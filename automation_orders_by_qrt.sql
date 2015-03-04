-- =============================================
-- Author:		Dai Nguyen
-- Create date: 2/10/2015
-- Description:	Automation Orders history by quarter
-- =============================================

declare @results table
(
	yr	int,
	q1	decimal (19, 2),
	q2	decimal (19, 2),
	q3	decimal (19, 2),
	q4	decimal (19, 2)
)

declare @m1From char(2) = '01',
		@m1To	char(2) = '03',
		@m2From	char(2) = '04',
		@m2To	char(2) = '06',
		@m3From	char(2) = '07',
		@m3To	char(2) = '09',
		@m4From	char(2) = '10',
		@m4To	char(2) = '12';

declare @year int = 2008;

while (@year <= 2015)
begin
	
	declare @q1From int = convert(int, concat(@year, @m1From)),
			@q1To	int = convert(int, concat(@year, @m1To)),
			@q2From int = convert(int, concat(@year, @m2From)),
			@q2To	int = convert(int, concat(@year, @m2To)),
			@q3From int = convert(int, concat(@year, @m3From)),
			@q3To	int = convert(int, concat(@year, @m3To)),
			@q4From int = convert(int, concat(@year, @m4From)),
			@q4To	int = convert(int, concat(@year, @m4To));
	
	insert into @results
		select	@year,
				q1 = sum
				(
					case when datepart(year, h.order_date) * 100 + datepart(month, h.order_date) between @q1From and @q1To
							then l.extended_price							
						 else 0
					end
				),								
				q2 = sum
				(
					case when datepart(year, h.order_date) * 100 + datepart(month, h.order_date) between @q2From and @q2To 
							then l.extended_price
						 else 0
					end
				),	
				q3 = sum
				(
					case when datepart(year, h.order_date) * 100 + datepart(month, h.order_date) between @q3From and @q3To 
							then l.extended_price
						 else 0
					end
				),	
				q4 = sum
				(
					case when datepart(year, h.order_date) * 100 + datepart(month, h.order_date) between @q4From and @q4To 
							then l.extended_price
						 else 0
					end
				)
		from	p21_view_oe_hdr h
				join p21_view_oe_line l on h.order_no = l.order_no
				join p21_view_inv_loc loc on l.inv_mast_uid = loc.inv_mast_uid
				join supplier_ud (nolock) ud on loc.primary_supplier_id = ud.supplier_id					
				and loc.primary_supplier_id not in (112923, 100299)
		where	h.projected_order = 'N'
				and h.delete_flag = 'N'
				and isnull(h.cancel_flag, 'N') = 'N'
				and isnull(h.rma_flag, 'N') = 'N'
				and l.delete_flag = 'N'
				and isnull(l.cancel_flag, 'N') = 'N'
				and isnull(l.disposition, '') <> 'C'
				and loc.location_id = 1 
				and isnull(ud.supplier_automation, 'N') = 'Y'
				and datepart(year, h.order_date) * 100 + datepart(month, h.order_date) between @q1From and @q4To						
	
	set @year = @year + 1;
end

select	*
from	@results
