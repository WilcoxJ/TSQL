-- Recursive CTE's Explained:

-- In this example we have a table with data on several loans including the start date of the loan, loan term (how many months the loan will last), and monthly payment amount.
-- I will demonstrate how to create a recursive CTE that will return the SUM of payments made each month for the past year.

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
    -- The anchor member must pull from an exisitng table or view, and will be the base result set R[0] that is passed to the recursive member.
UNION ALL
-- Recursive Member 
SELECT monthly_payment, loan_end_date, starting_date, DATEADD(MONTH, 1, current_month) -- Notice that we are incrementing the current_month each time the next result set R[1], R[2],...R[n] is passed to the recursive member. This is crucial to our terminating condition
    FROM loanCTE -- Notice the FROM loanCTE. This is the self-referential (hence recursive) part of the CTE.
    WHERE current_month < loan_end_date -- Terminating condition. This tells the recursive member when to stop pulling in the result sets. Without this condition along with the incrementing date in the SELECT, we would have an infinite loop.
)

-- This example uses a DATE column as it's terminating condition, but you can also use exact numeric types. Avoid using approximate numerics such as floats like the plague.
-- The important thing to understand here is the anchor member is your base result set R[0], which is passed to the recursive member for the next iteration.
-- Next the recursive member executes with the input result set from the previous iteration R[i-1] and returns a sub-result set R[i] until the terminating condition is met.
-- Then all result sets R[0], R[1], … R[n] are combined using UNION ALL operator to get the full loanCTE result set.


-- Now that we have the loanCTE built we can write our final query to produce the desired list (Year, Month, and SUM of monthly payments for the past year).
SELECT YEAR(current_month) as Year, MONTH(current_month) as Month,  SUM(monthly_payment) as total_montly_payments
    FROM loanCTE
    WHERE DATEFROMPARTS(YEAR(current_month), MONTH(current_month), 1) BETWEEN GETDATE()-365 AND GETDATE() -- Notice the DATEFROMPARTS() function here uses 1 as the day parameter. This is important since current_month will often not have 1 as it's day, and if you were only to use WHERE current_month BETWEEN GETDATE()-365 AND GETDATE() the SUM of monthly payments would be incorrect.
    GROUP BY YEAR(current_month), MONTH(current_month) 
    ORDER BY YEAR(current_month) DESC, MONTH(current_month) DESC;

-- Another Important note is SQL server by default only allows 100 iterations. You can increase this by setting the OPTION (MAXRECURSION 5000) at the bottom of the CTE
-- You can set this as high as 32767, or 0 which will remove the limit altogether.

-- Link to documentation: https://docs.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver15

