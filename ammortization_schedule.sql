-- This is an example of how to create an ammortization schedule for a 30 year fixed mortgage loan using a recursive CTE.


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[mortgage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[starting_date] [date] NULL,
	[loan_term] [int] NULL,
	[interest_rate] [decimal](19, 5) NULL,
	[loan_amount] [decimal](19, 5) NULL,
	[pmt_amount] [decimal](19, 5) NULL
) ON [PRIMARY]
GO


-- Insert your value(s)
-- INSERT INTO [dbo].[mortgage]
        --    ([starting_date]
        --    ,[loan_term]
        --    ,[interest_rate]
        --    ,[loan_amount]
        --    ,[pmt_amount])
    --  VALUES
        --    (<starting_date, date,>
        --    ,<loan_term, int,>
        --    ,<interest_rate, decimal(19,5),>
        --    ,<loan_amount, decimal(19,5),>
        --    ,<pmt_amount, decimal(19,5),>)
-- GO



WITH mortCTE AS 
(
    -- anchor member
    SELECT 
        0 AS pmtNo, 
        starting_date AS pmtDate, 
        loan_amount AS begBalance, 
        pmt_amount, 
        loan_amount * (interest_rate / 12) AS interest,
        pmt_amount - loan_amount * (interest_rate / 12) AS principle,
        loan_amount - (pmt_amount - loan_amount * (interest_rate / 12)) AS endingBalance,
        interest_rate,
        CONVERT(decimal(19,5), 0) AS cumulativeInterest
    FROM [dbo].[mortgage]

    UNION ALL

    -- recursive member
    SELECT 
        pmtNo + 1 AS pmtNo,
        DATEADD(MONTH, 1, pmtDate) AS pmtDate, 
        ROUND(endingBalance, 2) AS begBalance, 
        pmt_amount, 
        endingBalance * (interest_rate / 12) AS interest,
        pmt_amount - endingBalance * (interest_rate / 12) AS principle,
        endingBalance - (pmt_amount - endingBalance * (interest_rate / 12)) AS endingBalance,
        interest_rate,
        ROUND(cumulativeInterest + endingBalance * (interest_rate / 12), 2) AS cumulativeInterest
    FROM mortCTE
    WHERE endingBalance > 0
)

SELECT pmtNo, 
    pmtDate, 
    begBalance as begBalance, 
    pmt_amount as pmtAmount, 
    principle as Principle, 
    interest as interest, 
    endingBalance as endingBalance, 
    interest_rate,
    cumulativeInterest
FROM mortCTE
WHERE pmtNo > 0
OPTION (MAXRECURSION 360) 

