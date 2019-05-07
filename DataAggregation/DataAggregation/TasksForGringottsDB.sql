SELECT COUNT(Id) AS [Count]
FROM WizzardDeposits


SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits


SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup


SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)


SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup


SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup


SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY SUM(DepositAmount) DESC


SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator ASC, DepositGroup ASC


SELECT e.AgeGroup, COUNT(e.AgeGroup) AS WizardCount FROM 
( 
SELECT
	CASE
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN Age >= 61 THEN '[61+]'
	END AS AgeGroup
FROM WizzardDeposits
) AS e
GROUP BY e.AgeGroup

SELECT e.FirstLetter FROM 
(
SELECT LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup LIKE 'Troll Chest'
) AS e
GROUP BY e.FirstLetter
ORDER BY e.FirstLetter ASC


SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE CAST(DepositStartDate as Date) >= '1985-01-01'
GROUP BY IsDepositExpired, DepositGroup
ORDER BY DepositGroup DESC, IsDepositExpired ASC


SELECT SUM(TableDifference.Diff) AS SumDifference FROM(
SELECT DepositAmount - (
SELECT DepositAmount FROM WizzardDeposits WHERE Id = Host.Id + 1 
) AS Diff
FROM WizzardDeposits AS Host
) AS TableDifference
