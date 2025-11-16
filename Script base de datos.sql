<<<<<<< HEAD
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
=======
-- =====================================================================
-- IMPLEMENTACIÓN COMPLETA BASE DE DATOS GIMNASIO
-- Incluye: Diseño, Seguridad, Optimización, Respaldo y Migración
-- =====================================================================

USE master;
GO

-- =====================================================================
-- 1. CREACIÓN DE BASE DE DATOS CON DIMENSIONAMIENTO
-- =====================================================================

-- Crear BD con configuración de almacenamiento optimizada
CREATE DATABASE DB_GYM_STONE
-- ON PRIMARY 
-- (
--     NAME = N'Gimnasio_Data',
--     FILENAME = N'C:\SQLData\Gimnasio_Data.mdf',
--     SIZE = 100MB,              
--     MAXSIZE = 2GB,             
--     FILEGROWTH = 10MB          
-- )
-- LOG ON 
-- (
--     NAME = N'Gimnasio_Log',
--     FILENAME = N'C:\SQLData\Gimnasio_Log.ldf',
--     SIZE = 50MB,
--     MAXSIZE = 500MB,
--     FILEGROWTH = 5MB
-- );
>>>>>>> aa06cc34edcc9889b4a0afd01e07dcb7ae1b6f9a
GO
USE GimnasioDB;

<<<<<<< HEAD
-- Configuraciones de la base de datos (REcuperación y estadísticas)
ALTER DATABASE GimnasioDB SET RECOVERY FULL;
ALTER DATABASE GimnasioDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE GimnasioDB SET AUTO_UPDATE_STATISTICS ON;
GO

-- Creación de esquemas
CREATE SCHEMA Negocio AUTHORIZATION dbo;
=======
-- Configurar modelo de recuperación FULL para respaldos
ALTER DATABASE DB_GYM_STONE SET RECOVERY FULL;
GO

USE DB_GYM_STONE;
GO

-- =====================================================================
-- 2. CREACIÓN DE ESQUEMAS PARA ORGANIZACIÓN
-- =====================================================================

CREATE SCHEMA Membresia AUTHORIZATION dbo;
GO
CREATE SCHEMA Operaciones AUTHORIZATION dbo;
>>>>>>> aa06cc34edcc9889b4a0afd01e07dcb7ae1b6f9a
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
<<<<<<< HEAD
=======

-- Tabla de Inscripciones
CREATE TABLE Operaciones.Inscripciones (
    ID_Inscripcion INT IDENTITY(1,1) NOT NULL,
    ID_Socio INT NOT NULL,
    ID_Clase INT NOT NULL,
    Fecha_Inscripcion DATETIME2 NOT NULL DEFAULT GETDATE(),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Confirmada',
    Asistio BIT NULL,
    Fecha_Asistencia DATETIME2 NULL,
    Fecha_Creacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    Usuario_Creacion VARCHAR(50) NOT NULL DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_Inscripciones PRIMARY KEY CLUSTERED (ID_Inscripcion),
    CONSTRAINT FK_Inscripciones_Socio FOREIGN KEY (ID_Socio) REFERENCES Membresia.Socio(ID_Socio),
    CONSTRAINT FK_Inscripciones_Clase FOREIGN KEY (ID_Clase) REFERENCES Operaciones.Clases(ID_Clase),
    CONSTRAINT UQ_Socio_Clase UNIQUE (ID_Socio, ID_Clase),
    CONSTRAINT CHK_Estado_Inscripcion CHECK (Estado IN ('Confirmada', 'Cancelada', 'En Espera'))
);
GO

-- Tabla de Auditoría
CREATE TABLE dbo.Auditoria (
    ID_Auditoria BIGINT IDENTITY(1,1) NOT NULL,
    Tabla VARCHAR(100) NOT NULL,
    Operacion VARCHAR(20) NOT NULL,
    Usuario VARCHAR(100) NOT NULL,
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    Datos_Anteriores NVARCHAR(MAX),
    Datos_Nuevos NVARCHAR(MAX),
    CONSTRAINT PK_Auditoria PRIMARY KEY CLUSTERED (ID_Auditoria)
);
GO

-- =====================================================================
-- 4. OPTIMIZACIÓN - CREACIÓN DE ÍNDICES
-- =====================================================================

