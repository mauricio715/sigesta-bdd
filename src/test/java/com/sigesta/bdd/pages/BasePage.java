package com.sigesta.bdd.pages;

import net.serenitybdd.core.pages.PageObject;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

/** Utilidades comunes con esperas explícitas para la SPA de React. */
public abstract class BasePage extends PageObject {

    protected static final String URL_BASE = "http://localhost:5173";
    protected static final Duration ESPERA = Duration.ofSeconds(30);

    protected WebDriverWait esperar() {
        return new WebDriverWait(getDriver(), ESPERA);
    }

    protected WebElement visible(By localizador) {
        return esperar().until(ExpectedConditions.visibilityOfElementLocated(localizador));
    }

    protected WebElement clicable(By localizador) {
        return esperar().until(ExpectedConditions.elementToBeClickable(localizador));
    }

    protected void escribir(By localizador, String texto) {
        WebElement campo = clicable(localizador);
        campo.clear();
        campo.sendKeys(texto);
    }

    protected void esperarQueDesaparezca(By localizador) {
        esperar().until(ExpectedConditions.invisibilityOfElementLocated(localizador));
    }

    protected boolean existeVisible(By localizador) {
        return getDriver().findElements(localizador).stream().anyMatch(WebElement::isDisplayed);
    }

    /** Enlace del menú lateral (aside "Módulos") por su texto visible. */
    public void irAlModulo(String nombreModulo) {
        By enlace = By.xpath("//aside[@aria-label='Módulos']//a[normalize-space()='" + nombreModulo + "']");
        clicable(enlace).click();
        esperar().until(ExpectedConditions.textToBePresentInElementLocated(
                By.cssSelector("header p.truncate"), nombreModulo));
    }

    public String tituloDelModuloActual() {
        return visible(By.cssSelector("header p.truncate")).getText().trim();
    }

    public String tituloH1() {
        return visible(By.cssSelector("main h1")).getText().trim();
    }
}
