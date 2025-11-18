-- =============================================
-- CONFIGURACIÓN DE PLAN DE BACKUP - GIMNASIO
-- =============================================

USE [msdb];
GO

-- 1. CREAR OPERATOR PARA NOTIFICACIONES
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = 'DBA_Team')
BEGIN
    EXEC msdb.dbo.sp_add_operator 
        @name = N'DBA_Team',
        @enabled = 1,
        @email_address = N'dba@gimnasio.com'; --direccion de correo del esquipo DBA
END
GO

-- 2. JOB 1: BACKUP FULL SEMANAL (DOMINGOS 12:00 AM)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Backup_Full_Semanal_Gimnasio')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Backup_Full_Semanal_Gimnasio';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @description = N'Backup completo semanal de base de datos Gimnasio - Domingos 12:00 AM',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_level_netsend = 2,
    @notify_level_page = 2,
    @notify_email_operator_name = N'DBA_Team';
GO

-- Paso 1: Realizar backup full
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @step_name = N'Realizar_Backup_Full',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''E:\Backups\Gimnasio\FULL\gym_full_'' + @fecha + ''.bak'' 

BACKUP DATABASE [gym_management] 
TO DISK = @ruta
WITH 
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Full Semanal Gimnasio'';',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Paso 2: Verificar backup
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Full_Semanal_Gimnasio',
    @step_name = N'Verificar_Backup',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''E:\Backups\Gimnasio\FULL\gym_full_'' + @fecha + ''.bak''

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
    @description = N'Backup diferencial diario de base de datos Gimnasio - 6:00 PM',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = N'DBA_Team';
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Differential_Diario_Gimnasio',
    @step_name = N'Realizar_Backup_Differential',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''E:\Backups\Gimnasio\DIFF\gym_diff_'' + @fecha + ''.bak''

BACKUP DATABASE [gym_management] 
TO DISK = @ruta
WITH 
    DIFFERENTIAL,
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Differential Diario Gimnasio'';',
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

-- 4. JOB 3: BACKUP LOG TRANSACCIONAL (CADA 6 HORAS)
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Backup_Log_Gimnasio_6Horas')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Backup_Log_Gimnasio_6Horas';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup_Log_Gimnasio_6Horas',
    @description = N'Backup de log transaccional cada 6 horas - Gimnasio',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = N'DBA_Team';
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup_Log_Gimnasio_6Horas',
    @step_name = N'Realizar_Backup_Log',
    @subsystem = N'TSQL',
    @command = N'DECLARE @fecha VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), '':'', '''')
DECLARE @ruta VARCHAR(200) = ''E:\Backups\Gimnasio\LOG\gym_log_'' + @fecha + ''.trn''

BACKUP LOG [gym_management] 
TO DISK = @ruta
WITH 
    COMPRESSION,
    CHECKSUM,
    STATS = 10,
    DESCRIPTION = ''Backup Log Transaccional Gimnasio'';',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Programación: Cada 6 horas (12AM, 6AM, 12PM, 6PM)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Backup_Log_Gimnasio_6Horas',
    @name = N'Programacion_Log_6Horas',
    @freq_type = 4, -- Diario
    @freq_interval = 1,
    @freq_subday_type = 8, -- Horas
    @freq_subday_interval = 6,
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

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Limpieza_Backups_Antiguos',
    @step_name = N'Eliminar_Backups_Antiguos',
    @subsystem = N'TSQL',
    @command = N'-- Eliminar backups full con más de 30 días
EXEC xp_delete_file 0, N''E:\Backups\Gimnasio\FULL'', N''bak'', DATEADD(DAY, -30, GETDATE());

-- Eliminar backups differential con más de 15 días  
EXEC xp_delete_file 0, N''E:\Backups\Gimnasio\DIFF'', N''bak'', DATEADD(DAY, -15, GETDATE());

-- Eliminar logs con más de 7 días
EXEC xp_delete_file 0, N''E:\Backups\Gimnasio\LOG'', N''trn'', DATEADD(DAY, -7, GETDATE());';
GO

-- Programación: Viernes 2:00 AM
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Limpieza_Backups_Antiguos',
    @name = N'Programacion_Limpieza',
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
EXEC msdb.dbo.sp_update_job @job_name = N'Backup_Log_Gimnasio_6Horas', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Limpieza_Backups_Antiguos', @enabled = 1;
GO

PRINT 'Plan de backups configurado exitosamente!';