-- Índices para tabla Socios
CREATE NONCLUSTERED INDEX IX_Socio_Email ON Membresia.Socio(Email);
CREATE NONCLUSTERED INDEX IX_Socio_Plan ON Membresia.Socio(ID_Plan) INCLUDE (Estado, Fecha_Vencimiento);
CREATE NONCLUSTERED INDEX IX_Socio_Estado ON Membresia.Socio(Estado) INCLUDE (Nombre, Apellido, Email);
CREATE NONCLUSTERED INDEX IX_Socio_FechaInscripcion ON Membresia.Socio(Fecha_Inscripcion);
GO

-- Índices para tabla Pagos
CREATE NONCLUSTERED INDEX IX_Pagos_Socio ON Finanzas.Pagos(ID_Socio) INCLUDE (Fecha_Pago, Monto);
CREATE NONCLUSTERED INDEX IX_Pagos_Fecha ON Finanzas.Pagos(Fecha_Pago) INCLUDE (Monto, Metodo_Pago);
CREATE NONCLUSTERED INDEX IX_Pagos_Estado ON Finanzas.Pagos(Estado_Pago, Fecha_Pago);
GO

-- Índices para tabla Clases
CREATE NONCLUSTERED INDEX IX_Clases_Instructor ON Operaciones.Clases(ID_Instructor) INCLUDE (Nombre_Clase, Horario_Inicio);
CREATE NONCLUSTERED INDEX IX_Clases_Horario ON Operaciones.Clases(Horario_Inicio, Horario_Fin) INCLUDE (Nombre_Clase, Cupo_Maximo);
CREATE NONCLUSTERED INDEX IX_Clases_Activo ON Operaciones.Clases(Activo) INCLUDE (Nombre_Clase);
GO

-- Índices para tabla Inscripciones
CREATE NONCLUSTERED INDEX IX_Inscripciones_Clase ON Operaciones.Inscripciones(ID_Clase) INCLUDE (Estado);
CREATE NONCLUSTERED INDEX IX_Inscripciones_Fecha ON Operaciones.Inscripciones(Fecha_Inscripcion);
GO

-- Índices para tabla Mantenimiento
CREATE NONCLUSTERED INDEX IX_Mantenimiento_Equipo ON Recursos.Mantenimiento(ID_Equipo) INCLUDE (Fecha_Mantenimiento);
CREATE NONCLUSTERED INDEX IX_Mantenimiento_ProximaFecha ON Recursos.Mantenimiento(Proximo_Mantenimiento) WHERE Proximo_Mantenimiento IS NOT NULL;
GO

-- =====================================================================
-- 5. VISTAS CON FUNCIONES VENTANA PARA ANÁLISIS
-- =====================================================================

-- Vista: Socios con ranking de antigüedad
CREATE VIEW Membresia.v_Socios_Ranking AS
SELECT 
    ID_Socio,
    Nombre + ' ' + Apellido AS Nombre_Completo,
    Email,
    Fecha_Inscripcion,
    DATEDIFF(DAY, Fecha_Inscripcion, GETDATE()) AS Dias_Antiguedad,
    Estado,
    RANK() OVER (ORDER BY Fecha_Inscripcion) AS Ranking_Antiguedad,
    ROW_NUMBER() OVER (PARTITION BY Estado ORDER BY Fecha_Inscripcion) AS Numero_Por_Estado
FROM Membresia.Socio;
GO

-- Vista: Análisis de ingresos mensuales con acumulado
CREATE VIEW Finanzas.v_Ingresos_Mensuales AS
SELECT 
    YEAR(Fecha_Pago) AS Anio,
    MONTH(Fecha_Pago) AS Mes,
    DATENAME(MONTH, Fecha_Pago) AS Nombre_Mes,
    COUNT(*) AS Cantidad_Pagos,
    SUM(Monto) AS Total_Mensual,
    AVG(Monto) AS Promedio_Pago,
    SUM(SUM(Monto)) OVER (PARTITION BY YEAR(Fecha_Pago) ORDER BY MONTH(Fecha_Pago)) AS Acumulado_Anual,
    SUM(Monto) - LAG(SUM(Monto)) OVER (PARTITION BY YEAR(Fecha_Pago) ORDER BY MONTH(Fecha_Pago)) AS Variacion_Mes_Anterior
