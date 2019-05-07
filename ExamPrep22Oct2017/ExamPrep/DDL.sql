CREATE TABLE Users
(
	Id INT NOT NULL IDENTITY,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR(1) NULL CHECK (Gender='M' OR Gender='F'),
	BirthDate DATETIME2,
	Age INT,
	Email NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Users
	PRIMARY KEY (Id)
)

CREATE TABLE Departments
(
	Id INT NOT NULL IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Departments
	PRIMARY KEY (Id)
)

CREATE TABLE Employees
(
	Id INT NOT NULL IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) NULL CHECK (Gender='M' OR Gender='F'),
	BirthDate DATETIME2,
	Age INT,
	DepartmentId INT NOT NULL,

	CONSTRAINT PK_Employees
	PRIMARY KEY (Id),

	CONSTRAINT FK_Employees_Departments
	FOREIGN KEY (DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE Categories
(
	Id INT NOT NULL IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL,

	CONSTRAINT PK_Categories
	PRIMARY KEY (Id),

	CONSTRAINT FK_Categories_Departments
	FOREIGN KEY (DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE [Status]
(
	Id INT NOT NULL IDENTITY,
	Label VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Status
	PRIMARY KEY (Id)
)	

CREATE TABLE Reports
(
	Id INT NOT NULL IDENTITY,
	CategoryId INT NOT NULL,
	StatusId INT NOT NULL,
	OpenDate DATETIME2 NOT NULL,
	CloseDate DATETIME2,
	[Description] VARCHAR(200),
	UserId INT NOT NULL,
	EmployeeId INT,

	CONSTRAINT PK_Reports
	PRIMARY KEY (Id),

	CONSTRAINT FK_Reports_Categories
	FOREIGN KEY (CategoryId)
	REFERENCES Categories(Id),

	CONSTRAINT FK_Reports_Status
	FOREIGN KEY (StatusId)
	REFERENCES [Status](Id),

	CONSTRAINT FK_Reports_Users
	FOREIGN KEY (UserId)
	REFERENCES Users(Id),

	CONSTRAINT FK_Reports_Employees
	FOREIGN KEY (EmployeeId)
	REFERENCES Employees(Id)
)

