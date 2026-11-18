package com.sigesta.bdd.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

/** Panel de control / Dashboard (frontend/src/pages/DashboardPage.jsx). */
public class PanelControlPage extends BasePage {

    private static final By SALUDO = By.xpath("//main//h1[starts-with(normalize-space(),'Buen turno')]");
    private static final By INDICADORES = By.cssSelector("main section[aria-label='Indicadores']");
    private static final By ENLACE_ACTIVO = By.xpath("//aside[@aria-label='Módulos']//a[@aria-current='page']");

    public String saludo() {
        return visible(SALUDO).getText().trim();
    }

    public boolean indicadoresVisibles() {
        return visible(INDICADORES).isDisplayed();
    }

    public String enlaceActivoDelMenu() {
        return visible(ENLACE_ACTIVO).getText().trim();
    }

    public boolean estaEnLaRaiz() {
        return esperar().until(ExpectedConditions.urlMatches("^http://localhost:5173/?$"));
    }
}
