---17
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT)
RETURNS INT AS 
BEGIN 
	DECLARE @count INT = (SELECT COUNT(*)
							FROM Reports
							WHERE EmployeeId = @employeeId
							AND StatusId = @statusId)
	RETURN @count
END

SELECT Id, FirstName, Lastname, dbo.udf_GetReportsCount(Id, 2) AS ReportsCount
FROM Employees
ORDER BY Id
GO

---18
CREATE PROC usp_AssignEmployeeToReport(@employeeId INT, @reportId INT)
AS
BEGIN
	BEGIN TRAN
		DECLARE @categoryId INT = 
		(
		SELECT CategoryId
		FROM Reports
		WHERE Id = @reportId
		)
		DECLARE @categoryDepId INT = 
		(
		SELECT DepartmentId
		FROM Categories
		WHERE Id = @categoryId
		)
		DECLARE @employeeDepId INT = 
		(
		SELECT DepartmentId
		FROM Employees
		WHERE Id = @employeeId
		)
		UPDATE Reports
		SET EmployeeId = @employeeId
		WHERE Id = @reportId

		IF @employeeId IS NOT NULL
		   AND @categoryDepId <> @employeeDepId
		BEGIN 
			ROLLBACK
			RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
		END
    COMMIT
END
GO

---19
CREATE TRIGGER tr_CloseReport 
ON Reports 
AFTER UPDATE
AS
BEGIN
	UPDATE Reports
	SET StatusId = (SELECT Id FROM [Status] WHERE Label = 'completed')
	WHERE Id IN (SELECT Id FROM inserted
			     WHERE Id IN (SELECT Id FROM deleted WHERE CloseDate IS NULL)
			     AND CloseDate IS NOT NULL
				 )   
END



