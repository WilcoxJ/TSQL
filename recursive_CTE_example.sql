-- Recursive CTE:

-- example of recursive CTE that will return the SUM of payments made each month for the past year.

-- Create Table
CREATE TABLE [dbo].[loan](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [starting_date] [date] NULL,
    [loan_term] [int] NULL,
    [monthly_payment] [decimal](19, 2) NULL
) ON [PRIMARY]
GO

-- Insert Sample Data
INSERT INTO [dbo].[loan]
    ([starting_date]
    ,[loan_term]
    ,[monthly_payment])
VALUES
    ('8/1/2020', 52, 1),
    ('6/2/2010', 64, 2500),
    ('9/11/2011', 66, 650),
    ('7/4/2011', 36, 600),
    ('11/19/2014', 36, 450),
    ('4/21/2017', 24, 650),
    ('6/25/2009', 68, 7500),
    ('4/3/2016', 72, 12000),
    ('5/2/2013', 12, 330),
    ('7/11/2011', 32, 331.33),
    ('6/11/2013', 36, 200),
    ('7/11/2014', 34, 250),
    ('8/15/2015', 32, 673),
    ('9/15/2017', 31, 8),
    ('11/6/2019', 64, 65),
    ('10/13/2017', 52, 128)
GO



-- Recursive CTE
WITH loanCTE as 
(
-- Anchor Member 
SELECT monthly_payment, DATEADD(MONTH, loan_term, starting_date) as loan_end_date, starting_date, starting_date as current_month
    FROM loan
UNION ALL
-- Recursive Member 
SELECT monthly_payment, loan_end_date, starting_date, DATEADD(MONTH, 1, current_month)
    FROM loanCTE
    WHERE current_month < loan_end_date 
)

SELECT YEAR(current_month) as Year, MONTH(current_month) as Month,  SUM(monthly_payment) as total_montly_payments
    FROM loanCTE
    WHERE DATEFROMPARTS(YEAR(current_month), MONTH(current_month), 1) BETWEEN GETDATE()-365 AND GETDATE()
    GROUP BY YEAR(current_month), MONTH(current_month) 
    ORDER BY YEAR(current_month) DESC, MONTH(current_month) DESC;
