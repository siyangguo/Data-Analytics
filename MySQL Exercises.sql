/* https://en.wikibooks.org/wiki/SQL_Exercises/The_computer_store */
CREATE TABLE Manufacturers(
	Code INTEGER PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL
);

CREATE TABLE Products(
	Code INTEGER PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL,
	Price REAL NOT NULL,
	Manufacturer INTEGER NOT NULL
	CONSTRAINT fk_Manufacturers_Code REFERENCES MANUFACTURERS(Code)
);
/* 16. Select the name of each manufacturer along with the name and price of its most expensive product. */
SELECT A.Name, A.Price, F.Name
From Products A Join Manufacturers F 
On A.Manufacturers=F.Code
AND A.Price=
(
	Select MAX(A.Price)
	From Products A
	Where A.Manufacturer=F.Code
)


/* https://en.wikibooks.org/wiki/SQL_Exercises/Employee_management */
CREATE TABLE Departments(
	Code INTEGER PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL,
	Budget REAL NOT NULL
);

CREATE TABLE Employees(
	SSN INTEGER PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL,
	LastName TEXT NOT NULL,
	Department INTEGER NOT NULL,
	CONSTRAINT fk_Departments_Code FOREIGN KEY(Department) REFERENCES Departments(Code)
);
/* 13.Select the departments with a budget larger than the average budget of all the departments. */
SELECT * 
FROM Departments
WHERE Budget>
(
	SELECT AVG(Budget)
	FROM Departments
)

/* https://en.wikibooks.org/wiki/SQL_Exercises/The_warehouse */
CREATE TABLE Warehouses(
	Code INTEGER PRIMARY KEY NOT NULL,
	Location TEXT NOT NULL,
	Capacity INTEGER NOT NULL
);

CREATE TABLE Boxed(
	Code TEXT PRIMARY KEY NOT NULL,
	Contents TEXT NOT NULL,
	Value REAL NOT NULL,
	Warehouse INTEGER NOT NULL,
	CONSTRAINT fk_Warehouses_Code FOREIGN KEY (Warehouse) REFERENCES Warehouses(Code)
);

/* 8. Select the warehouse codes, along with the number of boxes in each warehouse. Optionally, take into account that some warehouses are empty. */
SELECT Warehouses.Code
FROM Warehouses JOIN Boxes ON Warehouses.Code=Boxes.Warehouse
GROUP BY Warehouses.Code
HAVING COUNT(Boxes.Code)>Warehouses.Capacity

/* 14. Apply a 20% value reduction to boxes with a value larger than the average value of all the boxes. */
UPDATE Boxes 
SET Value=Value*0.8 
WHERE Value>(
	SELECT AVG(Value)
	FROM (
		SELECT *
		FROM Boxes
	) AS X
)

/* https://en.wikibooks.org/wiki/SQL_Exercises/Pieces_and_providers */
CREATE TABLE Pieces(
	Code INTEGER PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL
);

CREATE TABLE Providers(
	Code TEXT PRIMARY KEY NOT NULL,
	Name TEXT NOT NULL
);

CREATE TABLE Provides(
	Piece INTEGER
	CONSTRAINT fk_Pieces_Code REFERENCES Pieces(Code),
	Provide TEXT
	CONSTRAINT fk_Provides_Code REFERENCES Providers(Code),
	Price INTEGER NOT NULL,
	PRIMARY KEY(Piece, Provider)
);

/* 5. Select the name of pieces provided by provider with code "HAL". */
SELECT Name
FROM Pieces
WHERE EXISTS(
	SELECT * 
	FROM Provides
	WHERE Provider='HAL' AND Piece=Pieces.Code
)

/* 6. For each piece, find the most expensive offering of that piece and include the piece name, provider name, and price. */
SELECT Pieces.Name,Providers.Name,Price
FROM Pieces JOIN Provides ON Pieces.Code=Piece
JOIN Providers ON Providers.Code=Provider
WHERE Price=(
	SELECT MAX(Price)
	FROM Provides
	WHERE Piece=Pieces.Code
)

/* 
https://en.wikibooks.org/wiki/SQL_Exercises/Planet_Express
Which pilots transported those packages?
*/
Select E.Name
From Employee AS E 
Join Shipment AS S On E.EmployeeID=S.Manager
Join Package AS P On S.ShipmentID=P.Shipment
Where S.ShipmentID In (
	Select P.Shipment
	From Package AS P
	Join Client AS C On P.Sender=C.AccountNumber
	Where C.Accountment=(
		Select Client.AccountNumber
		From Client Join Package On Client.AccountNumber=Package.Recipient
		Where Package.weight=1.5
	) 
)
Group By (E.Name)