FROM Finanzas.Pagos
WHERE Estado_Pago = 'Completado'
GROUP BY YEAR(Fecha_Pago), MONTH(Fecha_Pago), DATENAME(MONTH, Fecha_Pago);
GO

-- Vista: Popularidad de clases
CREATE VIEW Operaciones.v_Popularidad_Clases AS
SELECT 
    c.ID_Clase,
    c.Nombre_Clase,
    c.Cupo_Maximo,
    COUNT(i.ID_Inscripcion) AS Total_Inscripciones,
    CAST(COUNT(i.ID_Inscripcion) AS FLOAT) / c.Cupo_Maximo * 100 AS Porcentaje_Ocupacion,
    DENSE_RANK() OVER (ORDER BY COUNT(i.ID_Inscripcion) DESC) AS Ranking_Popularidad,
    e.Nombre + ' ' + e.Apellido AS Instructor
FROM Operaciones.Clases c
LEFT JOIN Operaciones.Inscripciones i ON c.ID_Clase = i.ID_Clase AND i.Estado = 'Confirmada'
INNER JOIN Recursos.Empleados e ON c.ID_Instructor = e.ID_Empleado
GROUP BY c.ID_Clase, c.Nombre_Clase, c.Cupo_Maximo, e.Nombre, e.Apellido;
GO

-- Vista: Dashboard principal
CREATE VIEW dbo.v_Dashboard_Principal AS
SELECT 
    (SELECT COUNT(*) FROM Membresia.Socio WHERE Estado = 'Activo') AS Socios_Activos,
    (SELECT COUNT(*) FROM Operaciones.Clases WHERE Activo = 1) AS Clases_Activas,
    (SELECT SUM(Monto) FROM Finanzas.Pagos WHERE MONTH(Fecha_Pago) = MONTH(GETDATE()) AND YEAR(Fecha_Pago) = YEAR(GETDATE())) AS Ingresos_Mes_Actual,
    (SELECT COUNT(*) FROM Recursos.Equipo WHERE Estado = 'Operativo') AS Equipos_Operativos,
    (SELECT COUNT(*) FROM Recursos.Empleados WHERE Activo = 1) AS Empleados_Activos;
GO

-- =====================================================================
-- 6. PROCEDIMIENTOS ALMACENADOS
-- =====================================================================

-- SP: Inscribir socio a clase
CREATE PROCEDURE Operaciones.sp_Inscribir_Clase
    @ID_Socio INT,
    @ID_Clase INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar cupo disponible
        DECLARE @CupoActual INT, @CupoMaximo INT;
        SELECT @CupoActual = Cupo_Actual, @CupoMaximo = Cupo_Maximo 
        FROM Operaciones.Clases 
        WHERE ID_Clase = @ID_Clase;
        
        IF @CupoActual >= @CupoMaximo
        BEGIN
            RAISERROR('No hay cupo disponible en esta clase', 16, 1);
            RETURN;
        END
        
        -- Insertar inscripción
        INSERT INTO Operaciones.Inscripciones (ID_Socio, ID_Clase, Estado)
        VALUES (@ID_Socio, @ID_Clase, 'Confirmada');
        
        -- Actualizar cupo
        UPDATE Operaciones.Clases 
        SET Cupo_Actual = Cupo_Actual + 1 
        WHERE ID_Clase = @ID_Clase;
        
        COMMIT TRANSACTION;
        SELECT 'Inscripción exitosa' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP: Procesar pago
CREATE PROCEDURE Finanzas.sp_Procesar_Pago
    @ID_Socio INT,
    @Monto DECIMAL(10,2),
    @Metodo_Pago VARCHAR(30),
    @Referencia VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insertar pago
        INSERT INTO Finanzas.Pagos (ID_Socio, Monto, Metodo_Pago, Referencia_Transaccion, Estado_Pago)
        VALUES (@ID_Socio, @Monto, @Metodo_Pago, @Referencia, 'Completado');
        
        -- Actualizar fecha de vencimiento del socio
        UPDATE Membresia.Socio
        SET Fecha_Vencimiento = DATEADD(MONTH, 1, ISNULL(Fecha_Vencimiento, GETDATE())),
            Estado = 'Activo'
        WHERE ID_Socio = @ID_Socio;
        
        COMMIT TRANSACTION;
        SELECT 'Pago procesado exitosamente' AS Mensaje, SCOPE_IDENTITY() AS ID_Pago;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP: Reporte de socios por vencer
