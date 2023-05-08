IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'BD_TiendaZapatillas')
BEGIN
  CREATE DATABASE BD_TiendaZapatillas
  PRINT 'La base de datos BD_TiendaZapatillas ha sido creada exitosamente'
END
ELSE
BEGIN
  PRINT 'La base de datos BD_TiendaZapatillas ya existe'
END

USE BD_TiendaZapatillas

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
        Sexo CHAR(1) NOT NULL,
        Telefono VARCHAR(20) NOT NULL,
        Direccion VARCHAR(100) NOT NULL,
        IdUsuarioCliente INT NOT NULL,
        IdDistrito INT NOT NULL,
        FOREIGN KEY (IdUsuarioCliente) REFERENCES UsuarioCliente(IdUsuarioCliente),
        FOREIGN KEY (IdDistrito) REFERENCES Distrito(IdDistrito)
    );
    PRINT 'La tabla Cliente ha sido creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Cliente ya existe';
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



--------------------------------------



INSERT INTO TipoUsuario (IdTipoUsuario, descripcion) VALUES (1, 'Cliente');
INSERT INTO TipoUsuario (IdTipoUsuario, descripcion) VALUES (2, 'Vendedor');
INSERT INTO TipoUsuario (IdTipoUsuario, descripcion) VALUES (3, 'Administrador');
INSERT INTO TipoUsuario (IdTipoUsuario, descripcion) VALUES (4, 'Gerente');

INSERT INTO Estado (IdEstado, Descripcion) VALUES
(1, 'Activa'),
(2, 'Inactiva');

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


INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario) VALUES (1, 'Vendedor',2);
INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario) VALUES (2, 'Administrador',3);
INSERT INTO Cargo (IdCargo, Descripcion, IdTipoUsuario) VALUES (3, 'Gerente',4);

Select * from Colaborador


-- Colaborador
INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
VALUES ('74643627', 'Jhoset', 'Llacchua', 'Sales', 'Masculino', 1025.00, '933352723', 'Tarapaca 130, 15324', 3, 1, 3);


INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
VALUES ('74643628', 'Juan', 'Antonio', 'Perez', 'Masculino', 1025.00, '933352723', 'Tarapaca 130, 15324', 3, 1, 3);



INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
VALUES ('74643629', 'Maria', 'Antonieta', 'De las nieves', 'Femenino', 1025.00, '933352723', 'Tarapaca 130, 15324', 1, 1, 3);



INSERT INTO Colaborador (DNI, Nombre, ApePaterno, ApeMaterno, Sexo, Sueldo, Telefono, Direccion, IdCargo, IdEstado, IdDistrito)
VALUES ('73617739', 'Mavic', 'Wolf', 'Doom', 'Masculino', 1025.00, '933352723', 'Tarapaca 130, 15324', 2, 1, 2);

select * from UsuarioCliente