# language: es
@sigesta
Característica: Pruebas funcionales E2E de SI-GESTA
  Como administrador de la planta Brunette
  Quiero ingresar a SI-GESTA y consultar sus módulos principales
  Para controlar la trazabilidad de los lotes y planificar la demanda

  Antecedentes:
    Dado que el administrador abre la página de inicio de sesión de SI-GESTA

  @login
  Escenario: Inicio de sesión exitoso como administrador
    Cuando ingresa el correo "admin@sigesta.com" y la contraseña "password"
    Y presiona el botón Iniciar sesión
    Entonces ingresa al módulo "Panel de control"
    Y ve el saludo de bienvenida y los indicadores de la planta

  @trazabilidad
  Escenario: Consulta de trazabilidad bidireccional de un lote real
    Dado que inició sesión con el correo "admin@sigesta.com" y la contraseña "password"
    Cuando navega al módulo "Trazabilidad" desde el menú lateral
    Y busca el lote "LEC-LV-2609"
    Entonces ve la trazabilidad "Hacia adelante" del lote "LEC-LV-2609"
    Y el proveedor de origen del lote es "Lácteos del Valle S.A."
    Y ve la sección "Producción donde se usó"
    Y ve la sección "Clientes que recibieron producto con este insumo"

  @prediccion
  Escenario: Visualización del módulo de Predicción de demanda con Machine Learning
    Dado que inició sesión con el correo "admin@sigesta.com" y la contraseña "password"
    Cuando navega al módulo "Predicción de demanda" desde el menú lateral
    Entonces ve el título de la página "Predicción de demanda"
    Y el modelo termina de calcular sin mostrar errores
    Y ve las secciones "Desempeño del modelo" y "Proyección de ventas"
