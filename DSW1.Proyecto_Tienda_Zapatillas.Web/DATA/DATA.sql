-- Verificar si la base de datos ya existe
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'BD_TiendaZapatillas')
BEGIN
    -- Crear la base de datos
    CREATE DATABASE BD_TiendaZapatillas;
    PRINT 'La base de datos BD_TiendaZapatillas ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La base de datos BD_TiendaZapatillas ya existe';
END
GO

USE BD_TiendaZapatillas
GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Categoria')
BEGIN
    CREATE TABLE Categoria (
        IdCategoria INT PRIMARY KEY,
        Descripcion VARCHAR(100) NOT NULL
    );
    PRINT 'La tabla Categoria ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Categoria ya existe';
END



IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Provincia')
BEGIN
    CREATE TABLE Provincia (
        IdProvincia INT PRIMARY KEY,
        Descripcion VARCHAR(50) NOT NULL
    );
    PRINT 'La tabla Provincia ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Provincia ya existe';
END


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Estado')
BEGIN
    CREATE TABLE Estado (
        IdEstado INT PRIMARY KEY,
        Descripcion VARCHAR(50) NOT NULL
    );
    PRINT 'La tabla Estado ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Estado ya existe';
END



IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TipoUsuario')
BEGIN
    CREATE TABLE TipoUsuario (
        IdTipoUsuario INT PRIMARY KEY,
        descripcion VARCHAR(50) NOT NULL
    );
    PRINT 'La tabla tb_TipoUsuario ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla tb_TipoUsuario ya existe';
END
GO


--------------------------------


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Producto')
BEGIN
    CREATE TABLE Producto (
        IdProducto INT PRIMARY KEY,
        Nombre VARCHAR(100) NOT NULL,
        Descripcion VARCHAR(500) NOT NULL,
        Precio DECIMAL(10,2) NOT NULL,
        Imagen VARCHAR(500) NOT NULL,
        Stock INT NOT NULL,
        IdCategoria INT,
        FOREIGN KEY (IdCategoria) REFERENCES Categoria(IdCategoria)
    );
    PRINT 'La tabla Producto ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Producto ya existe';
END


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Distrito')
BEGIN
    CREATE TABLE Distrito (
        IdDistrito INT PRIMARY KEY,
        Descripcion VARCHAR(50) NOT NULL,
        IdProvincia INT NOT NULL,
        FOREIGN KEY (IdProvincia) REFERENCES Provincia(IdProvincia)
    );
    PRINT 'La tabla tb_Distrito ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla tb_Distrito ya existe';
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Cargo')
BEGIN
    CREATE TABLE Cargo (
        IdCargo INT PRIMARY KEY,
        Descripcion VARCHAR(50) NOT NULL,
        IdTipoUsuario INT NOT NULL,
        FOREIGN KEY (IdTipoUsuario) REFERENCES TipoUsuario(IdTipoUsuario)
    );
    PRINT 'La tabla Cargo ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Cargo ya existe';
END


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'UsuarioCliente')
BEGIN
    CREATE TABLE UsuarioCliente (
        IdUsuarioCliente INT PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        ApePaterno VARCHAR(50) NOT NULL,
        ApeMaterno VARCHAR(50) NOT NULL,
        Email VARCHAR(100) unique NOT NULL,
        Clave VARBINARY(32) NOT NULL,
        IdTipoUsuario INT FOREIGN KEY REFERENCES TipoUsuario(IdTipoUsuario)
    );
    PRINT 'La tabla UsuarioCliente ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla UsuarioCliente ya existe';
END






------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Colaborador')
BEGIN
    CREATE TABLE Colaborador (
        DNI CHAR(8) PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        ApePaterno VARCHAR(50) NOT NULL,
		ApeMaterno VARCHAR(50) NOT NULL,
        Sexo VARCHAR(10) NOT NULL,
        Sueldo DECIMAL(10, 2) NOT NULL,
        Telefono VARCHAR(15) NOT NULL,
        Direccion VARCHAR(100) NOT NULL,
        IdCargo INT NOT NULL,
        IdEstado INT NOT NULL,
        IdDistrito INT NOT NULL,
        CONSTRAINT FK_Colaborador_Cargo FOREIGN KEY (IdCargo) REFERENCES Cargo(IdCargo),
        CONSTRAINT FK_Colaborador_Estado FOREIGN KEY (IdEstado) REFERENCES Estado(IdEstado),
        CONSTRAINT FK_Colaborador_Distrito FOREIGN KEY (IdDistrito) REFERENCES Distrito(IdDistrito)
    );
    CREATE UNIQUE INDEX UX_Colaborador_DNI ON Colaborador(DNI);
    PRINT 'La tabla Colaborador ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Colaborador ya existe';
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Cliente')
BEGIN
    CREATE TABLE Cliente (
        IdCliente INT PRIMARY KEY,
        Sexo VARCHAR(10),
        Telefono VARCHAR(20),
        Direccion VARCHAR(100),
        IdUsuarioCliente INT NOT NULL,
        IdDistrito INT,
        FOREIGN KEY (IdUsuarioCliente) REFERENCES UsuarioCliente(IdUsuarioCliente),
        FOREIGN KEY (IdDistrito) REFERENCES Distrito(IdDistrito)
    );
    PRINT 'La tabla Cliente ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Cliente ya existe';
