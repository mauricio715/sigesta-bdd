package com.sigesta.bdd.stepdefinitions;

import com.sigesta.bdd.pages.LoginPage;
import com.sigesta.bdd.pages.PanelControlPage;
import com.sigesta.bdd.pages.PrediccionPage;
import com.sigesta.bdd.pages.TrazabilidadPage;
import io.cucumber.java.es.Cuando;
import io.cucumber.java.es.Dado;
import io.cucumber.java.es.Entonces;
import io.cucumber.java.es.Y;

import static org.assertj.core.api.Assertions.assertThat;

/** Definiciones de pasos en español para sigesta_bdd.feature. */
public class SigestaStepDefinitions {

    // Serenity instancia y comparte el WebDriver de cada PageObject
    LoginPage login;
    PanelControlPage panel;
    TrazabilidadPage trazabilidad;
    PrediccionPage prediccion;

    // ---------- Antecedentes / Login ----------

    @Dado("que el administrador abre la página de inicio de sesión de SI-GESTA")
    public void abrirLogin() {
        login.abrir();
    }

    @Cuando("ingresa el correo {string} y la contraseña {string}")
    public void ingresarCredenciales(String correo, String contrasena) {
        login.ingresarCredenciales(correo, contrasena);
    }

    @Y("presiona el botón Iniciar sesión")
    public void presionarIniciarSesion() {
        login.presionarIniciarSesion();
    }

    @Dado("que inició sesión con el correo {string} y la contraseña {string}")
    public void iniciarSesion(String correo, String contrasena) {
        login.iniciarSesion(correo, contrasena);
    }

    @Entonces("ingresa al módulo {string}")
    public void ingresaAlModulo(String modulo) {
        assertThat(panel.estaEnLaRaiz()).isTrue();
        assertThat(panel.tituloDelModuloActual()).isEqualTo(modulo);
        assertThat(panel.enlaceActivoDelMenu()).isEqualTo(modulo);
    }

    @Y("ve el saludo de bienvenida y los indicadores de la planta")
    public void veSaludoEIndicadores() {
        assertThat(panel.saludo()).startsWith("Buen turno");
        assertThat(panel.indicadoresVisibles()).isTrue();
    }

    // ---------- Navegación ----------

    @Cuando("navega al módulo {string} desde el menú lateral")
    public void navegarAlModulo(String modulo) {
        panel.irAlModulo(modulo);
        assertThat(panel.tituloDelModuloActual()).isEqualTo(modulo);
    }

    // ---------- Trazabilidad ----------

    @Y("busca el lote {string}")
    public void buscarLote(String codigo) {
        trazabilidad.buscarLote(codigo);
    }

    @Entonces("ve la trazabilidad {string} del lote {string}")
    public void veTrazabilidad(String direccion, String codigo) {
        assertThat(trazabilidad.direccionDeTrazabilidad(direccion)).isEqualTo(direccion);
        assertThat(trazabilidad.loteSeleccionadoVisible(codigo)).isTrue();
    }

    @Y("el proveedor de origen del lote es {string}")
    public void proveedorDeOrigen(String proveedor) {
        assertThat(trazabilidad.proveedorDelLote(proveedor)).contains(proveedor);
    }

    @Y("ve la sección {string}")
    public void veSeccionTrazabilidad(String titulo) {
        assertThat(trazabilidad.seccionVisible(titulo)).isTrue();
        assertThat(trazabilidad.hayError()).as("No debe mostrarse un aviso de error").isFalse();
    }

    // ---------- Predicción de demanda ----------

    @Entonces("ve el título de la página {string}")
    public void veTitulo(String titulo) {
        assertThat(prediccion.tituloH1()).isEqualTo(titulo);
    }

    @Y("el modelo termina de calcular sin mostrar errores")
    public void modeloSinErrores() {
        prediccion.esperarCalculoDelModelo();
        assertThat(prediccion.hayError()).as("El módulo de ML no debe mostrar errores").isFalse();
    }

    @Y("ve las secciones {string} y {string}")
    public void veSecciones(String primera, String segunda) {
        assertThat(prediccion.seccionVisible(primera)).isTrue();
        assertThat(prediccion.seccionVisible(segunda)).isTrue();
    }
}