CREATE PROCEDURE Membresia.sp_Socios_Por_Vencer
    @Dias_Anticipo INT = 7
AS
BEGIN
    SELECT 
        s.ID_Socio,
        s.Nombre + ' ' + s.Apellido AS Nombre_Completo,
        s.Email,
        s.Telefono,
        s.Fecha_Vencimiento,
        DATEDIFF(DAY, GETDATE(), s.Fecha_Vencimiento) AS Dias_Restantes,
        p.Nombre_Plan,
        p.Precio_Mensual
    FROM Membresia.Socio s
    INNER JOIN Membresia.Planes p ON s.ID_Plan = p.ID_Plan
    WHERE s.Estado = 'Activo'
        AND s.Fecha_Vencimiento IS NOT NULL
        AND DATEDIFF(DAY, GETDATE(), s.Fecha_Vencimiento) BETWEEN 0 AND @Dias_Anticipo
    ORDER BY s.Fecha_Vencimiento;
END;
GO

-- =====================================================================
-- 7. TRIGGERS DE AUDITORÍA
-- =====================================================================

-- Trigger: Auditoría de Socios
CREATE TRIGGER Membresia.tr_Socio_Auditoria
ON Membresia.Socio
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Operacion VARCHAR(20);
    
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @Operacion = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @Operacion = 'INSERT';
    ELSE
        SET @Operacion = 'DELETE';
    
    INSERT INTO dbo.Auditoria (Tabla, Operacion, Usuario, Datos_Anteriores, Datos_Nuevos)
    SELECT 
        'Membresia.Socio',
        @Operacion,
        SUSER_SNAME(),
        (SELECT * FROM deleted FOR JSON PATH),
        (SELECT * FROM inserted FOR JSON PATH);
END;
GO

-- Trigger: Auditoría de Pagos
CREATE TRIGGER Finanzas.tr_Pagos_Auditoria
ON Finanzas.Pagos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Operacion VARCHAR(20);
    
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @Operacion = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @Operacion = 'INSERT';
    ELSE
        SET @Operacion = 'DELETE';
    
    INSERT INTO dbo.Auditoria (Tabla, Operacion, Usuario, Datos_Anteriores, Datos_Nuevos)
    SELECT 
        'Finanzas.Pagos',
        @Operacion,
        SUSER_SNAME(),
        (SELECT * FROM deleted FOR JSON PATH),
        (SELECT * FROM inserted FOR JSON PATH);
END;
GO

-- =====================================================================
-- 8. SEGURIDAD - CREACIÓN DE ROLES Y USUARIOS
-- =====================================================================

-- Crear Logins a nivel de servidor
USE master;
GO

CREATE LOGIN admin_gimnasio WITH PASSWORD = 'Admin$2024Gym!', CHECK_POLICY = ON;
CREATE LOGIN recepcion_user WITH PASSWORD = 'Recep$2024!', CHECK_POLICY = ON;
CREATE LOGIN instructor_user WITH PASSWORD = 'Instruct$2024!', CHECK_POLICY = ON;
CREATE LOGIN contador_user WITH PASSWORD = 'Contab$2024!', CHECK_POLICY = ON;
CREATE LOGIN reportes_user WITH PASSWORD = 'Report$2024!', CHECK_POLICY = ON;
GO

USE DB_GYM_STONE;
GO

-- Crear usuarios en la base de datos
CREATE USER admin_gimnasio FOR LOGIN admin_gimnasio;
CREATE USER recepcion_user FOR LOGIN recepcion_user;
CREATE USER instructor_user FOR LOGIN instructor_user;
CREATE USER contador_user FOR LOGIN contador_user;
CREATE USER reportes_user FOR LOGIN reportes_user;
GO

-- Crear Roles personalizados
CREATE ROLE Administrador;
CREATE ROLE Recepcionista;
CREATE ROLE Instructor;
CREATE ROLE Contador;
CREATE ROLE Reportes;
GO

-- Asignar permisos al rol Administrador
ALTER ROLE db_owner ADD MEMBER admin_gimnasio;
GO

