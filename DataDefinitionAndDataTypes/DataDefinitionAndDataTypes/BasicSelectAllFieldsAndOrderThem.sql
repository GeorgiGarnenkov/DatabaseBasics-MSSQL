--20.BasicSelectAllFieldsAndOrderThem
SELECT * FROM Towns
ORDER BY Name

SELECT * FROM Departments
ORDER BY Name

SELECT * FROM Employees
ORDER BY Salary DESC


--21.SELECT SOME FIELDS
SELECT Name FROM Towns
ORDER BY Name

SELECT Name FROM Departments
ORDER BY Name

SELECT FirstName, LastName, JobTitle, Salary
FROM Employees
ORDER BY Salary DESC

--22.INCRESE EMPLOYEES SALARY
UPDATE Employees
SET Salary *= 1.10

SELECT Salary FROM Employees

--23.Decrease Tax Rate
UPDATE Payments
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments

UPDATE Payments
SET TaxAmount = AmountCharged * TaxRate

UPDATE Payments
SET PaymentTotal = AmountCharged + TaxAmount
