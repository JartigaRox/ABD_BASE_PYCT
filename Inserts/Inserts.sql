USE GimnasioDB
GO
-- INSERT DE PLANES
INSERT INTO Negocio.Membresia (
    Nombre_plan, 
    Precio_mensual, 
    Descripcion, 
    FechaCreacion, 
    FechaModificacion, 
    UsuarioModificacion, 
    Activo
)
VALUES 
    (
        'Basico', 
        12.99, 
        'Acceso a area de peso, cardio y clases grupales', 
        '2012-07-28T22:20:39.629', 
        '2023-12-29T03:04:48.163', 
        'owner', 
        1
    ),
    (
        'Intermedio', 
        19.99, 
        'Acceso a area de peso, cardio, clases grupales y asesoria personalizada. Sin cargo de cancelacion.', 
        '2024-10-12T04:48:08.554', 
        '2025-06-01T14:19:53.204', 
        'owner', 
        1
    ),
    (
        'Gold', 
        24.99, 
        'Acceso a area de peso, cardio, clases grupales y asesoria personalizada. Sin cargo de cancelacion. Invita a un amigo hasta 5 veces al mes.', 
        '2023-12-24T05:13:25.467', 
        '2022-10-10T09:03:07.172', 
        'owner', 
        1
    );
GO
SELECT * FROM Negocio.Membresia

-- INSERT SOCIO
CREATE TABLE #Socio (
    ID_plan INT,
    Nombre NVARCHAR(100),
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    FechaRegistro DATETIME2,
    FechaModificacion DATETIME2,
    UsuarioModificacion NVARCHAR(100),
    Activo BIT
);

BULK INSERT #Socio
FROM 'C:\Clases\BD\ABD_BASE_PYCT\bulk\socio.csv'
WITH (
    FIELDTERMINATOR = ',',        
    ROWTERMINATOR = '\n',       
	FIRSTROW = 2,                 
	CODEPAGE = '65001',           
    TABLOCK
);

INSERT INTO Negocio.Socio (
    ID_plan,
    Nombre,
    Telefono,
    Email,
    FechaRegistro,
    FechaModificacion,
    UsuarioModificacion,
    Activo
)
SELECT 
    ID_plan,
    Nombre,
    Telefono,
    Email,
    FechaRegistro,
    FechaModificacion,
    UsuarioModificacion,
    Activo
FROM #Socio;

DROP TABLE #Socio

SELECT * FROM Negocio.Socio
GO

-- INSERT CLASES

EXEC sp_rename 'RRHH.Empleados.CarnetEmpleado', 'ID_Empleado', 'COLUMN'

CREATE TABLE #Empleados (
	Nombre NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    Puesto NVARCHAR(50),
    FechaContratacion DATETIME2 DEFAULT GETDATE(),
    Salario DECIMAL(10,2),
    FechaModificacion DATETIME2 DEFAULT GETDATE(),
    UsuarioModificacion NVARCHAR(100) DEFAULT SYSTEM_USER,
    Activo BIT DEFAULT 1)
GO

BULK INSERT #Empleados
FROM 'C:\Clases\BD\ABD_BASE_PYCT\bulk\Empleados.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   
    FIRSTROW = 2,
    CODEPAGE = '65001'        
);

SELECT * FROM #Empleados

INSERT INTO RRHH.Empleados (
	Nombre,
	Telefono,
	Email,
	Puesto,
	FechaContratacion,
	Salario,
	FechaModificacion,
	UsuarioModificacion,
	Activo) 
SELECT 
	Nombre,
	Telefono,
	Email,
	Puesto,
	FechaContratacion,
	Salario,
	FechaModificacion,
	UsuarioModificacion,
	Activo
FROM #Empleados

SELECT * FROM RRHH.Empleados
DROP TABLE #Empleados

-- Insertar clases grupales de gimnasio
INSERT INTO Negocio.Clases (Nombre_clase, Horario, ID_empleado, Capacidad, Activo)
VALUES
    ('Yoga Matutino', 'Lun-Mie-Vie 6:00-7:00 AM', 3, 25, 1),
    ('Spinning', 'Lun-Mie-Vie 7:00-8:00 AM', 30, 30, 1),
    ('Zumba', 'Mar-Jue 9:00-10:00 AM', 27, 35, 1),
    ('CrossFit', 'Mar-Jue 6:30-7:30 AM', 23, 20, 1),
    ('Body Pump', 'Lun-Mie-Vie 6:00-7:00 PM', 16, 28, 1),
    ('Pilates', 'Mar-Jue 10:00-11:00 AM', 3, 20, 1),
    ('HIIT (Alta Intensidad)', 'Lun-Mie-Vie 8:00-9:00 PM', 10, 25, 1),
    ('Boxeo Fitness', 'Lun-Mie-Vie 7:00-8:00 PM', 7, 20, 1),
    ('Yoga Vespertino', 'Sábado 9:00-10:30 AM', 20, 25, 1),
    ('Funcional Training', 'Domingo 10:00-11:00 AM', 9, 22, 1);
GO
SELECT * FROM Negocio.Clases