-- Permisos para Recepcionista
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Membresia TO Recepcionista;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Operaciones TO Recepcionista;
GRANT SELECT ON SCHEMA::Recursos TO Recepcionista;
GRANT EXECUTE ON Operaciones.sp_Inscribir_Clase TO Recepcionista;
GRANT EXECUTE ON Membresia.sp_Socios_Por_Vencer TO Recepcionista;
ALTER ROLE Recepcionista ADD MEMBER recepcion_user;
GO

-- Permisos para Instructor
GRANT SELECT ON SCHEMA::Operaciones TO Instructor;
GRANT SELECT ON Membresia.Socio TO Instructor;
GRANT UPDATE ON Operaciones.Inscripciones TO Instructor;
ALTER ROLE Instructor ADD MEMBER instructor_user;
GO

-- Permisos para Contador
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Finanzas TO Contador;
GRANT SELECT ON SCHEMA::Membresia TO Contador;
GRANT EXECUTE ON Finanzas.sp_Procesar_Pago TO Contador;
ALTER ROLE Contador ADD MEMBER contador_user;
GO

-- Permisos para Reportes (solo lectura)
GRANT SELECT ON SCHEMA::Membresia TO Reportes;
GRANT SELECT ON SCHEMA::Operaciones TO Reportes;
GRANT SELECT ON SCHEMA::Finanzas TO Reportes;
GRANT SELECT ON SCHEMA::Recursos TO Reportes;
ALTER ROLE Reportes ADD MEMBER reportes_user;
GO

-- =====================================================================
-- 9. POLÍTICA DE SEGURIDAD A NIVEL DE FILA (RLS)
-- =====================================================================

-- Habilitar Row-Level Security para tabla de empleados
-- (Los instructores solo pueden ver sus propias clases)

CREATE FUNCTION Operaciones.fn_ClasesInstructor(@ID_Instructor INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS resultado
    WHERE @ID_Instructor = (
        SELECT e.ID_Empleado 
        FROM Recursos.Empleados e 
        WHERE e.Email = USER_NAME()
    ) OR IS_ROLEMEMBER('Administrador') = 1 OR IS_ROLEMEMBER('Recepcionista') = 1;
GO

CREATE SECURITY POLICY Operaciones.ClasesInstructorPolicy
ADD FILTER PREDICATE Operaciones.fn_ClasesInstructor(ID_Instructor)
ON Operaciones.Clases
WITH (STATE = OFF); -- Cambiar a ON cuando se implemente completamente
GO

-- =====================================================================
-- 10. ESTRATEGIA DE RESPALDO Y RECUPERACIÓN
-- =====================================================================

-- Script para respaldo completo (ejecutar en SQL Agent)
/*
BACKUP DATABASE DB_GYM_STONE
TO DISK = 'C:\SQLBackups\Gimnasio_Full.bak'
WITH 
    COMPRESSION,
    DESCRIPTION = 'Respaldo completo de Base de Datos Gimnasio',
    NAME = 'Gimnasio-Full',
    STATS = 10,
    CHECKSUM;
GO
*/

-- Script para respaldo diferencial (ejecutar diariamente)
/*
BACKUP DATABASE DB_GYM_STONE
TO DISK = 'C:\SQLBackups\Gimnasio_Diff.bak'
WITH 
    DIFFERENTIAL,
    COMPRESSION,
    DESCRIPTION = 'Respaldo diferencial de Base de Datos Gimnasio',
    NAME = 'Gimnasio-Differential',
    STATS = 10;
GO
*/

-- Script para respaldo de log (ejecutar cada hora)
/*
BACKUP LOG DB_GYM_STONE
TO DISK = 'C:\SQLBackups\Gimnasio_Log.trn'
WITH 
    COMPRESSION,
    DESCRIPTION = 'Respaldo de Log de transacciones',
    NAME = 'Gimnasio-Log',
    STATS = 10;
GO
*/

-- Script de recuperación
/*
-- 1. Restaurar respaldo completo
RESTORE DATABASE DB_GYM_STONE
FROM DISK = 'C:\SQLBackups\Gimnasio_Full.bak'
WITH NORECOVERY, REPLACE;

-- 2. Restaurar respaldo diferencial
RESTORE DATABASE DB_GYM_STONE
FROM DISK = 'C:\SQLBackups\Gimnasio_Diff
>>>>>>> aa06cc34edcc9889b4a0afd01e07dcb7ae1b6f9a
