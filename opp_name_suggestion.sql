-- =============================================
-- Author:		Dai Nguyen
-- Create date: 12/23/2014
-- Description:	Opp name suggestion
-- =============================================

declare @SalesRepIds dbo.Ud_SalesRepId,
		@FilterBuilder dbo.Ud_FilterBuilder,
		@take int = 10

insert into @SalesRepIds
values	('1027'),
		('1008')

insert into @FilterBuilder
values  ('Overview', 'TARGET')
		,('OppName', 'PARKER')

declare @filterKey		nvarchar(60),
		@filterValue	nvarchar(60),
		@sql			nvarchar(max),
		@salesreps		nvarchar(100)

set @salesreps = '(' + stuff((select ', ' + SalesRepId from @SalesRepIds for xml path(''), type).value('(./text())[1]','varchar(max)'),1,2,'') + ')'

set @sql = N'
select		top (@take)
			o.opportunity_name
from		p21_view_opportunity o
			join p21_view_customer c on o.customer_id = c.customer_id
			left join p21_view_opportunity_status s on o.opportunity_status_uid = s.opportunity_status_uid
where		o.row_status_flag = 704
			and c.delete_flag = ''N''		
			and o.salesrep_id in ' + @salesreps

declare filter_cursor cursor read_only for
	select	filterKey,
			filterValue
	from	@FilterBuilder
	

open filter_cursor;
fetch next from filter_cursor into	@filterKey,
									@filterValue

while @@fetch_status = 0
begin	
		
	set @sql += case @filterKey when 'Overview' then ' and o.opportunity_status_uid in (2, 4, 9, 3, 12, 11)'
								when 'StatusId' then ' and isnull(s.opportunity_status_id, '''') = ' + '''' + @filterValue + ''''
								when 'OppName' then ' and (o.opportunity_name like ' + '''' + @filterValue + '%'' or c.customer_name like ' + '''' + @filterValue + '%'')'
				end						   	
	
	fetch next from filter_cursor into	@filterKey,
										@filterValue
end;
close filter_cursor;
deallocate filter_cursor;
			
set @sql += N' order by	o.opportunity_name'

exec sp_executesql @sql, 
					N'@take int',
					@take