/* https://en.wikibooks.org/wiki/SQL_Exercises/The_Hospital */
/* Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform. */
Select Name
From Physician
Where EmployeeID IN
(
	Select Physician
	From Undergoes U
	WHERE NOT EXISTS(
		Select *
		From Trained_in 
		Where Treatment=Procedure AND Physician=U.Physician
	)
)

Select Name
From Physician
Where EmployeeID IN
(
	Select U.Physician
	From Undergoes U 
	LEFT JOIN Trained_In T ON U.Physician=T.Physician AND U.Procedures=T.Treatment
	WHERE Treatment IS NULL
)

SELECT P.Name
FROM Physicians AS P,
(
	SELECT Physician, Prodecure
	FROM Undergoes
	EXCEPT
	SELECT Physician, Treatment
	FROM Trained_In
) AS Pe
Where Pe.Physician=P.EmployeeID

/* Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on. */
SELECT P.Name,Pr.Name,U.Date,Pt.Name
FROM Physicians AS P, Procedure AS Pr, Undergoes AS U, Patient AS Pt,
(
	SELECT Physician,Prodecure
	FROM Undergoes
	EXCEPT
	SELECT Physician,Treatment
	FROM Trained_In
) AS Pe
WHERE Pe.EmployeeID=P.Physician AND Pe.Procedure=Pr.Code AND Pe.Physician=U.Physician AND Pe.Procedure=U.Procedure AND U.Patient=Pt.SSN

SELECT P.Name,Pr.Name,U.Date,Pt.Name
FROM Physicians AS P, Procedure AS Pr, Undergoes AS U, Patient AS Pt
WHERE P.EmployeeID=U.Physicians AND Pt.SSN=U.Patient AND Pr.Code=U.Procedure
AND NOT EXISTS (
	SELECT * 
	FROM Train_In AS T
	WHERE T.Treatment=U.Procedure AND T.Physician=U.Physician
)

/* Obtain the names of all physicians that have performed a medical procedure that they are certified to perform, but such that the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires). */
Select Name
From Physician
Where EmployeeID IN
(
	Select Physician
	From Undergoes U
	WHERE Date>(
		Select CertificationExpires
		From Trained_in AS T
		Where T.Treatment=U.Procedure AND T.Physician=U.Physician
	)
)

SELECT P.Name
FROM Physicians AS P, Procedure AS Pr, Undergoes AS U, Trained_In AS T
WHERE P.EmployeeID=U.Physician AND U.Treatment=T.Treatment AND U.Physician=T.Physician AND U.Date>T.CertificationExpires

/* Obtain the information for appointments where a patient met with a physician other than his/her primary care physician. Show the following information: Patient name, physician name, nurse name (if any), start and end time of appointment, examination room, and the name of the patient's primary care physician. */
SELECT Pt.Name, Ph.Name, N.name, A.Start, A.End, A.Examination, PhPCP.Name
FROM Patient Pt, Physician Ph, Physician PhPCP, Nurse N Right Join Appointment A On A.PrepNurse=N.EmployeeID
WHERE Pt.SSN=A.Patient AND Ph.EmployeeID=A.Physician AND PhPCP.EmployeeID=Pt.PCP AND Pt.PCP<>A.Physician

/* The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. There are no constraints in force to prevent inconsistencies between these two tables. More specifically, the Undergoes table may include a row where the patient ID does not match the one we would obtain from the Stay table through the Undergoes.Stay foreign key. Select all rows from Undergoes that exhibit this inconsistency. */
SELECT Pt.Name, PhPCP.Name
FROM Patient AS Pt, Physicians AS PhPCP
WHERE Pt.PCP=PhPCP.EmployeeID AND EXISTS (
	SELECT * 
	FROM Prescribes AS Pr
	WHERE Pr.Patient=Pt.SSN AND Pr.Physician=Pt.PCP
) AND EXISTS (
	SELECT * 
	FROM Undergoes AS U, Procedure AS Pr
	WHERE Pt.SSN=U.Patient AND U.Procedure=Pr.Code AND Pr.Cost>5000
) AND 2<=(
	SELECT COUNT(*)
	FROM Appointment AS A, Nurse N
	WHERE Pt.SSN=A.Patient AND A.PrepNurse=N.EmployeeID AND N.Registered=1
) AND Pt.PCP NOT IN (
	SELECT Head
	FROM Department
)

/* https://www.hackerrank.com/challenges/symmetric-pairs/problem */

/* https://www.hackerrank.com/challenges/earnings-of-employees/problem */

/* https://www.hackerrank.com/challenges/weather-observation-station-20/problem */