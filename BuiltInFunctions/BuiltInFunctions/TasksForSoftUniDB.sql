SELECT FirstName, LastName
 FROM Employees
 WHERE LEFT(FirstName, 2) = 'SA'

SELECT FirstName, LastName
 FROM Employees
 WHERE LastName LIKE '%ei%'

SELECT FirstName 
 FROM Employees
 WHERE DepartmentID = 3 OR DepartmentID = 10 AND 
 DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

SELECT FirstName, LastName
 FROM Employees
 WHERE JobTitle NOT LIKE '%engineer%'

SELECT [Name]
 FROM Towns
 WHERE LEN([Name]) = 5 OR LEN([Name]) = 6
 ORDER BY [Name] ASC

SELECT *
 FROM Towns
 WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
 ORDER BY [Name] ASC
GO

CREATE VIEW V_EmployeesHiredAfter2000 AS
 SELECT FirstName, LastName
 FROM Employees
 WHERE DATEPART(YEAR, HireDate) > 2000
GO

SELECT FirstName, LastName
 FROM Employees
 WHERE LEN(LastName) = 5
