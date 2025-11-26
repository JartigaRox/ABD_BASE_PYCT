USE master;
GO
ALTER DATABASE GimnasioDB SET RECOVERY FULL;
USE [msdb];
GO

-- 1. CREAR OPERATOR PARA NOTIFICACIONES
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = 'Boinas rusas Team')
BEGIN
    EXEC msdb.dbo.sp_add_operator 
        @name = N'Boinas rusas Team',
        @enabled = 1,
        @email_address = N'00171124@uca.edu.sv';
END
GO

-- 2. JOB 1: BACKUP FULL SEMANAL (DOMINGOS 12:00 AM)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Backup_Full_Semanal_Gimnasio')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Backup_Full_Semanal_Gimnasio';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @description = N'Backup completo semanal de base de datos GimnasioDB - Domingos 12:00 AM',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_level_netsend = 2,
    @notify_level_page = 2,
    @notify_email_operator_name = N'Boinas rusas Team';
GO

-- Paso 1: Realizar backup full
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @step_name = N'Realizar_Backup_Full',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''C:\Backups\Gimnasio\FULL\gym_full_'' + @fecha + ''.bak'' 

BACKUP DATABASE [GimnasioDB] -- Base de datos corregida
TO DISK = @ruta
WITH 
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Full Semanal GimnasioDB'';',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Paso 2: Verificar backup
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @step_name = N'Verificar_Backup',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''C:\Backups\Gimnasio\FULL\gym_full_'' + @fecha + ''.bak''

RESTORE VERIFYONLY 
FROM DISK = @ruta
WITH CHECKSUM;',
    @on_success_action = 3,
    @on_fail_action = 2;
GO

-- Programación: Domingos a las 12:00 AM
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @name = N'Programacion_Full_Semanal',
    @freq_type = 8, -- Semanal
    @freq_interval = 1, -- Domingo
    @freq_subday_type = 1, -- Una vez al día
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 000000; -- 12:00:00 AM
GO

-- 3. JOB 2: BACKUP DIFFERENTIAL DIARIO (6:00 PM)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Backup_Differential_Diario_Gimnasio')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Backup_Differential_Diario_Gimnasio';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup_Differential_Diario_Gimnasio',
    @description = N'Backup diferencial diario de base de datos GimnasioDB - 6:00 PM',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = N'Boinas rusas Team';
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Differential_Diario_Gimnasio',
    @step_name = N'Realizar_Backup_Differential',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''C:\Backups\Gimnasio\DIFF\gym_diff_'' + @fecha + ''.bak''

BACKUP DATABASE [GimnasioDB] -- Base de datos corregida
TO DISK = @ruta
WITH 
    DIFFERENTIAL,
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Differential Diario GimnasioDB'';',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Programación: Diario a las 6:00 PM
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Backup_Differential_Diario_Gimnasio',
    @name = N'Programacion_Differential_Diario',
    @freq_type = 4, -- Diario
    @freq_interval = 1,
    @freq_subday_type = 1,
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 180000; -- 18:00:00 (6:00 PM)
GO

-- 4. JOB 3: BACKUP LOG TRANSACCIONAL (CADA 2 HORAS)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Backup_Log_Gimnasio_2Horas')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Backup_Log_Gimnasio_2Horas';
GO


EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup_Log_Gimnasio_2Horas',
    @description = N'Backup de log transaccional cada 2 horas - GimnasioDB',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = N'Boinas rusas Team';
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Log_Gimnasio_2Horas',
    @step_name = N'Realizar_Backup_Log',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''C:\Backups\Gimnasio\LOG\gym_log_'' + @fecha + ''.trn''

BACKUP LOG [GimnasioDB] -- Base de datos corregida
TO DISK = @ruta
WITH 
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Log Transaccional GimnasioDB'';',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Programación: Cada 2 horas 
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Backup_Log_Gimnasio_2Horas',
    @name = N'Programacion_Log_2Horas',
    @freq_type = 4, -- Diario
    @freq_interval = 1,
    @freq_subday_type = 8, -- Horas
    @freq_subday_interval = 2, -- Ejecutar cada 2 horas
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 0,
    @active_end_time = 235959;
GO

-- 5. JOB 4: MANTENIMIENTO Y LIMPIEZA (VIERNES 2:00 AM)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Limpieza_Backups_Antiguos')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Limpieza_Backups_Antiguos';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Limpieza_Backups_Antiguos',
    @description = N'Eliminar backups antiguos - Conservar solo 4 semanas',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa';
