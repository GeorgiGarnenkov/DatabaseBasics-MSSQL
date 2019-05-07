SELECT DepartmentID, SUM(Salary)
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID


SELECT DepartmentID, MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID = 2 OR DepartmentID = 5 OR DepartmentID = 7 AND 
CAST(HireDate as Date) >= '2000-01-01'
GROUP BY DepartmentID
ORDER BY DepartmentID


SELECT DISTINCT DepartmentID, Salary FROM (
SELECT DepartmentID, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
FROM Employees
) AS e
WHERE SalaryRank = 3


SELECT TOP (10) FirstName, LastName, DepartmentID
FROM Employees AS emp
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE DepartmentID = emp.DepartmentID)
ORDER BY DepartmentID
