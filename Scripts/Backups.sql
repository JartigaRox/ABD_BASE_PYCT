USE GimnasioDB;
GO

-- Crear procedimiento para respaldo completo
CREATE PROCEDURE dbo.sp_BackupCompleto
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GimnasioDB\'
AS
BEGIN
    DECLARE @NombreArchivo NVARCHAR(500);
    DECLARE @Fecha NVARCHAR(20) = CONVERT(NVARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 108), ':', '');
    
    SET @NombreArchivo = @RutaBackup + 'GimnasioDB_Full_' + @Fecha + '.bak';
    
    BACKUP DATABASE GimnasioDB
    TO DISK = @NombreArchivo
    WITH FORMAT, COMPRESSION, STATS = 10;
    
    SELECT 'Respaldo completo exitoso: ' + @NombreArchivo AS Resultado;
END;
GO

-- Crear procedimiento para respaldo diferencial
CREATE PROCEDURE dbo.sp_BackupDiferencial
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GimnasioDB\'
AS
BEGIN
    DECLARE @NombreArchivo NVARCHAR(500);
    DECLARE @Fecha NVARCHAR(20) = CONVERT(NVARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 108), ':', '');
    
    SET @NombreArchivo = @RutaBackup + 'GimnasioDB_Diff_' + @Fecha + '.bak';
    
    BACKUP DATABASE GimnasioDB
    TO DISK = @NombreArchivo
    WITH DIFFERENTIAL, COMPRESSION, STATS = 10;
    
    SELECT 'Respaldo diferencial exitoso: ' + @NombreArchivo AS Resultado;
END;
GO

-- Crear procedimiento para respaldo de log
CREATE PROCEDURE dbo.sp_BackupLog
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GimnasioDB\'
AS
BEGIN
    DECLARE @NombreArchivo NVARCHAR(500);
    DECLARE @Fecha NVARCHAR(20) = CONVERT(NVARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 108), ':', '');
    
    SET @NombreArchivo = @RutaBackup + 'GimnasioDB_Log_' + @Fecha + '.trn';
    
    BACKUP LOG GimnasioDB
    TO DISK = @NombreArchivo
    WITH COMPRESSION, STATS = 10;
    
    SELECT 'Respaldo de log exitoso: ' + @NombreArchivo AS Resultado;
END;
GO