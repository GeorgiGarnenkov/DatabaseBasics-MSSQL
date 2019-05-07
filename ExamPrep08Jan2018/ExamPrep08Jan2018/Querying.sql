---5
SELECT Manufacturer,Model
FROM Models
ORDER BY Manufacturer, Id DESC


---6
SELECT FirstName, LastName
FROM Clients
WHERE YEAR(BirthDate) BETWEEN 1977 AND 1994
ORDER BY FirstName, LastName, Id


---7
SELECT t.Name AS TownName,o.Name AS OfficeName,	ParkingPlaces
FROM Offices AS o
JOIN Towns AS t ON t.Id = o.TownId
WHERE ParkingPlaces > 25
ORDER BY TownName, o.Id


---8
SELECT m.Model,	m.Seats, v.Mileage
FROM Models AS m
JOIN Vehicles AS v ON v.ModelId = m.Id
WHERE v.Id NOT IN (
					SELECT o.VehicleId
					FROM Orders AS o
					WHERE o.ReturnDate IS NULL
				  )
ORDER BY v.Mileage, m.Seats DESC, m.Id


---9
SELECT t.Name AS TownName, COUNT(o.Id) AS OfficesNumber
FROM Towns AS t
JOIN Offices AS o ON o.TownId = t.Id
GROUP BY t.Name
ORDER BY OfficesNumber DESC, TownName ASC


---10
SELECT m.Manufacturer AS Manufacturer, m.Model AS Model, COUNT(o.Id) AS TimesOrdered
FROM Orders AS o
RIGHT JOIN Vehicles AS v ON v.Id = o.VehicleId
JOIN Models AS m ON m.Id = v.ModelId
GROUP BY m.Manufacturer, m.Model
ORDER BY TimesOrdered desc, m.Manufacturer desc, m.Model asc


---11
SELECT Names, Class
FROM (
		SELECT CONCAT(c.FirstName, ' ' ,c.LastName) AS Names, 
			   m.Class AS Class, 
			   RANK() OVER(PARTITION BY CONCAT(c.FirstName, ' ', c.LastName) 
						   ORDER BY COUNT(m.Class) DESC) AS Ranking
		FROM Clients AS c
		JOIN Orders AS o ON o.ClientId = c.Id
		JOIN Vehicles AS v ON v.Id = o.VehicleId
		JOIN Models AS m ON m.Id = v.ModelId
		GROUP BY CONCAT(c.FirstName, ' ' ,c.LastName), m.Class, c.Id
) AS H
WHERE Ranking = 1
ORDER BY Names, Class


