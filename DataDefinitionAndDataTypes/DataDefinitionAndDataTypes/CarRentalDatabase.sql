CREATE DATABASE CarRental

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CategoryName NVARCHAR(30) NOT NULL,
	DailyRate DECIMAL(15,2) NOT NULL,
	WeeklyRate DECIMAL(15,2) NOT NULL,
	MonthlyRate DECIMAL(15,2) NOT NULL,
	WeekendRate DECIMAL(15,2) NOT NULL

)
CREATE TABLE Cars
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	PlateNumber INT NOT NULL,
	Manufacturer NVARCHAR(30) NOT NULL,
	Model NVARCHAR(30) NOT NULL,
	CarYear INT,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Doors INT,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(30),
	Available BIT NOT NULL
)	
CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	Title NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)
CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	DriverLicenceNumber INT NOT NULL, 
	FullName NVARCHAR(30) NOT NULL, 
	[Address] NVARCHAR(30) NOT NULL, 
	City NVARCHAR(30) NOT NULL, 
	ZIPCode INT, 
	Notes NVARCHAR(MAX)
	
)
CREATE TABLE RentalOrders
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL, 
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
	TankLevel INT, 
	KilometrageStart INT, 
	KilometrageEnd INT, 
	TotalKilometrage INT, 
	StartDate DATETIME, 
	EndDate DATETIME, 
	TotalDays AS EndDate - StartDate,
	RateApplied DECIMAL(15, 2), 
	TaxRate INT, 
	OrderStatus INT, 
	Notes NVARCHAR(MAX)
)


INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('car', 10, 70, 280, 30),
('van', 10, 70, 280, 30),
('bus', 10, 70, 280, 30)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CategoryId, Available) VALUES
(0123, 'Opel', 'Corsa', 1, 0),
(01234, 'VW', 'Sharan', 2, 0),
(0123456, 'Mercedes', 'Veneno', 3, 0)

INSERT INTO Employees(FirstName, LastName, Title) VALUES
('Ivan', 'Ivanov','Saler'),
('Georgi', 'Georgiev','Rentar'),
('Dimitar', 'Dimitrov','Boss')

INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City) VALUES
(123, 'Sasho', 'Tam nqkyde', 'Sozopol'),
(234, 'Dimo', 'Nqkyde', 'Plovdiv'),
(345, 'Gosho', 'Tam', 'Sofia')

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId) VALUES
(1, 1 ,1),
(2, 2 ,2),
(3, 3, 3)