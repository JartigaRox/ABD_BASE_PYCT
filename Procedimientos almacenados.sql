USE GimnasioDB;
GO
-- SP: Registrar nuevo socio
CREATE PROCEDURE Negocio.sp_RegistrarSocio
    @Nombre NVARCHAR(100),
    @Telefono NVARCHAR(20),
    @Email NVARCHAR(100),
    @ID_plan INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO Negocio.Socio (Nombre, Telefono, Email, ID_plan)
            VALUES (@Nombre, @Telefono, @Email, @ID_plan);
            
            SELECT SCOPE_IDENTITY() AS NuevoID_Socio;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP: Registrar pago
CREATE PROCEDURE Finanzas.sp_RegistrarPago
    @ID_Socio INT,
    @Monto DECIMAL(10,2),
    @Metodo_pago NVARCHAR(50),
    @Periodo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO Finanzas.Pagos (ID_Socio, Monto, Metodo_pago, Periodo)
            VALUES (@ID_Socio, @Monto, @Metodo_pago, @Periodo);
            
            SELECT SCOPE_IDENTITY() AS NuevoID_Pago;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- SP: Inscribir socio en clase
CREATE PROCEDURE Negocio.sp_InscribirSocioClase
    @ID_Socio INT,
    @ID_Clase INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CuposDisponibles INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
            SELECT @CuposDisponibles = c.Capacidad - COUNT(sc.ID_Socio)
            FROM Negocio.Clases c
            LEFT JOIN Negocio.SocioxClase sc ON c.ID_Clase = sc.ID_Clase AND sc.Estado = 'Activo'
            WHERE c.ID_Clase = @ID_Clase
            GROUP BY c.Capacidad;
            
            IF @CuposDisponibles > 0
            BEGIN
                INSERT INTO Negocio.SocioxClase (ID_Socio, ID_Clase)
                VALUES (@ID_Socio, @ID_Clase);
                
                SELECT 'Inscripción exitosa' AS Resultado;
            END
            ELSE
            BEGIN
                SELECT 'Clase llena' AS Resultado;
            END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
