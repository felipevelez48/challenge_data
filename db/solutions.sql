-- 1 -> Insertar un nuevo empleado (ID 6)

INSERT INTO empleados AS e (id_empleado, nombre, apellido, fecha_contratacion, salario, id_departamento)
VALUES (6, 'Elena', 'López', '2023-05-01', 33000.00, 3)
ON CONFLICT (id_empleado) DO UPDATE
    SET nombre              = EXCLUDED.nombre,
        apellido            = EXCLUDED.apellido,
        fecha_contratacion  = EXCLUDED.fecha_contratacion,
        salario             = EXCLUDED.salario,
        id_departamento     = EXCLUDED.id_departamento;


--2 -> Actualizar salario del empleado ID 2 → 37 000

UPDATE empleados
   SET salario = 37000.00
 WHERE id_empleado = 2;


-- 3 -> Trigger para descontar stock al crear un detalle_pedidos

-- 3.1  Función
CREATE OR REPLACE FUNCTION fn_disminuir_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE productos
       SET stock = stock - NEW.cantidad
     WHERE id_producto = NEW.id_producto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3.2  Trigger (AFTER INSERT en detalle_pedidos)
DROP TRIGGER IF EXISTS trg_disminuir_stock ON detalle_pedidos;
CREATE TRIGGER trg_disminuir_stock
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
EXECUTE FUNCTION fn_disminuir_stock();


/* ------------------------------------------------------------------
4 -> Consulta de productos
   - nombre_producto
   - stock actual
   - veces_pedido  : número de órdenes distintas
   - cantidad_vendida : SUM(cantidad)
   - fecha_ultimo_pedido
   - total_ingresos : SUM(cantidad * precio_unitario)
   * Filtra productos con >1 pedido
-------------------------------------------------------------------*/

WITH stats AS (
  SELECT
      p.id_producto,
      p.nombre_producto,
      p.stock,
      COUNT(DISTINCT dp.id_pedido)     AS veces_pedido,
      SUM(dp.cantidad)                AS cantidad_vendida,
      MAX(pe.fecha_pedido)            AS fecha_ultimo_pedido,
      SUM(dp.cantidad * dp.precio_unitario) AS total_ingresos
  FROM productos p
  LEFT JOIN detalle_pedidos dp ON p.id_producto = dp.id_producto
  LEFT JOIN pedidos pe         ON dp.id_pedido  = pe.id_pedido
  GROUP BY p.id_producto, p.nombre_producto, p.stock
)
SELECT *
FROM   stats
WHERE  veces_pedido > 1
ORDER BY total_ingresos DESC;

/* ------------------------------------------------------------------
5 -> Índices recomendados para tabla «pedidos»
   * idx_pedidos_cliente          : acelerará JOINs / filtros por cliente
   * idx_pedidos_fecha_pedido     : acelerar rangos de fechas frecuentes
-------------------------------------------------------------------*/
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente
    ON pedidos (id_cliente);

CREATE INDEX IF NOT EXISTS idx_pedidos_fecha_pedido
    ON pedidos (fecha_pedido DESC);

/* ------------------------------------------------------------------
6 -> Window function – salario acumulado por departamento
-------------------------------------------------------------------*/
SELECT
    id_departamento,
    id_empleado,
    nombre,
    apellido,
    salario,
    SUM(salario) OVER (
        PARTITION BY id_departamento
        ORDER BY fecha_contratacion
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS salario_acumulado
FROM empleados
ORDER BY id_departamento, fecha_contratacion;