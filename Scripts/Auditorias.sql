USE [master];
GO

-- ====================================================================================
-- 1. CREAR EL OBJETO AUDIT DE SERVIDOR
--    (Define dónde se guardarán los archivos de auditoría)
-- ====================================================================================

-- Detener la auditoría si existe para poder reconfigurarla
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'SQL_Audit_GimnasioDB')
    ALTER SERVER AUDIT [SQL_Audit_GimnasioDB] WITH (STATE = OFF);
GO

-- Eliminarla si existe
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'SQL_Audit_GimnasioDB')
    DROP SERVER AUDIT [SQL_Audit_GimnasioDB];
GO

CREATE SERVER AUDIT [SQL_Audit_GimnasioDB]
TO FILE 
(
    -- *** RUTA IMPORTANTE: DEBES CREAR ESTA CARPETA Y ASEGURARTE DE QUE LA CUENTA DE SERVICIO DE SQL SERVER TENGA PERMISOS DE ESCRITURA ***
    FILEPATH = 'C:\Audits\GimnasioDB\' 
    ,MAXSIZE = 10 MB -- Tamaño máximo de cada archivo de log
    ,MAX_ROLLOVER_FILES = 5 -- Número máximo de archivos a mantener
    ,RESERVE_DISK_SPACE = OFF
)
WITH
(
    QUEUE_DELAY = 1000,         -- Retardo en ms para escribir en el log
    ON_FAILURE = CONTINUE       -- Continuar la operación si la auditoría falla
);
GO

-- Habilitar el Audit de Servidor
ALTER SERVER AUDIT [SQL_Audit_GimnasioDB] WITH (STATE = ON);
PRINT '1. Objeto Audit de Servidor [SQL_Audit_GimnasioDB] creado y habilitado.';
GO

-- ====================================================================================
-- 2. CREAR LA ESPECIFICACIÓN DE AUDITORÍA DE BASE DE DATOS
--    (Define qué acciones se auditarán para cada usuario)
-- ====================================================================================

USE [GimnasioDB];
GO

-- Eliminar especificación si existe
IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'DB_Audit_GimnasioDB_Activity')
    DROP DATABASE AUDIT SPECIFICATION [DB_Audit_GimnasioDB_Activity];
GO

CREATE DATABASE AUDIT SPECIFICATION [DB_Audit_GimnasioDB_Activity]
FOR SERVER AUDIT [SQL_Audit_GimnasioDB]

    -- 1. AUDITAR SELECTS
    -- Se audita la acción SELECT a nivel de toda la base de datos para cubrir todas las tablas
    ADD (SELECT ON DATABASE::[GimnasioDB] BY [owner]),
    ADD (SELECT ON DATABASE::[GimnasioDB] BY [gym_operador]),
    ADD (SELECT ON DATABASE::[GimnasioDB] BY [finanzas]),
    ADD (SELECT ON DATABASE::[GimnasioDB] BY [backup_operator]),
    ADD (SELECT ON DATABASE::[GimnasioDB] BY [profesor]),

    -- 2. AUDITAR INSERTS
    ADD (INSERT ON DATABASE::[GimnasioDB] BY [owner]),
    ADD (INSERT ON DATABASE::[GimnasioDB] BY [gym_operador]),
    ADD (INSERT ON DATABASE::[GimnasioDB] BY [finanzas]),
    ADD (INSERT ON DATABASE::[GimnasioDB] BY [backup_operator]),
    ADD (INSERT ON DATABASE::[GimnasioDB] BY [profesor])
    
    -- NOTA: Si quisiera auditar solo en una tabla específica (ej. Negocio.Socio), el comando sería: 
    -- ADD (SELECT ON Negocio.Socio BY [gym_operador])
WITH (STATE = OFF);
GO

-- Habilitar la Especificación de Auditoría de Base de Datos
ALTER DATABASE AUDIT SPECIFICATION [DB_Audit_GimnasioDB_Activity] WITH (STATE = ON);
PRINT '2. Especificación de Auditoría de Base de Datos [DB_Audit_GimnasioDB_Activity] creada y habilitada.';
GO

-- ====================================================================================
-- 3. CONSULTAR LOS RESULTADOS DE LA AUDITORÍA
-- ====================================================================================

-- Después de ejecutar la auditoría y realizar algunas operaciones (SELECT/INSERT) con los usuarios,
-- usa la siguiente consulta para leer el archivo de logs:


SELECT 
    event_time, 
    action_id, 
    succeeded,
    server_principal_name,
    database_principal_name,
    database_name,
    object_name,
    statement
FROM sys.fn_get_audit_file (
    'C:\Audits\GimnasioDB\*', -- *** USAR LA MISMA RUTA DE FILEPATH DEL PASO 1 ***
    DEFAULT, 
    DEFAULT
)
WHERE action_id IN ('SL', 'IN') -- SL = SELECT, IN = INSERT
ORDER BY event_time DESC;