GO

USE [msdb];
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Limpieza_Backups_Antiguos',
    @step_name = N'Eliminar_Backups_Antiguos',
    @subsystem = N'TSQL',
    @command = N'
DECLARE @fecha_corte_full DATETIME = DATEADD(DAY, -30, GETDATE());
DECLARE @fecha_corte_diff DATETIME = DATEADD(DAY, -15, GETDATE());
DECLARE @fecha_corte_log DATETIME = DATEADD(DAY, -7, GETDATE());

-- EXEC xp_delete_file 0, N''C:\Backups\Gimnasio\FULL'', N''bak'', @fecha_corte_full; --eliminar backups full (más de 30 días)
 
EXEC xp_delete_file 0, N''C:\Backups\Gimnasio\DIFF'', N''bak'', @fecha_corte_diff; --eliminar backups diff (más de 15 días)

EXEC xp_delete_file 0, N''C:\Backups\Gimnasio\LOG'', N''trn'', @fecha_corte_log; --eliminar backups log (más de 7 días)

PRINT ''Archivos antiguos procesados.'';
',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Programación: Viernes 2:00 AM
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Limpieza_Backups_Antiguos',
    @name = N'Eliminar_Backups_Antiguos',
    @freq_type = 8, -- Semanal
    @freq_interval = 32, -- Viernes
    @freq_subday_type = 1,
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 020000; -- 2:00 AM
GO

-- HABILITAR LOS JOBS
EXEC msdb.dbo.sp_update_job @job_name = N'Backup_Full_Semanal_Gimnasio', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Backup_Differential_Diario_Gimnasio', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Backup_Log_Gimnasio_2Horas', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Limpieza_Backups_Antiguos', @enabled = 1;
GO

PRINT 'Plan de backups configurado exitosamente con Log cada 2 horas!';

--Para que ya no se envien correos 
USE [msdb];
GO

-- 1. Deshabilitar notificaciones para el Backup Full Semanal
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Full_Semanal_Gimnasio', 
    @notify_level_email = 0; -- 0 = Nunca notificar

-- 2. Deshabilitar notificaciones para el Backup Diferencial Diario
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Differential_Diario_Gimnasio', 
    @notify_level_email = 0;

-- 3. Deshabilitar notificaciones para el Backup de Log (Cada 2 Horas)
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Log_Gimnasio_2Horas',
    @notify_level_email = 0;

-- 4. Deshabilitar notificaciones para la Limpieza de Backups
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Limpieza_Backups_Antiguos', 
    @notify_level_email = 0;

GO

PRINT 'Notificaciones por correo electrónico deshabilitadas para todos los Jobs de respaldo.';

--para desactivar los jobs
USE [msdb];
GO

-- 1. Deshabilitar el Backup Full Semanal
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Full_Semanal_Gimnasio', 
    @enabled = 0; -- 0 = Deshabilitado

-- 2. Deshabilitar el Backup Diferencial Diario
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Differential_Diario_Gimnasio', 
    @enabled = 0;

-- 3. Deshabilitar el Backup de Log (Cada 2 Horas)
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Backup_Log_Gimnasio_2Horas',
    @enabled = 0;

-- 4. Deshabilitar la Limpieza de Backups
EXEC msdb.dbo.sp_update_job 
    @job_name = N'Limpieza_Backups_Antiguos', 
    @enabled = 0;

GO

PRINT 'Todos los Jobs de respaldo han sido deshabilitados.';


--para que los jobs esten asociados a la instancia actual
USE [msdb];
GO

DECLARE @ServerName NVARCHAR(128);
SET @ServerName = CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)); 


-- 1. Asociar el Job Full
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'Backup_Full_Semanal_Gimnasio', 
    @server_name = @ServerName;

-- 2. Asociar el Job Diferencial
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'Backup_Differential_Diario_Gimnasio', 
    @server_name = @ServerName;

-- 3. Asociar el Job de Log
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'Backup_Log_Gimnasio_2Horas', 
    @server_name = @ServerName;

-- 4. Asociar el Job de Limpieza
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'Limpieza_Backups_Antiguos', 
    @server_name = @ServerName;

PRINT 'Jobs asociados correctamente a la instancia ' + @ServerName;
GO