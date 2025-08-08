CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_contratacion DATE,
    salario DECIMAL(10, 2),
    id_departamento INT
);

INSERT INTO empleados VALUES
(1, 'Juan', 'Pérez', '2020-01-15', 30000.00, 1),
(2, 'María', 'González', '2019-05-20', 35000.00, 2),
(3, 'Carlos', 'Rodríguez', '2021-03-10', 28000.00, 1),
(4, 'Ana', 'Martínez', '2018-11-01', 40000.00, 3),
(5, 'Luis', 'Sánchez', '2022-07-05', 32000.00, 2);



CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(50)
);

INSERT INTO departamentos VALUES
(1, 'Ventas'),
(2, 'Marketing'),
(3, 'Recursos Humanos'),
(4, 'Tecnología');


CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    precio DECIMAL(10, 2),
    stock INT
);

INSERT INTO productos VALUES
(1, 'Laptop', 1200.00, 50),
(2, 'Smartphone', 800.00, 100),
(3, 'Tablet', 300.00, 75),
(4, 'Monitor', 250.00, 30),
(5, 'Teclado', 50.00, 200);


CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO clientes VALUES
(1, 'Pedro', 'Gómez', 'pedro@email.com'),
(2, 'Laura', 'Fernández', 'laura@email.com'),
(3, 'Miguel', 'Torres', 'miguel@email.com'),
(4, 'Sofia', 'Díaz', 'sofia@email.com');


-- Tabla pedidos (sin cambios en la estructura)
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido DATE,
    total DECIMAL(10, 2)
);

-- Datos actualizados para la tabla pedidos
INSERT INTO pedidos VALUES
(1, 1, '2023-01-10', 2700.00),  -- 2 laptops + 1 tablet
(2, 2, '2023-02-15', 800.00),   -- 1 smartphone
(3, 3, '2023-03-20', 550.00),   -- 2 monitores + 1 teclado
(4, 4, '2023-04-05', 2100.00);  -- 1 laptop + 1 smartphone + 2 teclados

-- Tabla detalle_pedidos (sin cambios)
CREATE TABLE detalle_pedidos (
    id_detalle INT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10, 2)
);

-- Datos para detalle_pedidos (sin cambios)
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 2, 1200.00),  -- 2 laptops en el pedido 1
(2, 1, 3, 1, 300.00),   -- 1 tablet en el pedido 1
(3, 2, 2, 1, 800.00),   -- 1 smartphone en el pedido 2
(4, 3, 4, 2, 250.00),   -- 2 monitores en el pedido 3
(5, 3, 5, 1, 50.00),    -- 1 teclado en el pedido 3
(6, 4, 1, 1, 1200.00),  -- 1 laptop en el pedido 4
(7, 4, 2, 1, 800.00),   -- 1 smartphone en el pedido 4
(8, 4, 5, 2, 50.00);    -- 2 teclados en el pedido 4
