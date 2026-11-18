package com.sigesta.bdd.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

/** Pantalla de inicio de sesión (frontend/src/pages/LoginPage.jsx). */
public class LoginPage extends BasePage {

    private static final By CAMPO_CORREO = By.id("email");
    private static final By CAMPO_CONTRASENA = By.id("password");
    private static final By BOTON_INGRESAR = By.xpath("//form//button[@type='submit' and contains(normalize-space(),'Iniciar sesión')]");
    private static final By TITULO_FORMULARIO = By.xpath("//h2[normalize-space()='Iniciar sesión']");
    private static final By MENU_LATERAL = By.cssSelector("aside[aria-label='Módulos']");

    public void abrir() {
        getDriver().manage().deleteAllCookies();
        getDriver().get(URL_BASE + "/login");
        // Limpia una sesión previa guardada por la SPA
        ((org.openqa.selenium.JavascriptExecutor) getDriver()).executeScript("window.localStorage.clear(); window.sessionStorage.clear();");
        getDriver().navigate().refresh();
        visible(TITULO_FORMULARIO);
    }

    public void ingresarCredenciales(String correo, String contrasena) {
        escribir(CAMPO_CORREO, correo);
        escribir(CAMPO_CONTRASENA, contrasena);
    }

    public void presionarIniciarSesion() {
        clicable(BOTON_INGRESAR).click();
        esperar().until(ExpectedConditions.visibilityOfElementLocated(MENU_LATERAL));
    }

    public void iniciarSesion(String correo, String contrasena) {
        ingresarCredenciales(correo, contrasena);
        presionarIniciarSesion();
    }
}
