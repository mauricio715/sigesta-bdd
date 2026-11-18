# sigesta-bdd

Pruebas funcionales End-to-End (E2E) de **SI-GESTA** con BDD:
Java + Maven + Cucumber + Gherkin en español + Serenity BDD.

Proyecto independiente del código fuente de SI-GESTA.

## Requisitos
- Java 17+ y Maven 3.8+
- Google Chrome
- SI-GESTA corriendo: frontend `http://localhost:5173`, backend Laravel `:8000`, ai-service `:8001`
- Base de datos con `DemoSeeder` (usuario `admin@sigesta.com` / `password`, lote `LEC-LV-2609`)

## Ejecutar
```
mvn clean verify
```
Reporte: `target/site/serenity/index.html`

Por etiqueta: `mvn clean verify -Dcucumber.filter.tags="@trazabilidad"`

## Escenarios (`src/test/resources/features/sigesta_bdd.feature`)
1. Inicio de sesión exitoso como administrador → Panel de control
2. Trazabilidad bidireccional del lote `LEC-LV-2609` (proveedor Lácteos del Valle S.A.)
3. Predicción de demanda (Machine Learning) sin errores

## Jenkins (Freestyle)
- Git: URL de este repositorio, rama `main`
- Paso de build: *Invoke top-level Maven targets* → `clean verify`
- Post-build: *Publish HTML reports* → directorio `target/site/serenity`, índice `index.html`
