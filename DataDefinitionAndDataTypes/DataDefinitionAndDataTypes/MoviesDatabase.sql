CREATE DATABASE Movies

CREATE TABLE Directors
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	DirectorName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)

)
CREATE TABLE Genres 
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	GenreName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)	
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CategoryName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)
CREATE TABLE Movies 
(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL, 
	Title NVARCHAR(MAX) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DATETIME,
	[Length] DATETIME2,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors(DirectorName) VALUES
('Ivan'),
('Georgi'),
('Pesho'),
('Kalin'),
('Sasho')

INSERT INTO Genres(GenreName) VALUES
('Horror'),
('Comedy'),
('SciFi'),
('Action'),
('Drama')

INSERT INTO Categories(CategoryName) VALUES
('asdf'),
('asdfg'),
('asdfgh'),
('asdfghj'),
('zxcv')

INSERT INTO Movies(Title, DirectorId, GenreId, CategoryId) VALUES
('Avengers', 2, 2, 2),
('Avengers Two', 3, 3, 3),
('Avengers Three', 1, 1, 1),
('Avengers Four', 5 ,5 ,5),
('Avengers Five', 4, 4, 4)