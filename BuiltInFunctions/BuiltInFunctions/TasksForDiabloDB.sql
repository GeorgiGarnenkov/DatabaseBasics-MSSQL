SELECT TOP (50) [Name], CONVERT(VARCHAR(10), DATEADD(DAY, 0, [Start]), 121) AS [Start]
FROM Games
WHERE DATEPART(YEAR, [Start]) = 2011 OR DATEPART(YEAR, [Start]) = 2012
ORDER BY [Start] ASC


SELECT Username, SUBSTRING(Email,charindex('@',Email,1)+1,len(Email)) AS 'Email Provider'
FROM Users
ORDER BY [Email Provider], Username


SELECT Username, IpAddress
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username


SELECT [Name] AS Game,
CASE 
		WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
		WHEN DATEPART(HOUR, [Start]) >= 18 AND DATEPART(HOUR, [Start]) < 24 THEN 'Evening'
	END AS 'Part of the Day',
CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration >= 4 AND Duration <= 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		WHEN Duration IS NULL THEN 'Extra Long'
    END AS Duration
FROM Games
ORDER BY Game ASC, Duration ASC, [Part of the Day] ASC

