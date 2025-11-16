USE GimnasioDB;
-- Índices en Negocio.Socio
CREATE NONCLUSTERED INDEX IX_Socio_Email ON Negocio.Socio(Email);
CREATE NONCLUSTERED INDEX IX_Socio_Plan ON Negocio.Socio(ID_plan) INCLUDE (Nombre, Email, Activo);
CREATE NONCLUSTERED INDEX IX_Socio_Activo ON Negocio.Socio(Activo) WHERE Activo = 1;
GO

-- Índices en Finanzas.Pagos
CREATE NONCLUSTERED INDEX IX_Pagos_Socio ON Finanzas.Pagos(ID_Socio) INCLUDE (Fecha_pago, Monto);
CREATE NONCLUSTERED INDEX IX_Pagos_Fecha ON Finanzas.Pagos(Fecha_pago DESC);
CREATE NONCLUSTERED INDEX IX_Pagos_Estado ON Finanzas.Pagos(Estado) WHERE Estado = 'Completado';
GO

-- Índices en Negocio.Clases
CREATE NONCLUSTERED INDEX IX_Clases_Empleado ON Negocio.Clases(ID_empleado);
CREATE NONCLUSTERED INDEX IX_Clases_Activo ON Negocio.Clases(Activo) WHERE Activo = 1;
GO

-- Índices en RRHH.Empleados
CREATE NONCLUSTERED INDEX IX_Empleados_Email ON RRHH.Empleados(Email);
CREATE NONCLUSTERED INDEX IX_Empleados_Puesto ON RRHH.Empleados(Puesto) INCLUDE (Nombre, Salario);
GO

-- Índices en Operaciones
CREATE NONCLUSTERED INDEX IX_Mantenimiento_Equipo ON Operaciones.Mantenimiento(ID_Equipo, Fecha_mantenimiento DESC);
CREATE NONCLUSTERED INDEX IX_Mantenimiento_Fecha ON Operaciones.Mantenimiento(Fecha_mantenimiento DESC);
CREATE NONCLUSTERED INDEX IX_Equipo_Estado ON Operaciones.Equipo(Estado);
GO