-- INSERT SOCIOXCLASE
BULK INSERT Negocio.SocioxClase
FROM 'C:\Clases\BD\ABD_BASE_PYCT\bulk\ClasexSocio.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'       
);

SELECT * FROM Negocio.SocioxClase

-- Insert mantenimiento
-- Insertar datos en la tabla Operaciones.Equipo (Gimnasio)
-- 20 registros de equipos variados

INSERT INTO Operaciones.Equipo (Nombre, Fecha_compra, Estado, FechaCreacion, FechaModificacion, UsuarioModificacion) VALUES
('Caminadora Precor TRM 835', '2023-01-15 09:00:00', 'Operativo', '2023-01-15 09:00:00', '2023-01-15 09:00:00', 'admin_gym'),
('Caminadora Life Fitness T5', '2023-01-15 09:00:00', 'Operativo', '2023-01-15 09:00:00', '2023-01-15 09:00:00', 'admin_gym'),
('Bicicleta Estática Schwinn IC4', '2023-02-10 10:30:00', 'Operativo', '2023-02-10 10:30:00', '2023-02-10 10:30:00', 'admin_gym'),
('Elíptica NordicTrack Commercial 14.9', '2023-02-20 11:15:00', 'En Mantenimiento', '2023-02-20 11:15:00', '2024-11-25 14:20:00', 'tecnico_mantenimiento'),
('Escaladora StairMaster 8G', '2023-03-05 08:45:00', 'Operativo', '2023-03-05 08:45:00', '2023-03-05 08:45:00', 'admin_gym'),
('Remo Concept2 Model D', '2023-03-15 13:00:00', 'Operativo', '2023-03-15 13:00:00', '2023-03-15 13:00:00', 'admin_gym'),
('Bicicleta Spinning Keiser M3i', '2023-04-01 09:30:00', 'Operativo', '2023-04-01 09:30:00', '2023-04-01 09:30:00', 'admin_gym'),
('Rack Squat Hammer Strength', '2023-01-20 10:00:00', 'Operativo', '2023-01-20 10:00:00', '2023-01-20 10:00:00', 'admin_gym'),
('Banco Press Banca Olímpico', '2023-01-20 10:00:00', 'Operativo', '2023-01-20 10:00:00', '2023-01-20 10:00:00', 'admin_gym'),
('Máquina Smith Precor', '2023-02-15 11:30:00', 'Operativo', '2023-02-15 11:30:00', '2023-02-15 11:30:00', 'admin_gym'),
('Prensa de Piernas 45° Life Fitness', '2023-02-28 14:00:00', 'Operativo', '2023-02-28 14:00:00', '2023-02-28 14:00:00', 'admin_gym'),
('Polea Alta/Baja Dual Cybex', '2023-03-10 09:15:00', 'Operativo', '2023-03-10 09:15:00', '2023-03-10 09:15:00', 'admin_gym'),
('Máquina Pectoral Fly Technogym', '2023-03-25 10:45:00', 'Operativo', '2023-03-25 10:45:00', '2023-03-25 10:45:00', 'admin_gym'),
('Multiestación Body-Solid EXM3000LPS', '2023-04-10 12:00:00', 'Operativo', '2023-04-10 12:00:00', '2023-04-10 12:00:00', 'admin_gym'),
('Set Mancuernas 5-50 lbs (Par)', '2023-05-01 08:00:00', 'Operativo', '2023-05-01 08:00:00', '2023-05-01 08:00:00', 'admin_gym'),
('Balón Medicinal 10 kg Rogue', '2023-05-15 10:30:00', 'Operativo', '2023-05-15 10:30:00', '2023-05-15 10:30:00', 'admin_gym'),
('TRX Suspension Trainer Pro', '2023-06-01 09:00:00', 'Operativo', '2023-06-01 09:00:00', '2023-06-01 09:00:00', 'admin_gym'),
('Kettlebell Set 8-32 kg', '2023-06-20 11:45:00', 'Operativo', '2023-06-20 11:45:00', '2023-06-20 11:45:00', 'admin_gym'),
('Colchonetas Yoga/Pilates (10 unidades)', '2023-07-05 14:30:00', 'Operativo', '2023-07-05 14:30:00', '2023-07-05 14:30:00', 'admin_gym'),
('Barras Olímpicas 20 kg (3 unidades)', '2023-08-15 08:15:00', 'Fuera de Servicio', '2023-08-15 08:15:00', '2024-11-22 09:00:00', 'tecnico_mantenimiento');

