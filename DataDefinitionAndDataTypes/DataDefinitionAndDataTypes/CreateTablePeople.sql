CREATE TABLE People
(
	Id INT PRIMARY KEY IDENTITY(1,1),
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(3,2),
	[Weight] DECIMAL(3,2),
	Gender CHAR(1) NULL CHECK (Gender='m' OR Gender='f'),
	Birthdate DATETIME NOT NULL,
	Biography NVARCHAR(MAX)
);

INSERT INTO People([Name], Gender, Birthdate) VALUES
('Ivan', 'm', '12.02.1980'),
('Pesho', 'm', '09.12.1990'),
('Slavin', 'm', '04.04.2001'),
('Drago', 'm', '08.22.2002'),
('Georgi', 'm', '10.15.1989')

--Make Id primary key. Populate the table with only 5 records.
--Submit your CREATE and INSERT statements as Run queries & check DB.
