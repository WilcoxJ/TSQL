-- Drop table if exists
DROP TABLE IF EXISTS dbo.AmortizationSchedule;

CREATE TABLE dbo.AmortizationSchedule (
    PaymentNumber INT,
    PaymentDate DATE,
    BeginningBalance DECIMAL(18, 2),
    MonthlyPayment DECIMAL(18, 2),
    Interest DECIMAL(18, 2),
    Principal DECIMAL(18, 2),
    EndingBalance DECIMAL(18, 2)
);

DECLARE @LoanAmount DECIMAL(18, 2) = 250000.00; -- Loan amount
DECLARE @AnnualInterestRate DECIMAL(5, 3) = 3.275; -- Annual interest rate
DECLARE @LoanTermYears INT = 30; -- Loan term in years

-- Calculate monthly interest rate and number of payments
DECLARE @MonthlyInterestRate DECIMAL(18, 6) = @AnnualInterestRate / 1200.0;
DECLARE @NumberOfPayments INT = @LoanTermYears * 12;
DECLARE @MonthlyPayment DECIMAL(18, 2);

-- Calculate monthly payment using the PMT function
SET @MonthlyPayment = (@LoanAmount * @MonthlyInterestRate) / (1 - POWER(1 + @MonthlyInterestRate, -@NumberOfPayments));

WITH AmortizationCTE AS (
    SELECT
        1 AS PaymentNumber,
        DATEADD(MONTH, 1, GETDATE()) AS PaymentDate,
        CAST(@LoanAmount AS DECIMAL(18, 2)) AS BeginningBalance,
        @MonthlyPayment AS MonthlyPayment,
        CAST(@LoanAmount * @MonthlyInterestRate AS DECIMAL(18, 2)) AS Interest,
        CAST(@MonthlyPayment - (@LoanAmount * @MonthlyInterestRate) AS DECIMAL(18, 2)) AS Principal,
        CAST(@LoanAmount - (@MonthlyPayment - (@LoanAmount * @MonthlyInterestRate)) AS DECIMAL(18, 2)) AS EndingBalance

    UNION ALL

    SELECT
        PaymentNumber + 1,
        DATEADD(MONTH, 1, PaymentDate),
        CAST(EndingBalance AS DECIMAL(18, 2)),
        @MonthlyPayment,
        CAST(EndingBalance * @MonthlyInterestRate AS DECIMAL(18, 2)),
        CAST(@MonthlyPayment - (EndingBalance * @MonthlyInterestRate) AS DECIMAL(18, 2)),
        CAST(EndingBalance - (@MonthlyPayment - (EndingBalance * @MonthlyInterestRate)) AS DECIMAL(18, 2))
    FROM
        AmortizationCTE
    WHERE
        PaymentNumber < @NumberOfPayments
)

SELECT * 
FROM AmortizationCTE
OPTION(MAXRECURSION 1000);
