USE BD_TiendaZapatillas
GO


CREATE PROCEDURE sp_RegistrarUsuarioCliente 
    @Nombre VARCHAR(50),
    @ApePaterno VARCHAR(50),
    @ApeMaterno VARCHAR(50),
    @Email VARCHAR(100),
    @Clave VARCHAR(50),
    @IdTipoUsuario INT = 1,
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
    
    SET @Mensaje = 'El usuario ha sido registrado exitosamente.';
END
GO


----------------------------------
DECLARE @Mensaje VARCHAR(100);
EXEC sp_RegistrarUsuarioCliente 
    @Nombre = 'Jhoset',
    @ApePaterno = 'Llacchua',
	@ApeMaterno = 'Sales',
    @Email = 'jhosetsales@gmail.com',
    @Clave = 'password123',
    @IdTipoUsuario = 1,
    @Mensaje = @Mensaje OUTPUT;

PRINT @Mensaje;

select * from UsuarioCliente
GO
--------------------------------

CREATE PROCEDURE sp_IniciarSesionUsuarioCliente 
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

DECLARE @Mensaje VARCHAR(100);
DECLARE @IdUsuario INT;

EXEC sp_IniciarSesionUsuarioCliente 
     @Email = 'jhosetsales@gmail.com',
    @Clave = 'password1234',
    @Mensaje = @Mensaje OUTPUT,
    @IdUsuario = @IdUsuario OUTPUT;

SELECT @Mensaje AS Mensaje, @IdUsuario AS Id
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


select * from UsuarioColaborador

DECLARE @Mensaje VARCHAR(100);
EXEC sp_RegistrarUsuarioColaborador 
    @Email = 'maria@gmail.com',
    @Clave = 'contraseña',
    @DNI = '74643629',
    @Mensaje = @Mensaje OUTPUT;

PRINT @Mensaje;

--------------------


CREATE PROCEDURE sp_IniciarSesionUsuarioColaborador
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


DECLARE @Email VARCHAR(100) = 'maria@gmail.com'
DECLARE @Clave VARCHAR(50) = 'contraseña'
DECLARE @Mensaje VARCHAR(100)

EXEC sp_IniciarSesionUsuarioColaborador @Email, @Clave, @Mensaje OUTPUT

SELECT @Mensaje AS Mensaje


select * from UsuarioColaborador