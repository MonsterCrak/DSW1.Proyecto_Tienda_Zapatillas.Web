USE BD_TiendaZapatillas
GO


IF OBJECT_ID('sp_RegistrarUsuarioCliente', 'P') IS NOT NULL
    DROP PROCEDURE sp_RegistrarUsuarioCliente;
GO

CREATE PROCEDURE sp_RegistrarUsuarioCliente 
    @Nombre VARCHAR(50),
    @ApePaterno VARCHAR(50),
    @ApeMaterno VARCHAR(50),
    @Email VARCHAR(100),
    @Clave VARCHAR(50),
    @IdTipoUsuario INT = 1,
	@IdUsuarioCliente INT OUTPUT,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM UsuarioCliente WHERE Email = @Email)
    BEGIN
        SET @Mensaje = 'El correo electrónico ya existe. Por favor, ingrese otro correo electrónico.';
        RETURN;
    END
    
    DECLARE @Id INT;
    SELECT @Id = MAX(IdUsuarioCliente) + 1 FROM UsuarioCliente;
    IF @Id IS NULL SET @Id = 1;
    
    DECLARE @ClaveHash VARBINARY(32);
    SET @ClaveHash = HASHBYTES('SHA2_256', @Clave);
    
    INSERT INTO UsuarioCliente (IdUsuarioCliente, Nombre, ApePaterno, ApeMaterno, Email, Clave, IdTipoUsuario)
    VALUES (@Id, @Nombre, @ApePaterno, @ApeMaterno, @Email, @ClaveHash, @IdTipoUsuario);


	INSERT INTO Cliente (IdCliente, Sexo, Telefono, Direccion, IdUsuarioCliente, IdDistrito)
	VALUES (@Id, null, null, null, @Id, null);


    
    SET @Mensaje = 'El usuario ha sido registrado exitosamente.';
END
GO



--------------------------------

CREATE OR ALTER PROCEDURE sp_IniciarSesionUsuarioCliente 
    @Email VARCHAR(100),
    @Clave VARCHAR(50),
    @Mensaje VARCHAR(100) OUTPUT,
    @IdUsuario INT OUTPUT
AS
BEGIN
    DECLARE @ClaveHash VARBINARY(32);
    SET @ClaveHash = HASHBYTES('SHA2_256', @Clave);
    
    SELECT @IdUsuario = IdUsuarioCliente FROM UsuarioCliente WHERE Email = @Email AND Clave = @ClaveHash;

    IF @IdUsuario IS NULL
    BEGIN
        SET @Mensaje = 'El correo electrónico o la contraseña son incorrectos.';
        RETURN;
    END
    
    SET @Mensaje = 'El usuario ha iniciado sesión exitosamente.';
END
GO

-----------------------------

IF OBJECT_ID('sp_RegistrarUsuarioColaborador', 'P') IS NOT NULL
    DROP PROCEDURE sp_RegistrarUsuarioColaborador;
GO

CREATE PROCEDURE sp_RegistrarUsuarioColaborador
    @Email VARCHAR(100),
    @Clave VARCHAR(50),
    @DNI CHAR(8),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdTipoUsuario INT

	-- Verificar si el DNI existe en la tabla Colaborador
	IF NOT EXISTS(SELECT * FROM Colaborador WHERE DNI = @DNI)
	BEGIN
		SET @Mensaje = 'El DNI especificado no se encuentra registrado en el sistema'
		RETURN
	END

	-- Validar si el email ya está registrado
    IF EXISTS(SELECT * FROM UsuarioColaborador WHERE Email = @Email)
    BEGIN
        SET @Mensaje = 'El email especificado ya se encuentra registrado en el sistema'
        RETURN
    END
	
	-- Obtener el IdTipoUsuario del Colaborador a partir del DNI
	SELECT @IdTipoUsuario = Cargo.IdTipoUsuario
	FROM BD_tiendaZapatillas.dbo.Colaborador
	INNER JOIN BD_tiendaZapatillas.dbo.Cargo ON Colaborador.IdCargo = Cargo.IdCargo
	WHERE Colaborador.DNI = @DNI

	-- Validar DNI registrado
	IF EXISTS(SELECT * FROM UsuarioColaborador WHERE DNI = @DNI)
	BEGIN
		SET @Mensaje = 'El usuario con el DNI especificado ya tiene una cuenta registrada en el sistema'
		RETURN
	END

	-- Convertir la clave a sha256
	DECLARE @ClaveSha256 VARBINARY(32) = HASHBYTES('SHA2_256', @Clave);

	-- Insertar el nuevo UsuarioColaborador
	INSERT INTO UsuarioColaborador (Email, Clave, ValidacionCargo, DNI)
	VALUES (@Email, @ClaveSha256, @IdTipoUsuario, @DNI)

	-- Obtener el IdUsuarioColaborador generado por la inserción
	DECLARE @IdUsuarioColaborador INT
	SELECT @IdUsuarioColaborador = SCOPE_IDENTITY()

	SET @Mensaje = 'El UsuarioColaborador se ha registrado exitosamente. El IdUsuarioColaborador generado es: ' + CAST(@IdUsuarioColaborador AS VARCHAR)
END
GO


---------------------------------


