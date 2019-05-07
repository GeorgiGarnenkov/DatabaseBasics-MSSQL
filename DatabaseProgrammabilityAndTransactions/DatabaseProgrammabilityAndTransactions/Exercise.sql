								------ 1 ------
CREATE PROC usp_GetEmployeesSalaryAbove35000 AS
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary > 35000


								------ 2 ------
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@salaryNumber DECIMAL(18,4)) AS
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary >= @salaryNumber


								------ 3 ------
CREATE OR ALTER PROC usp_GetTownsStartingWith(@nameString NVARCHAR(50)) AS
	SELECT [Name] AS Town
	FROM Towns
	WHERE Name LIKE @nameString + '%'
	

								------ 4 ------
CREATE PROC usp_GetEmployeesFromTown (@townName NVARCHAR(50)) AS 
BEGIN
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees AS e
	JOIN Addresses AS a ON a.AddressID = e.AddressID
	JOIN Towns AS t ON t.TownID = a.TownID
	WHERE t.Name = @townName
END


								------ 5 ------
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(10) AS 
BEGIN
	IF(@salary < 30000)
	BEGIN
		RETURN 'Low'
	END
	ELSE IF(@salary >= 30000 AND @salary <= 50000)
	BEGIN
		RETURN 'Average'
	END

	RETURN 'High'
END


								------ 6 ------
CREATE OR ALTER PROC usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR(10)) AS
BEGIN
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees AS e
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END


								------ 7 ------
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT AS
BEGIN
	DECLARE @index INT = 1;
	DECLARE @currentChar CHAR(1);
	DECLARE @isComprised INT
	WHILE(@index <= LEN(@word))
	BEGIN
		SET @currentChar = SUBSTRING(@word, @index, 1)
		SET @isComprised = CHARINDEX(@currentChar, @setOfLetters)

		IF(@isComprised = 0)
		BEGIN
			RETURN 0
		END
		SET @index += 1
	END
	RETURN 1
END


								------ 8 ------
CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment(@departmentId INT) AS 
BEGIN 
	
END
GO

								------ 9 ------
CREATE PROC usp_GetHoldersFullName AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
	FROM AccountHolders
END
exec usp_GetHoldersFullName
GO

								------ 10 ------
CREATE PROC usp_GetHoldersWithBalanceHigherThan (@number DECIMAL(15,2))
AS
BEGIN
	SELECT ah.FirstName, ah.LastName 
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	GROUP BY ah.FirstName, ah.LastName
	HAVING @number < SUM(a.Balance)
END
GO
								------ 11 ------
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(15, 4), @yearlyInterestRate FLOAT, @numberOfYears INT) 
RETURNS DECIMAL(15, 4) AS
BEGIN 
	DECLARE @result DECIMAL(15, 4)
	SET @result = @sum * POWER((1 + @yearlyInterestRate), @numberOfYears)
	RETURN @result
END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO

								------ 12 ------
CREATE PROC usp_CalculateFutureValueForAccount @accountID INT, @interestRate FLOAT
AS 
BEGIN
	SELECT a.Id AS [Account Id],
		   ah.FirstName,
		   ah.LastName,
		   a.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	WHERE a.Id = @accountID
END

EXEC usp_CalculateFutureValueForAccount 1 , 0.1
GO


								------ 13 ------
CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(50))
RETURNS TABLE 
AS
RETURN(
SELECT SUM(e.Cash) AS [SumCash] 
	FROM(
		SELECT g.Id, ug.Cash, ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [RowNumber]
		FROM Games AS g
		JOIN UsersGames AS ug ON ug.GameId = g.Id
		WHERE g.Name = @gameName
		) AS e
	WHERE e.RowNumber % 2 = 1
      )
GO
SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')
GO


								------ 14 ------
CREATE TABLE Logs(
	LogId INT IDENTITY NOT NULL,
	AccountId INT,
	OldSum DECIMAL(15, 2),
	NewSum DECIMAL(15, 2),

	CONSTRAINT PK_Logs
	PRIMARY KEY (LogId),

	CONSTRAINT FK_Logs_Accounts
	FOREIGN KEY (AccountId)
	REFERENCES Accounts(Id)
)
GO


CREATE TRIGGER tr_Accounts 
ON Accounts 
AFTER UPDATE
AS
BEGIN
	INSERT Logs(AccountId, OldSum, NewSum)
	SELECT inserted.Id, deleted.Balance, inserted.Balance
	FROM deleted, inserted
