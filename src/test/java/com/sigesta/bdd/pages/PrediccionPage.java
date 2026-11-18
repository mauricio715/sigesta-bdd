package com.sigesta.bdd.pages;

import org.openqa.selenium.By;

/** Módulo Predicción de demanda (PrediccionPage.jsx, regresión lineal). */
public class PrediccionPage extends BasePage {

    private static final By CARGANDO = By.xpath("//*[@role='status' and contains(.,'Entrenando el modelo')]");
    private static final By ERROR = By.cssSelector("main [role='alert']");

    public void esperarCalculoDelModelo() {
        esperarQueDesaparezca(CARGANDO);
        // El primer panel del plan es "Desempeño del modelo..."
        visible(By.xpath("//main//*[starts-with(normalize-space(text()),'Desempeño del modelo')]"));
    }

    public boolean hayError() {
        return existeVisible(ERROR);
    }

    public boolean seccionVisible(String inicioTitulo) {
        return visible(By.xpath("//main//*[starts-with(normalize-space(text()),'" + inicioTitulo + "')]")).isDisplayed();
    }
}
