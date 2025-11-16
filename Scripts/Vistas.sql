USE GimnasioDB;
GO

-- Vista: Reporte de Pagos con Ranking
CREATE VIEW Finanzas.vw_ReportePagosRanking
AS
SELECT 
    p.ID_Pago,
    s.ID_socio,
    s.Nombre AS NombreSocio,
    p.Monto,
    p.Fecha_pago,
    p.Metodo_pago,
    ROW_NUMBER() OVER (PARTITION BY YEAR(p.Fecha_pago), MONTH(p.Fecha_pago) ORDER BY p.Monto DESC) AS RankingMensual,
    SUM(p.Monto) OVER (PARTITION BY s.ID_socio ORDER BY p.Fecha_pago) AS MontoAcumulado,
    AVG(p.Monto) OVER (PARTITION BY s.ID_socio) AS PromedioSocio
FROM Finanzas.Pagos p
INNER JOIN Negocio.Socio s ON p.ID_Socio = s.ID_socio;
GO

-- Vista: Análisis de Clases
CREATE VIEW Negocio.vw_AnalisisClases
AS
SELECT 
    c.ID_Clase,
    c.Nombre_clase,
    c.Horario,
    e.Nombre AS Instructor,
    COUNT(sc.ID_Socio) AS TotalInscritos,
    c.Capacidad,
    c.Capacidad - COUNT(sc.ID_Socio) AS CuposDisponibles,
    CAST(COUNT(sc.ID_Socio) * 100.0 / NULLIF(c.Capacidad, 0) AS DECIMAL(5,2)) AS PorcentajeOcupacion
FROM Negocio.Clases c
LEFT JOIN Negocio.SocioxClase sc ON c.ID_Clase = sc.ID_Clase AND sc.Estado = 'Activo'
LEFT JOIN RRHH.Empleados e ON c.ID_empleado = e.CarnetEmpleado
WHERE c.Activo = 1
GROUP BY c.ID_Clase, c.Nombre_clase, c.Horario, e.Nombre, c.Capacidad;
GO

-- Vista: Reporte de Mantenimiento
CREATE VIEW Operaciones.vw_HistorialMantenimiento
AS
SELECT 
    m.ID_Mantenimiento,
    eq.Nombre AS NombreEquipo,
    eq.Estado AS EstadoEquipo,
    e.Nombre AS Responsable,
    m.Fecha_mantenimiento,
    m.Descripcion,
    m.Costo,
    ROW_NUMBER() OVER (PARTITION BY eq.ID_Equipo ORDER BY m.Fecha_mantenimiento DESC) AS UltimoMantenimiento,
    SUM(m.Costo) OVER (PARTITION BY eq.ID_Equipo) AS CostoTotalEquipo
FROM Operaciones.Mantenimiento m
INNER JOIN Operaciones.Equipo eq ON m.ID_Equipo = eq.ID_Equipo
INNER JOIN RRHH.Empleados e ON m.ID_Empleado = e.CarnetEmpleado;
GO