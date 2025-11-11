CREATE DATABASE DB_StoneGym
USE DB_StoneGym

CREATE TABLE Planes (
	ID_Plan INT NOT NULL PRIMARY KEY,
	Nombre_Plan VARCHAR(50) NOT NULL,
	Descripcion TEXT,
)

CREATE TABLE Socio (
	ID_Socio INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL,
	Telefono VARCHAR(9),
	Email VARCHAR(20),
	ID_Plan INT,
	FOREIGN KEY (ID_Plan) REFERENCES Planes(ID_Plan)
)

CREATE TABLE Pagos (
	ID_Pago INT NOT NULL PRIMARY KEY,
	Metodo_pago VARCHAR(20) NOT NULL,
	Fecha_Pago DATE NOT NULL,
	Monto DECIMAL(10,2),
	ID_Socio INT,
	FOREIGN KEY (ID_Socio) REFERENCES Socio(ID_Socio)
)

CREATE TABLE Empleados (
	ID_Empleado INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(30) NOT NULL,
	Telefono VARCHAR(9),
	Email VARCHAR(20) NOT NULL,
	Puesto VARCHAR(15) NOT NULL,
)

CREATE TABLE Clases (
	ID_Clase INT NOT NULL PRIMARY KEY,
	Nombre_Clase VARCHAR(30) NOT NULL,
	Horario DATETIME,
	Instructor INT,
	FOREIGN KEY (Instructor) REFERENCES Empleados(ID_Empleado)
)

CREATE TABLE Equipo (
	ID_Equipo INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(30),
	Fecha_Compra DATE,
	Estado VARCHAR(15),
)

CREATE TABLE Mantenimiento(
	ID_Mantenimiento INT NOT NULL PRIMARY KEY,
	Fecha_Mantenimiento DATE,
	Descripcion TEXT,
	ID_Equipo INT,
	ID_Empleado INT,
	FOREIGN KEY (ID_Equipo) REFERENCES Equipo(ID_Equipo),
	FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID_Empleado),
)

CREATE TABLE Inscripciones (
    ID_Socio INT NOT NULL,
    ID_Clase INT NOT NULL,
    
    PRIMARY KEY (ID_Socio, ID_Clase),
    
    CONSTRAINT FK_Inscripciones_Socio FOREIGN KEY (ID_Socio) 
        REFERENCES Socio(ID_Socio),
    CONSTRAINT FK_Inscripciones_Clase FOREIGN KEY (ID_Clase) 
        REFERENCES Clases(ID_Clase)
)