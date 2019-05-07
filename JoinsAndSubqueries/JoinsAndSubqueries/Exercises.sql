SELECT TOP(5) e.EmployeeId, e.JobTitle, a.AddressID, a.AddressText
	FROM Employees AS e
	INNER JOIN Addresses AS a ON a.AddressID = e.AddressID
ORDER BY a.AddressID ASC

--------

SELECT TOP(50) e.FirstName, e.LastName, t.[Name] AS Town, a.AddressText
	FROM Employees AS e
	INNER JOIN Addresses AS a ON a.AddressID = e.AddressID
	INNER JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY e.FirstName ASC, LastName ASC

--------

SELECT e.EmployeeID,	e.FirstName,	e.LastName,	d.Name AS DepartmentName
	FROM Employees AS e
	INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID ASC 

--------

SELECT TOP(5) EmployeeID,	FirstName,	Salary,	d.Name AS DepartmentName
	FROM Employees AS e
	INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID ASC 

--------

SELECT TOP(3) e.EmployeeID, e.FirstName
	FROM Employees AS e
	LEFT OUTER JOIN EmployeesProjects AS p ON p.EmployeeID = e.EmployeeID
	WHERE p.ProjectID IS NULL
	ORDER BY EmployeeID ASC
	
--------

SELECT e.FirstName,	e.LastName,	e.HireDate,	d.Name AS DeptName
	FROM Employees AS e
	INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales' OR d.Name = 'Finance'AND CAST(e.HireDate AS DATE) > '01.01.1999'
ORDER BY e.HireDate

--------

SELECT TOP(5) e.EmployeeID,	e.FirstName, p.Name AS ProjectName
	FROM Employees AS e
	JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002.08.13' AND p.EndDate IS NULL
ORDER BY EmployeeID ASC

--------

SELECT e.EmployeeID, e.FirstName, 
	CASE
		WHEN p.StartDate > '2005.01.01' THEN NULL
		ELSE p.Name
	END AS ProjectName
	FROM Employees AS e
	JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

--------

SELECT e.EmployeeID,	e.FirstName,	e.ManagerID,	m.FirstName AS ManagerName
	FROM Employees AS e
	JOIN Employees AS m ON m.EmployeeID = e.ManagerID
WHERE e.ManagerID = 3 OR e.ManagerID = 7
ORDER BY EmployeeID ASC
	
--------
	
SELECT TOP(50) e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, 
			   m.FirstName + ' ' + m.LastName AS ManagerName, d.[Name] AS DepartmentName
	FROM Employees AS e
	JOIN Employees AS m ON m.EmployeeID = e.ManagerID
	JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID ASC

--------

SELECT MIN(a.AverageSalary) AS MinAverageSalary
	FROM
	(
	SELECT e.DepartmentID, AVG(e.Salary) AS AverageSalary
		FROM Employees AS e
		GROUP BY e.DepartmentID
	) AS a

--------

SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
	FROM MountainsCountries AS mc
	JOIN Mountains AS m ON m.Id = mc.MountainId
	JOIN Peaks AS p ON p.MountainId = m.Id 
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

--------

SELECT mc.CountryCode, COUNT(m.MountainRange) AS MountainRanges
	FROM MountainsCountries AS mc
	JOIN Mountains AS m ON m.Id = mc.MountainId
WHERE mc.CountryCode = 'US' OR mc.CountryCode = 'RU' OR mc.CountryCode = 'BG' 
GROUP BY mc.CountryCode

--------

SELECT TOP(5) c.CountryName, r.RiverName
	FROM Countries AS c
	LEFT OUTER JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT OUTER JOIN Rivers AS r ON r.Id = cr.RiverId
	LEFT OUTER JOIN Continents AS co ON co.ContinentCode = c.ContinentCode
WHERE co.ContinentName LIKE 'Africa'
ORDER BY c.CountryName ASC


---------


WITH Countries_CTE (ContinentCode, CurrencyCode, CurrencyUsage) AS 
(
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage
	FROM Countries
	GROUP BY ContinentCode, CurrencyCode
	HAVING COUNT(CurrencyCode) > 1
)
SELECT e.ContinentCode, cci.CurrencyCode , e.MaxCurrency AS CurrencyUsage FROM(
SELECT ContinentCode, MAX(CurrencyUsage) AS MaxCurrency
	FROM Countries_CTE
	GROUP BY ContinentCode) AS e
JOIN Countries_CTE AS cci ON cci.ContinentCode = e.ContinentCode AND cci.CurrencyUsage = e.MaxCurrency
ORDER BY e.ContinentCode

--------


SELECT COUNT(*) AS CountryCode
	FROM Countries
	WHERE CountryCode NOT IN (SELECT CountryCode FROM MountainsCountries)
	
--------

SELECT TOP (5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength
	FROM Countries as c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
	GROUP BY c.CountryName
	ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName ASC


--------

WITH CTE_CountriesInfo (CountryName, PeakName, Elevation, Mountain) AS 
(
	SELECT c.CountryName AS [Country],
			          p.PeakName AS [Highest Peak Name], 
			    MAX(p.Elevation) AS [Highest Peak Elevation], 
			     m.MountainRange AS [Mountain]
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
GROUP BY c.CountryName, p.PeakName, m.MountainRange
)
SELECT TOP (5) e.CountryName AS Country, 
	   ISNULL(cci.PeakName,'(no highest peak)') AS [Highest Peak Name], 
	   ISNULL(cci.Elevation, 0) AS [Highest Peak Elevation], 
	   ISNULL(cci.Mountain,'(no mountain)') AS [Mountain]
FROM(
	SELECT CountryName, 
           MAX(Elevation) AS MaxElevation
		FROM CTE_CountriesInfo
		GROUP BY CountryName) AS e
LEFT JOIN CTE_CountriesInfo AS cci ON cci.CountryName = e.CountryName AND cci.Elevation = e.MaxElevation
ORDER BY e.CountryName, cci.PeakName
	
--------
