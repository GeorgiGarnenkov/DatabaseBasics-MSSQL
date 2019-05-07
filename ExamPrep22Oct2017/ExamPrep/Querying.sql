SELECT Username, Age
FROM Users
ORDER BY Age ASC, Username DESC


SELECT [Description], OpenDate
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate ASC , Description ASC


SELECT e.FirstName,	e.LastName,	r.Description,	FORMAT(r.OpenDate, 'yyyy-MM-dd') AS OpenDate
FROM Employees AS e
JOIN Reports AS r ON r.EmployeeId = e.Id
ORDER BY e.Id, OpenDate, r.Id


SELECT c.Name AS CategoryName, COUNT(r.CategoryId) AS ReportsNumber
FROM Categories AS c
JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber desc, CategoryName asc


SELECT c.Name AS CategoryName, COUNT(e.Id) AS [Employees Number]
FROM Categories AS c
JOIN Departments AS d ON d.Id = c.DepartmentId
JOIN Employees AS e ON e.DepartmentId = d.Id
GROUP BY c.Name
ORDER BY CategoryName asc


SELECT e.FirstName + ' ' + e.LastName AS [Name], COUNT(DISTINCT r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY [Users Number] DESC, [Name] ASC


SELECT r.OpenDate,	r.[Description],	u.Email as [Reporter Email]
FROM Reports as r
JOIN Users as u on u.Id = r.UserId
JOIN Categories as c on c.Id = r.CategoryId
JOIN Departments as d on d.Id = c.DepartmentId
WHERE CloseDate IS NULL AND 
	  LEN([Description]) > 20 AND 
	  [Description] LIKE '%str%' AND
	  d.Id IN (1, 4 ,5)
ORDER BY OpenDate, [Reporter Email], r.Id


SELECT DISTINCT c.Name AS [Category Name]
FROM Categories as c
JOIN Reports as r on r.CategoryId = c.Id
JOIN Users as u on u.Id = r.UserId
WHERE MONTH(r.OpenDate) = MONTH(u.BirthDate) AND
	  DAY(r.OpenDate) = DAY(u.BirthDate) 
ORDER BY [Category Name]



SELECT DISTINCT Username
FROM Reports as r
JOIN Categories as c on c.Id = r.CategoryId
JOIN Users as u on u.Id = r.UserId
WHERE LEFT(u.Username, 1) LIKE '[0-9]' AND
CONVERT(VARCHAR(10), c.Id) = LEFT(u.Username, 1)
OR 
	  RIGHT(u.Username, 1) LIKE '[0-9]' AND
CONVERT(VARCHAR(10), c.Id) = RIGHT(u.Username, 1)
ORDER BY Username



SELECT E.Firstname+' '+E.Lastname AS [Name], 
	   ISNULL(CONVERT(varchar, CC.ReportSum), '0') + '/' +        
       ISNULL(CONVERT(varchar, OC.ReportSum), '0') AS [Closed Open Reports]
FROM Employees AS E
JOIN (SELECT EmployeeId,  COUNT(1) AS ReportSum
	  FROM Reports R
	  WHERE  YEAR(OpenDate) = 2016
	  GROUP BY EmployeeId) AS OC ON OC.Employeeid = E.Id
LEFT JOIN (SELECT EmployeeId,  COUNT(1) AS ReportSum
	       FROM Reports R
	       WHERE  YEAR(CloseDate) = 2016
	       GROUP BY EmployeeId) AS CC ON CC.Employeeid = E.Id
ORDER BY [Name]




SELECT d.Name AS [Department Name], 
	   ISNULL(CONVERT(VARCHAR, AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate))), 'no info')
	   AS [Average Duration]
FROM Departments AS d
JOIN Categories AS c ON c.DepartmentId = d.Id
LEFT JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Name
ORDER BY d.Name



SELECT [Department Name],[Category Name], [Percentage]
FROM 
(
	SELECT d.Name AS [Department Name], c.Name AS [Category Name],
		   CAST(ROUND(COUNT(1) OVER(PARTITION BY c.Id) * 100.00 / COUNT(1) OVER(PARTITION BY d.Id), 0) AS INT) AS [Percentage]
	FROM Categories AS c
	JOIN Reports AS r ON r.CategoryId = c.Id
	JOIN Departments AS d ON d.Id = c.DepartmentId) AS Stats
	GROUP BY [Department Name], [Category Name], [Percentage]
	ORDER BY [Department Name], [Category Name], [Percentage]