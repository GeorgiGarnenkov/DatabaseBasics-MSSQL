SELECT c.Id, c.Name
FROM Cities AS c
WHERE CountryCode = 'BG'
ORDER BY c.Name


SELECT Firstname + ' ' + ISNULL(MiddleName + ' ','') + LastName AS [Full Name], YEAR(BirthDate) AS BirthYear
FROM Accounts
WHERE YEAR(BirthDate) > 1991
ORDER BY YEAR(BirthDate) DESC, FirstName ASC


SELECT a.FirstName,	a.LastName,	FORMAT(a.BirthDate, 'MM-dd-yyyy') AS BirthDate, c.Name AS Hometown, a.Email 
FROM Accounts AS a
JOIN Cities AS c ON c.Id = a.CityId
WHERE a.Email LIKE 'e%'
ORDER BY c.Name DESC


SELECT c.Name AS City,COUNT(h.Id) AS Hotels
FROM Cities as c
LEFT JOIN Hotels as h on h.CityId = c.Id
GROUP BY c.Name
ORDER BY Hotels DESC, c.Name


SELECT r.Id,	r.Price,h.Name as Hotel, c.Name as	City
FROM Rooms as r
JOIN Hotels as h on h.Id = r.HotelId
JOIN Cities as c on c.Id = h.CityId
WHERE r.Type = 'First Class'
ORDER BY r.Price desc, r.Id


SELECT a.Id as AccountId, 
	   a.FirstName + ' ' + a.LastName as	FullName,
	    MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) as	LongestTrip,
		MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) as	ShortestTrip
FROM Accounts as a
JOIN AccountsTrips as ac on ac.AccountId = a.Id
JOIN Trips as t on t.Id = ac.TripId
WHERE a.MiddleName IS null AND t.CancelDate IS null
GROUP BY a.Id, a.FirstName + ' ' + a.LastName
ORDER BY LongestTrip desc, a.Id


SELECT TOP(5) c.Id,c.Name as	City, c.CountryCode as 	Country, COUNT(a.Id) as	Accounts
FROM Cities as c
JOIN Accounts as a on a.CityId = c.Id
GROUP BY c.Id,c.Name, c.CountryCode
ORDER BY COUNT(a.Id) DESC


SELECT a.Id AS Id, c.Name AS City, COUNT(t.Id) AS [Trips]
FROM Accounts AS a
JOIN Cities as c on c.Id = a.CityId
JOIN Hotels AS h ON h.CityId = c.Id  
JOIN AccountsTrips AS ac on ac.AccountId = a.Id
JOIN Trips AS t on t.Id = ac.TripId
WHERE h.CityId = c.Id
GROUP BY a.Id, c.Name
ORDER BY COUNT(t.Id) DESC, a.Id
GO


SELECT Id , Name, [Total Revenue], [Trips]
FROM
(SELECT hp.Id as Id, hp.Name as [Name], h.BaseRate + r.Price AS [Total Revenue], COUNT(ac.TripId) as [Trips]
FROM(
		SELECT a.Id, 
			   c.Name,
			   c.Id as CityId
		FROM Accounts as a
		JOIN Cities as c on c.Id = a.CityId
) AS hp
JOIN Hotels as h on h.CityId = hp.CityId
JOIN Rooms as r on r.HotelId = h.Id
JOIN AccountsTrips as ac on ac.AccountId = hp.Id
JOIN Trips as t on t.Id = ac.TripId
WHERE YEAR(t.BookDate) = 2016
GROUP BY hp.Id, hp.Name, h.BaseRate + r.Price
) AS Hp2
GROUP BY hp2.Id, hp2.Name, hp2.[Total Revenue], hp2.Trips

GO


CREATE TRIGGER tr_DeleteTrip
ON Trips
INSTEAD OF DELETE
AS 
	BEGIN 
			UPDATE SET 

	END