CREATE OR ALTER PROCEDURE sp_IniciarSesionUsuarioColaborador
    @Email VARCHAR(100),
    @Clave VARCHAR(50),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el email existe en la tabla UsuarioColaborador
    IF NOT EXISTS(SELECT * FROM UsuarioColaborador WHERE Email = @Email)
    BEGIN
        SET @Mensaje = 'El email especificado no se encuentra registrado en el sistema'
        RETURN
    END

    -- Obtener el IdUsuarioColaborador y Clave del email especificado
    DECLARE @IdUsuarioColaborador INT
    DECLARE @ClaveSha256 VARBINARY(32)
    SELECT @IdUsuarioColaborador = IdUsuarioColaborador, @ClaveSha256 = Clave
    FROM UsuarioColaborador
    WHERE Email = @Email

    -- Convertir la clave especificada a sha256
    DECLARE @ClaveEspecSha256 VARBINARY(32) = HASHBYTES('SHA2_256', @Clave);

    -- Verificar si la clave es correcta
    IF @ClaveSha256 <> @ClaveEspecSha256
    BEGIN
        SET @Mensaje = 'La clave especificada es incorrecta'
        RETURN
    END

    SET @Mensaje = 'Inicio de sesión exitoso para el Usuario Colaborador con IdUsuarioColaborador: ' + CAST(@IdUsuarioColaborador AS VARCHAR)
END
GO

----------------- [Select] ------------------


CREATE OR ALTER PROCEDURE GetDistritosByProvincia
    @IdProvincia INT
AS
BEGIN
    SELECT * FROM Distrito WHERE IdProvincia = @IdProvincia
END
GO


----------------- [MANTENIMIENTOS] ------------------

CREATE OR ALTER PROCEDURE sp_mergeColaborador
    @DNI CHAR(8),
    @Nombre VARCHAR(50),
    @ApePaterno VARCHAR(50),
    @ApeMaterno VARCHAR(50),
    @Sexo VARCHAR(10),
    @Sueldo DECIMAL(10, 2),
    @Telefono VARCHAR(15),
    @Direccion VARCHAR(100),
    @IdCargo INT,
    @IdEstado INT,
    @IdDistrito INT,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowCount INT;

    IF EXISTS (SELECT * FROM Colaborador WHERE DNI = @DNI)
    BEGIN
        MERGE INTO Colaborador WITH (HOLDLOCK) AS T
        USING (
            SELECT @DNI, @Nombre, @ApePaterno, @ApeMaterno, @Sexo, @Sueldo, @Telefono, @Direccion, @IdCargo, @IdEstado, @IdDistrito
        ) AS S (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
        ON T.DNI = S.DNI
        WHEN MATCHED AND T.DNI = S.DNI THEN
            UPDATE SET
                T.Nombre = S.Nombre,
                T.ApePaterno = S.ApePaterno,
                T.ApeMaterno = S.ApeMaterno,
                T.Sexo = S.Sexo,
                T.Sueldo = S.Sueldo,
                T.Telefono = S.Telefono,
                T.Direccion = S.Direccion,
                T.IdCargo = S.IdCargo,
                T.IdEstado = S.IdEstado,
                T.IdDistrito = S.IdDistrito
        WHEN NOT MATCHED THEN
            INSERT (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
            VALUES (S.DNI, S.Nombre, S.ApePaterno, S.ApeMaterno, S.Sexo, S.Sueldo, S.Telefono, S.Direccion, S.IdCargo, S.IdEstado, S.IdDistrito);

        SET @RowCount = @@ROWCOUNT;

        IF @RowCount = 1
        BEGIN
            SET @Mensaje = 'Colaborador actualizado con éxito.';
        END
        ELSE IF @RowCount = 2
        BEGIN
            SET @Mensaje = 'Colaborador registrado con éxito.';
        END
        ELSE
        BEGIN
            SET @Mensaje = 'Error en el registro del colaborador.';
        END
    END
    ELSE
    BEGIN
        INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
        VALUES (@DNI, @Nombre, @ApePaterno, @ApeMaterno, @Sexo, @Sueldo, @Telefono, @Direccion, @IdCargo, @IdEstado, @IdDistrito);

        SET @RowCount = @@ROWCOUNT;

        IF @RowCount = 1
        BEGIN
            SET @Mensaje = 'Colaborador registrado con éxito.';
        END
        ELSE
        BEGIN
            SET @Mensaje = 'Error en el registro del colaborador.';
		END
	END
		Return;
END
GO

------- [Usuario Principal] --------


DECLARE @Mensaje VARCHAR(100);
EXEC sp_RegistrarUsuarioColaborador 
    @Email = 'jhosetsales@gmail.com',
    @Clave = 'password123',
    @DNI = '74643627',
    @Mensaje = @Mensaje OUTPUT;

PRINT @Mensaje;
GO


----------------------------------------
----------------- Test -----------------
----------------------------------------

DECLARE @Mensaje VARCHAR(100);
DECLARE @IdUsuarioCliente INT;

EXEC sp_RegistrarUsuarioCliente 
    @Nombre = 'Jhoset',
    @ApePaterno = 'Llacchua',
    @ApeMaterno = 'Sales',
    @Email = 'jhosetsales@gmail.com',
    @Clave = 'password123',
    @IdUsuarioCliente = @IdUsuarioCliente OUTPUT,
    @Mensaje = @Mensaje OUTPUT;

PRINT @Mensaje;


select * from UsuarioCliente
select * from Cliente
GO



DECLARE @Email VARCHAR(100) = 'jhosetsales@gmail.com'
DECLARE @Clave VARCHAR(50) = 'password123'
DECLARE @Mensaje VARCHAR(100)

EXEC sp_IniciarSesionUsuarioColaborador @Email, @Clave, @Mensaje OUTPUT

SELECT @Mensaje AS Mensaje




