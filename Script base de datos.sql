-- Creación de la base de datos
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GimnasioDB')
BEGIN
    ALTER DATABASE GimnasioDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GimnasioDB;
END
GO

CREATE DATABASE GimnasioDB
ON PRIMARY -- Datos principales y tablas
(
    NAME = 'GimnasioDB_Data',
    FILENAME = 'C:\Backups\GimnasioDB\GimnasioDB_Data.mdf', -- Cambien la dirección a donde guarden los backups
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
)
LOG ON -- logs
(
    NAME = 'GimnasioDB_Log',
    FILENAME = 'C:\Backups\GimnasioDB\GimnasioDB_Log.ldf', -- Cambien la dirección a donde guarden los backups
    SIZE = 50MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 10MB
);
GO
USE GimnasioDB;

-- Configuraciones de la base de datos (REcuperación y estadísticas)
ALTER DATABASE GimnasioDB SET RECOVERY FULL;
ALTER DATABASE GimnasioDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE GimnasioDB SET AUTO_UPDATE_STATISTICS ON;
GO

-- Creación de esquemas
CREATE SCHEMA Negocio AUTHORIZATION dbo;
GO
CREATE SCHEMA Finanzas AUTHORIZATION dbo;
GO
CREATE SCHEMA RRHH AUTHORIZATION dbo;
GO
CREATE SCHEMA Operaciones AUTHORIZATION dbo;
GO

-- Creación de tablas

-- ESQUEMA NEGOCIO
-- Tabla: Membresia
CREATE TABLE Negocio.Membresia (
    ID_membresia INT IDENTITY(1,1) NOT NULL,
    Nombre_plan NVARCHAR(100) NOT NULL,
    Precio_mensual DECIMAL(10,2) NOT NULL,
    Descripcion NVARCHAR(500),
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_Membresia PRIMARY KEY CLUSTERED (ID_membresia)
) ON [PRIMARY];
GO

-- Tabla: Socio
CREATE TABLE Negocio.Socio (
    ID_socio INT IDENTITY(1,1) NOT NULL,
    ID_plan INT NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    FechaRegistro DATETIME2 DEFAULT GETDATE(),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_Socio PRIMARY KEY CLUSTERED (ID_socio),
    CONSTRAINT FK_Socio_Membresia FOREIGN KEY (ID_plan) REFERENCES Negocio.Membresia(ID_membresia)
) ON [PRIMARY];
GO

-- Tabla: Clases
CREATE TABLE Negocio.Clases (
    ID_Clase INT IDENTITY(1,1) NOT NULL,
    Nombre_clase NVARCHAR(100) NOT NULL,
    Horario NVARCHAR(50),
    ID_empleado INT,
    Capacidad INT,
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_Clases PRIMARY KEY CLUSTERED (ID_Clase)
) ON [PRIMARY];
GO

-- Tabla: SocioxClase 
CREATE TABLE Negocio.SocioxClase (
    ID_Socio INT NOT NULL,
    ID_Clase INT NOT NULL,
    FechaInscripcion DATETIME2 DEFAULT GETDATE(),
    Estado NVARCHAR(20) DEFAULT 'Activo',
    CONSTRAINT PK_SocioxClase PRIMARY KEY CLUSTERED (ID_Socio, ID_Clase),
    CONSTRAINT FK_SocioxClase_Socio FOREIGN KEY (ID_Socio) REFERENCES Negocio.Socio(ID_socio),
    CONSTRAINT FK_SocioxClase_Clase FOREIGN KEY (ID_Clase) REFERENCES Negocio.Clases(ID_Clase)
) ON [PRIMARY];
GO

-- ESQUEMA FINANZAS
-- Tabla: Pagos
CREATE TABLE Finanzas.Pagos (
    ID_Pago INT IDENTITY(1,1) NOT NULL,
    ID_Socio INT NOT NULL,
    Metodo_pago NVARCHAR(50),
    Fecha_pago DATETIME2 DEFAULT GETDATE(),
    Monto DECIMAL(10,2) NOT NULL,
    Periodo NVARCHAR(50),
    Estado NVARCHAR(20) DEFAULT 'Completado',
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    CONSTRAINT PK_Pagos PRIMARY KEY CLUSTERED (ID_Pago),
    CONSTRAINT FK_Pagos_Socio FOREIGN KEY (ID_Socio) REFERENCES Negocio.Socio(ID_socio)
) ON [PRIMARY];
GO

-- ESQUEMA RRHH
-- Tabla: Empleados
CREATE TABLE RRHH.Empleados (
    CarnetEmpleado INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    Puesto NVARCHAR(50),
    FechaContratacion DATETIME2 DEFAULT GETDATE(),
    Salario DECIMAL(10,2),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_Empleados PRIMARY KEY CLUSTERED (CarnetEmpleado)
) ON [PRIMARY];
GO

-- Agregar FK de Empleados a Clases
ALTER TABLE Negocio.Clases
ADD CONSTRAINT FK_Clases_Empleado FOREIGN KEY (ID_empleado) REFERENCES RRHH.Empleados(CarnetEmpleado);
GO

-- ESQUEMA OPERACIONES
-- Tabla: Equipo
CREATE TABLE Operaciones.Equipo (
    ID_Equipo INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Fecha_compra DATETIME2,
    Estado NVARCHAR(50) DEFAULT 'Operativo',
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    CONSTRAINT PK_Equipo PRIMARY KEY CLUSTERED (ID_Equipo)
) ON [PRIMARY];
GO

-- Tabla: Mantenimiento
CREATE TABLE Operaciones.Mantenimiento (
    ID_Mantenimiento INT IDENTITY(1,1) NOT NULL,
    ID_Equipo INT NOT NULL,
    ID_Empleado INT NOT NULL,
    Fecha_mantenimiento DATETIME2 DEFAULT GETDATE(),
    Descripcion NVARCHAR(500),
    Costo DECIMAL(10,2),
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    CONSTRAINT PK_Mantenimiento PRIMARY KEY CLUSTERED (ID_Mantenimiento),
    CONSTRAINT FK_Mantenimiento_Equipo FOREIGN KEY (ID_Equipo) REFERENCES Operaciones.Equipo(ID_Equipo),
    CONSTRAINT FK_Mantenimiento_Empleado FOREIGN KEY (ID_Empleado) REFERENCES RRHH.Empleados(CarnetEmpleado)
) ON [PRIMARY];
GO