-- INSERT MANTENIMIENTO
INSERT INTO Operaciones.Mantenimiento (ID_Equipo, ID_Empleado, Fecha_mantenimiento, Descripcion, Costo, FechaCreacion, UsuarioModificacion)
VALUES 
(1, 5, '2024-03-15 08:30:00', 'Mantenimiento preventivo: lubricación de banda, ajuste de velocidad y limpieza general', 85.00, '2024-03-15 08:30:00', 'tecnico_mantenimiento'),
(2, 16, '2024-03-20 10:15:00', 'Mantenimiento preventivo: revisión de sistema eléctrico y calibración de display', 75.00, '2024-03-20 10:15:00', 'tecnico_mantenimiento'),
(3, 5, '2024-04-10 09:00:00', 'Limpieza profunda y lubricación de pedales, ajuste de resistencia', 60.00, '2024-04-10 09:00:00', 'tecnico_mantenimiento'),
(5, 28, '2024-04-25 14:30:00', 'Mantenimiento preventivo: lubricación de cadena, revisión de escalones', 95.00, '2024-04-25 14:30:00', 'tecnico_mantenimiento'),
(6, 16, '2024-05-05 11:00:00', 'Revisión general, lubricación de rieles y ajuste de tensión', 70.00, '2024-05-05 11:00:00', 'tecnico_mantenimiento'),
(4, 5, '2024-06-12 08:45:00', 'Reparación de sensor de frecuencia cardíaca y reemplazo de cable de alimentación', 125.50, '2024-06-12 08:45:00', 'tecnico_mantenimiento'),
(7, 28, '2024-06-18 13:20:00', 'Reemplazo de piñón desgastado y ajuste de sistema de frenado', 180.00, '2024-06-18 13:20:00', 'tecnico_mantenimiento'),
(8, 16, '2024-07-03 09:30:00', 'Soldadura de estructura y pintura anticorrosiva en base del rack', 220.00, '2024-07-03 09:30:00', 'tecnico_mantenimiento'),
(10, 5, '2024-07-15 10:45:00', 'Reparación de sistema hidráulico y reemplazo de pistón defectuoso', 310.75, '2024-07-15 10:45:00', 'tecnico_mantenimiento'),
(20, 28, '2024-08-01 08:00:00', 'Reemplazo de barra con fisura, inspección de seguridad completa', 450.00, '2024-08-01 08:00:00', 'tecnico_mantenimiento')
SELECT * FROM Operaciones.Mantenimiento


SELECT * FROM Finanzas.Pagos
SET NOCOUNT ON;
GO
DBCC CHECKIDENT ('Finanzas.Pagos', RESEED, 999);
GO

DECLARE @counter INT = 1;
DECLARE @ID_Socio INT;
DECLARE @Metodo_pago NVARCHAR(50);
DECLARE @Fecha_pago DATETIME2;
DECLARE @Monto DECIMAL(10,2);
DECLARE @Periodo NVARCHAR(50);
DECLARE @Estado NVARCHAR(20);
DECLARE @TotalSocios INT;

-- Obtener el total de socios
SELECT @TotalSocios = COUNT(*) FROM Negocio.Socio;

WHILE @counter <= 1000
BEGIN
    -- Seleccionar un ID_Socio aleatorio de los existentes
    SELECT TOP 1 @ID_Socio = ID_socio 
    FROM Negocio.Socio 
    ORDER BY NEWID();
    
    -- Método de pago aleatorio
    SET @Metodo_pago = CASE (ABS(CHECKSUM(NEWID())) % 5) + 1
        WHEN 1 THEN 'Efectivo'
        WHEN 2 THEN 'Tarjeta de Crédito'
        WHEN 3 THEN 'Tarjeta de Débito'
        WHEN 4 THEN 'Transferencia Bancaria'
        ELSE 'Cheque'
    END;
    
    -- Fecha de pago aleatoria entre 2024-01-01 y 2025-10-31
    SET @Fecha_pago = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 670, '2024-01-01');
    
    -- Monto aleatorio: 12.99, 19.99 o 24.99
    SET @Monto = CASE (ABS(CHECKSUM(NEWID())) % 3) + 1
        WHEN 1 THEN 12.99
        WHEN 2 THEN 19.99
        ELSE 24.99
    END;
    
    -- Periodo basado en la fecha de pago (MES y AÑO coinciden con @Fecha_pago)
    SET @Periodo = CASE MONTH(@Fecha_pago)
        WHEN 1 THEN 'Enero ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 2 THEN 'Febrero ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 3 THEN 'Marzo ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 4 THEN 'Abril ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 5 THEN 'Mayo ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 6 THEN 'Junio ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 7 THEN 'Julio ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 8 THEN 'Agosto ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 9 THEN 'Septiembre ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 10 THEN 'Octubre ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        WHEN 11 THEN 'Noviembre ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
        ELSE 'Diciembre ' + CAST(YEAR(@Fecha_pago) AS NVARCHAR(4))
    END;
    
    -- Estado aleatorio
    SET @Estado = CASE (ABS(CHECKSUM(NEWID())) % 20) + 1
        WHEN 1 THEN 'Pendiente'
        WHEN 2 THEN 'Rechazado'
        ELSE 'Completado'
    END;
    
    -- Insertar registro con FechaCreacion igual a Fecha_pago
    INSERT INTO Finanzas.Pagos (ID_Socio, Metodo_pago, Fecha_pago, Monto, Periodo, Estado, FechaCreacion, UsuarioModificacion)
    VALUES (@ID_Socio, @Metodo_pago, @Fecha_pago, @Monto, @Periodo, @Estado, @Fecha_pago, 'finanzas');
    
    SET @counter = @counter + 1;
END;

SET NOCOUNT OFF;
GO

EXEC sp_BackupCompleto 'C:\Backups\GimnasioDB'