END

								------ 15 ------

CREATE TABLE NotificationEmails
(
	Id INT IDENTITY PRIMARY KEY,
	Recipient VARCHAR(100),
	Subject NVARCHAR(100),
	Body NVARCHAR(MAX)
)

CREATE TRIGGER tr_EmailNotification
ON Logs
AFTER INSERT
AS
BEGIN
	INSERT NotificationEmails(Recipient, Subject, Body)
	SELECT inserted.AccountId, 
			CONCAT('Balance change for account: ', inserted.AccountId), 
			CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum)
	FROM inserted
END
								------ 16 ------

CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @moneyAmount MONEY)
AS
BEGIN TRAN
		UPDATE Accounts
		SET Balance = Balance + @moneyAmount
		WHERE Accounts.Id = @AccountId
		BEGIN
			COMMIT
		END

								------ 17 ------

CREATE PROCEDURE usp_WithdrawMoney(@AccountId INT, @moneyAmount MONEY)
AS
BEGIN
	DECLARE @CurrentAccountBalance MONEY
	BEGIN TRAN
		UPDATE Accounts
		SET Balance = Balance - @moneyAmount
		WHERE Accounts.Id = @AccountId
	
		SET @CurrentAccountBalance = (SELECT Balance FROM Accounts AS a WHERE a.Id = @AccountId)
	
		IF (@CurrentAccountBalance < 0)
		BEGIN
			ROLLBACK
		END
		ELSE
		BEGIN
			COMMIT
		END
END


								------ 18 ------

CREATE PROCEDURE usp_TransferMoney(@senderId INT, @receiverId INT, @amount MONEY)
AS
BEGIN
	DECLARE @SenderBalance MONEY = (SELECT ac.Balance FROM Accounts AS ac WHERE ac.Id = @senderId)
	BEGIN TRAN
		IF(@amount < 0)
		BEGIN
			ROLLBACK
		END
		ELSE
		BEGIN
			IF(@SenderBalance - @amount >= 0)
			BEGIN
				EXEC usp_WithdrawMoney @senderId, @amount
				EXEC usp_DepositMoney @receiverId, @amount
				COMMIT
			END
			ELSE
			BEGIN
				ROLLBACK
			END
		END
END

								------ 20 ------
DECLARE @User VARCHAR(MAX) = 'Stamat'
DECLARE @GameName VARCHAR(MAX) = 'Safflower'
DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @User)
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney MONEY = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @ItemsBulkPrice MONEY
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)

BEGIN TRAN
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)
			UPDATE UsersGames
			SET Cash = Cash - @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END
		

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
BEGIN TRAN
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)
			UPDATE UsersGames
			SET Cash = Cash - @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END

SELECT Name AS 'Item Name' FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @UserGameId)
ORDER BY [Item Name]


								------ 21 ------

CREATE PROCEDURE usp_AssignProject(@emloyeeID INT, @ProjectID INT)
AS
BEGIN
	DECLARE @MaxProjectsPerEmployee INT = 3
	DECLARE @EmplojeeProjectCount INT
			BEGIN TRAN
			INSERT EmployeesProjects (EmployeeID, ProjectID)
			VALUES
			(@emloyeeID, @ProjectID)

			SET @EmplojeeProjectCount = (SELECT COUNT(*) FROM EmployeesProjects
										WHERE EmployeeID = @emloyeeID
									)
			IF(@EmplojeeProjectCount > @MaxProjectsPerEmployee)
			BEGIN
				RAISERROR('The employee has too many projects!',16,1)
				ROLLBACK
			END
			ELSE
			BEGIN
				COMMIT
			END
END



								------ 22 ------

ALTER TABLE Departments
ALTER COLUMN ManagerID INT

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (SELECT EmployeeID FROM Employees 
					 WHERE DepartmentID IN (SELECT DepartmentID 
						FROM Departments
						WHERE Name IN ('Production','Production Control'))
					)
ALTER TABLE Employees
DROP CONSTRAINT FK_Employees_Departments
ALTER TABLE Employees
DROP CONSTRAINT FK_Employees_Employees
ALTER TABLE Departments
DROP CONSTRAINT FK_Departments_Employees

DELETE FROM Employees
WHERE DepartmentID IN	(
						SELECT DepartmentID 
						FROM Departments
						WHERE Name IN ('Production','Production Control')
						)

DELETE FROM Departments
WHERE Name IN ('Production','Production Control')
