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