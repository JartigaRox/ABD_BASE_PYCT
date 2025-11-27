--Para hacer la base contenida
EXEC sp_configure 'contained database authentication', 1;  
RECONFIGURE;

--especificar en que base queremis crear el usuario contenido
USE master;
-- Forzar desconexión de usuarios activos y establecer modo single user temporalmente
ALTER DATABASE GimnasioDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Cambiar a base contenida
ALTER DATABASE GimnasioDB SET CONTAINMENT = PARTIAL;
-- Restaurar modo multi-user
ALTER DATABASE GimnasioDB SET MULTI_USER;

--Crear usuario sin login
USE GimnasioDB;
CREATE USER owner WITH PASSWORD = 'ContraOwner';
GO

--crear usuario gym_operador
CREATE USER gym_operador WITH PASSWORD = 'ContraOperador';
GO

--crear usuario finanzas
CREATE USER finanzas WITH PASSWORD  = 'ContraFinanzas';
GO

--crear usuario backup_operator
CREATE USER backup_operator WITH PASSWORD = 'ContraBackup';
GO

--crear usuario profesor
CREATE USER profesor WITH PASSWORD = 'ContraProfesor';
GO