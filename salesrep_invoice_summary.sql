-- =============================================
-- Author:		Dai Nguyen
-- Create date: 2/26/2015
-- Description:	salesrep invoices summary
-- =============================================

declare @type nvarchar(10) = 'monthly' -- 'daily'
declare @salesrep_id nvarchar(10) = '1002'

declare @now date = getdate();

declare @year varchar(4) = convert(varchar(4), datepart(year, @now));
declare @month varchar(2) = (case when datepart(month, @now) < 10 then concat('0', datepart(month, @now)) else convert(varchar(2), datepart(month, @now)) end);

declare @start datetime = case when @type = 'monthly' then convert(date, concat(@year, @month, '01')) else @now end;


select	curr = sum(case when s.invoice_date >= @start then
			case when (s.invoice_line_type = 0 and s.order_type = 1706) then s.sales_price_home
				 when (s.invoice_line_type = 0 and s.invoice_line_uid_parent = 0 and s.oe_line_assembly <> 'N') then s.assembly_sales_price_home
				 else s.sales_price_home 
			end
		end),
		cur_count = count(distinct case when s.invoice_date >= @start and s.sales_price_home >= 0 then s.order_no end) - count(distinct case when s.invoice_date >= @start and s.sales_price_home < 0 then s.order_no end),
		cur_customer_count = count(distinct case when s.invoice_date >= @start then s.customer_id end),
		prev = sum(case when s.invoice_date < @start then
			case when (s.invoice_line_type = 0 and s.order_type = 1706) then s.sales_price_home
				 when (s.invoice_line_type = 0 and s.invoice_line_uid_parent = 0 and s.oe_line_assembly <> 'N') then s.assembly_sales_price_home
				 else s.sales_price_home 
			end
		end),
		prev_count = count(distinct case when s.invoice_date < @start and s.sales_price_home >= 0 then s.order_no end) - count(distinct case when s.invoice_date < @start and s.sales_price_home < 0 then s.order_no end),
		prev_customer_count = count(distinct case when s.invoice_date < @start then s.customer_id end)
from	p21_sales_history_report_view s				
where	s.invoice_date >= case when @type = 'monthly' then dateadd(month, -1, @start) else dateadd(day, -1, @start) end
		and s.salesrep_id = @salesrep_id
		and s.invoice_line_type not in (981,982,1577,1719)
		and s.vendor_consigned = 'N'
		and s.projected_order = 'N'
		and isnull(s.detail_type, 0) = 0
		and isnull(s.progress_bill_flag, 'N') = 'N'
		and s.consignment_flag = 'N'