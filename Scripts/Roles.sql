USE GimnasioDB;

CREATE ROLE R_owner;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Negocio TO owner;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Finanzas TO owner;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::RRHH TO owner;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Operaciones TO owner;
GO

-- Rol: gym_operador
CREATE ROLE R_gym_operador;
GRANT SELECT, UPDATE ON Negocio.Socio TO gym_operador;
GRANT SELECT, UPDATE ON Negocio.Clases TO gym_operador;
GRANT SELECT, UPDATE ON Negocio.SocioxClase TO gym_operador;
GRANT SELECT ON RRHH.Empleados TO gym_operador;
GRANT SELECT, UPDATE ON Operaciones.Equipo TO gym_operador;
GRANT SELECT ON Finanzas.Pagos TO gym_operador;
GO

-- Rol: finanzas
CREATE ROLE R_finanzas;
GRANT SELECT ON Negocio.Socio TO finanzas;
GRANT SELECT ON Negocio.Membresia TO finanzas;
GRANT SELECT, INSERT, UPDATE ON Finanzas.Pagos TO finanzas;
GRANT SELECT ON RRHH.Empleados TO finanzas;
GO

-- Rol: backup_operator
CREATE ROLE R_backup_operator;
GRANT SELECT ON SCHEMA::Negocio TO backup_operator;
GRANT SELECT ON SCHEMA::Finanzas TO backup_operator;
GRANT SELECT ON SCHEMA::RRHH TO backup_operator;
GRANT SELECT ON SCHEMA::Operaciones TO backup_operator;
GO
-- Rol: profesor
CREATE ROLE R_profesor;
GRANT SELECT ON SCHEMA::Negocio TO profesor;
GRANT SELECT ON SCHEMA::Finanzas TO profesor;
GRANT SELECT ON SCHEMA::RRHH TO profesor;
GRANT SELECT ON SCHEMA::Operaciones TO profesor;
GO