END



IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Carrito')
BEGIN
    CREATE TABLE Carrito (
        IdCarrito INT PRIMARY KEY,
        Fecha DATETIME NOT NULL,
        Estado VARCHAR(20) NOT NULL,
        IdUsuarioCliente INT NOT NULL,
        FOREIGN KEY (IdUsuarioCliente) REFERENCES UsuarioCliente(IdUsuarioCliente)
    );
    PRINT 'La tabla Carrito ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Carrito ya existe';
END



----------------------------------------------------
-- Al registrar Debo hacer una consulta a DNI para traer el nombre y apellido
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'UsuarioColaborador')
BEGIN
    CREATE TABLE UsuarioColaborador (
        IdUsuarioColaborador INT IDENTITY(1,1) PRIMARY KEY,
        Email VARCHAR(100) unique NOT NULL,
        Clave VARBINARY(32) NOT NULL,
		ValidacionCargo INT NOT NULL,
        DNI CHAR(8) NOT NULL,
        FOREIGN KEY (DNI) REFERENCES Colaborador(DNI)
    );
    PRINT 'La tabla UsuarioColaborador ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla UsuarioColaborador ya existe';
END


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DetalleCarrito')
BEGIN
    CREATE TABLE DetalleCarrito (
        IdDetalleCarrito INT PRIMARY KEY,
        Cantidad INT NOT NULL,
        Precio DECIMAL(10,2) NOT NULL,
        IdCarrito INT NOT NULL,
        IdProducto INT NOT NULL,
        FOREIGN KEY (IdCarrito) REFERENCES Carrito(IdCarrito),
        FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
    );
    PRINT 'La tabla DetalleCarrito ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla DetalleCarrito ya existe';
END



--------------------------------------



-- Insertar registros en TipoUsuario si no existen
INSERT INTO TipoUsuario (IdTipoUsuario, descripcion)
SELECT 1, 'Cliente'
WHERE NOT EXISTS (SELECT 1 FROM TipoUsuario WHERE IdTipoUsuario = 1);

INSERT INTO TipoUsuario (IdTipoUsuario, descripcion)
SELECT 2, 'Vendedor'
WHERE NOT EXISTS (SELECT 1 FROM TipoUsuario WHERE IdTipoUsuario = 2);

INSERT INTO TipoUsuario (IdTipoUsuario, descripcion)
SELECT 3, 'Administrador'
WHERE NOT EXISTS (SELECT 1 FROM TipoUsuario WHERE IdTipoUsuario = 3);

INSERT INTO TipoUsuario (IdTipoUsuario, descripcion)
SELECT 4, 'Gerente'
WHERE NOT EXISTS (SELECT 1 FROM TipoUsuario WHERE IdTipoUsuario = 4);


-----------------------

-- Insertar registros en Estado si no existen
INSERT INTO Estado (IdEstado, Descripcion)
SELECT 1, 'Activa'
WHERE NOT EXISTS (SELECT 1 FROM Estado WHERE IdEstado = 1);

INSERT INTO Estado (IdEstado, Descripcion)
SELECT 2, 'Inactiva'
WHERE NOT EXISTS (SELECT 1 FROM Estado WHERE IdEstado = 2);

--------



INSERT INTO Provincia (IdProvincia, Descripcion) VALUES
(1, 'Lima'),
(2, 'Arequipa'),
(3, 'Cusco');

INSERT INTO Distrito (IdDistrito, Descripcion, IdProvincia) VALUES 
(1, 'Lima', 1),
(2, 'Los Olivos', 1),
(3, 'Comas', 1),
(4, 'Carabayllo', 1),
(5, 'Ate', 1),
(6, 'San Juan de Lurigancho', 1),
(7, 'Breña', 1),
(8, 'San Miguel', 1),
(9, 'Surco', 1),
(10, 'Jesús María', 1),
(11, 'Arequipa', 2),
(12, 'Cayma', 2),
(13, 'Cerro Colorado', 2),
(14, 'Mariano Melgar', 2),
(15, 'Yanahuara', 2),
(16, 'Cusco', 3),
(17, 'San Sebastián', 3),
(18, 'Santiago', 3),
(19, 'Wanchaq', 3),
(20, 'San Jerónimo', 3);

-----------------

-- Insertar registros en Cargo si no existen
INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario)
SELECT 1, 'Vendedor', 2
WHERE NOT EXISTS (SELECT 1 FROM Cargo WHERE IdCargo = 1);

INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario)
SELECT 2, 'Administrador', 3
WHERE NOT EXISTS (SELECT 1 FROM Cargo WHERE IdCargo = 2);

INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario)
SELECT 3, 'Gerente', 4
WHERE NOT EXISTS (SELECT 1 FROM Cargo WHERE IdCargo = 3);



-- Colaborador
INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
VALUES ('74643627', 'Jhoset', 'Llacchua', 'Sales', 'Masculino', 1025.00, '933352723', 'Admin dir', 2, 1, 3);



PRINT 'BD_TiendaZapatillas ejecutada correctamente';