---12
SELECT AgeGroup =
			CASE
				WHEN YEAR(c.BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
				ELSE 'Others'
			END,  SUM(o.Bill) AS Revenue, AVG(o.TotalMileage) as AverageMileage
FROM Clients AS c
JOIN Orders AS o ON o.ClientId = c.Id
GROUP BY CASE
				WHEN YEAR(c.BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
				ELSE 'Others'
			END
ORDER BY AgeGroup ASC


---13
SELECT Manufacturer, AverageConsumption
FROM(
		SELECT TOP (7)m.Manufacturer, AVG(m.Consumption) AS AverageConsumption, 
				 COUNT(m.Model) AS Counter
		FROM Orders AS o
		JOIN Vehicles AS v ON v.Id = o.VehicleId
		JOIN Models AS m ON m.Id = v.ModelId
		GROUP BY m.Manufacturer, m.Model
		ORDER BY Counter DESC
) AS H
WHERE AverageConsumption BETWEEN 5 AND 15
ORDER BY Manufacturer, AverageConsumption


---14
SELECT [Client Name], Email, Bill, Town
FROM (
		SELECT ROW_NUMBER() OVER(PARTITION BY t.Name ORDER BY o.Bill DESC) AS				 OrderByHighestBill,
			   CONCAT(c.FirstName, ' ', c.LastName) AS [Client Name],
			   c.Id AS ClientId, 
			   c.Email AS Email, o.Bill AS Bill, t.Name AS	Town
		FROM Orders AS o
		JOIN Clients AS c ON c.Id = o.ClientId
		JOIN Towns AS t ON  t.Id = o.TownId
		WHERE o.CollectionDate > c.CardValidity AND o.Bill IS NOT NULL
) AS h
WHERE OrderByHighestBill IN (1, 2)
ORDER BY Town, Bill, ClientId


---15
SELECT t.Name AS TownName, 
	   (SUM(H.M)* 100) / (ISNULL(SUM(H.M), 0) + ISNULL(SUM(H.F), 0)) AS MalePercent,
	   (SUM(H.F)* 100) / (ISNULL(SUM(H.M), 0) + ISNULL(SUM(H.F), 0)) AS FemalePercent
FROM(
		SELECT o.TownId, 
			CASE WHEN Gender = 'M' THEN COUNT(o.Id) END AS M,
			CASE WHEN Gender = 'F' THEN COUNT(o.Id) END AS F
		FROM Orders AS o
		JOIN Clients AS c ON c.Id = o.ClientId
		GROUP BY c.Gender, o.TownId
) AS H
JOIN Towns AS t ON t.Id = H.TownId
GROUP BY t.Name
GO

---16
WITH CTE_Ranks (ReturnOfficeId, OfficeId, Id, Manufacturer, Model)
AS 
(
	SELECT h.ReturnOfficeId, h.OfficeId, h.Id, h.Manufacturer, h.Model
	FROM(
			SELECT DENSE_RANK() OVER (PARTITION BY v.Id ORDER BY o.CollectionDate DESC)		AS					 RankLatestRentCars,
				   o.ReturnOfficeId,
				   v.OfficeId,
				   v.Id,
				   m.Manufacturer,
				   m.Model
			FROM Orders AS o
			RIGHT JOIN Vehicles AS v ON v.Id = o.VehicleId
			JOIN Models AS m ON m.Id = v.ModelId
			) AS H
	WHERE RankLatestRentCars = 1
)
SELECT CONCAT(Manufacturer, ' - ', Model) AS Vehicle,
		Location = 
					CASE
						WHEN(
								SELECT COUNT(*)
								FROM Orders AS o
								WHERE o.VehicleId = CTE_Ranks.Id
							) = 0 
							THEN 'home'
						WHEN(
								CTE_Ranks.ReturnOfficeId IS NULL
							)
							THEN 'on a rent'
						WHEN(
								CTE_Ranks.OfficeId <> CTE_Ranks.ReturnOfficeId
							) 
							THEN (
									SELECT CONCAT(t.Name, ' - ', o.Name)
									FROM Towns AS t
									JOIN Offices AS o ON o.TownId = t.Id
									WHERE o.Id = CTE_Ranks.ReturnOfficeId
								 )
					END
FROM CTE_Ranks
ORDER BY Vehicle, CTE_Ranks.Id
go


---17
CREATE FUNCTION udf_CheckForVehicle(@townName    VARCHAR(50),@seatsNumber INT)
RETURNS VARCHAR(MAX)
AS
     BEGIN
         DECLARE @result VARCHAR(MAX)=
(
    SELECT TOP 1 CONCAT(o.Name, ' - ', m.Model)
    FROM Towns AS t
         JOIN Offices AS o ON t.Id = o.TownId
         JOIN Vehicles AS v ON v.OfficeId = o.Id
         JOIN models AS m ON m.Id = v.ModelId
    WHERE t.Id IN
				(
				    SELECT Id
				    FROM Towns
				    WHERE Name = @townName
				)
					AND m.Seats = @seatsNumber
    ORDER BY o.Name
)
         IF(@result IS NULL)
             BEGIN
                 SET @result = 'NO SUCH VEHICLE FOUND'
             END
         RETURN @result
     END

GO
SELECT dbo.udf_CheckForVehicle ('La Escondida', 9) 
GO



---18
CREATE PROCEDURE usp_MoveVehicle (@vehicleId INT, @officeId  INT)
AS
     BEGIN
			 BEGIN TRANSACTION
			 DECLARE @curentVehicleCount INT =
										(
										    SELECT COUNT(*)
										    FROM Offices AS O
										         JOIN Vehicles AS V ON V.OfficeId = O.Id
										    WHERE O.Id = @officeId
										)
			 IF(@curentVehicleCount >=
			   (
				SELECT ParkingPlaces
				FROM Offices
				WHERE id = @officeId
			   ))
					BEGIN
					    RAISERROR('Not enough room in this office!', 16, 1)
					    ROLLBACK
					END
			 UPDATE Vehicles
			 SET OfficeId = @officeId
			 WHERE id = @vehicleId
			 COMMIT
     END
	 go

BEGIN TRAN
EXEC usp_MoveVehicle  7, 32
SELECT OfficeId
FROM Vehicles WHERE Id = 7
ROLLBACK
 go



---19
CREATE TRIGGER TR_AddMileage 
ON orders 
AFTER UPDATE
AS
	DECLARE @startMileage INT = (SELECT TotalMileage FROM deleted)
	 IF (@startMileage IS NULL)
		 BEGIN
				DECLARE @vehicleId INT = (SELECT VehicleId FROM inserted)
				DECLARE @mileage INT = (SELECT TotalMileage FROM inserted)

				UPDATE Vehicles 
				SET Mileage +=@mileage
				WHERE id = @vehicleId
		 END


go

BEGIN 
TRAN
UPDATE Orders
SET
TotalMileage = 100
WHERE Id = 16;

SELECT Mileage FROM Vehicles
WHERE Id = 25


rollback