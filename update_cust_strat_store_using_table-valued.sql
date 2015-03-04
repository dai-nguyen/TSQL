
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dai Nguyen
-- Create date: 8/13/2014
-- Description:	Update Customer Score using UD Table-Valued
-- =============================================
CREATE PROCEDURE Brenner_UpdateCustomerStratScore 
	@scores Ud_CustomerScore readonly
AS
BEGIN
	
	SET NOCOUNT ON;

	update	ud
	set		ud.cust_strat_score = 'Visitor'
	from    p21_view_customer c
			join customer_ud (nolock) ud on c.customer_id = ud.customer_id
	where	c.delete_flag = 'N'
			and c.customer_type_cd = 1203

    update	ud
	set		ud.cust_strat_score = s.Score
	from	customer_ud ud (nolock)
			join @scores s on ud.customer_id = s.CustomerID

END
GO
