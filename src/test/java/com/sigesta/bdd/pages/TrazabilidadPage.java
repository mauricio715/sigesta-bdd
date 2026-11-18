package com.sigesta.bdd.pages;

import org.openqa.selenium.By;

/** Módulo Trazabilidad (TrazabilidadPage.jsx + BuscadorLote.jsx). */
public class TrazabilidadPage extends BasePage {

    private static final By CAMPO_LOTE = By.id("lote-trazabilidad");
    private static final By BOTON_BUSCAR = By.xpath("//input[@id='lote-trazabilidad']/following-sibling::button[contains(normalize-space(),'Buscar')]");
    private static final By CARGANDO = By.xpath("//*[@role='status' and contains(.,'Reconstruyendo la cadena del lote')]");

    public void buscarLote(String codigo) {
        escribir(CAMPO_LOTE, codigo);
        clicable(BOTON_BUSCAR).click();
    }

    public String direccionDeTrazabilidad(String direccionEsperada) {
        return visible(By.xpath("//main//p[normalize-space()='" + direccionEsperada + "']")).getText().trim();
    }

    public boolean loteSeleccionadoVisible(String codigo) {
        return visible(By.xpath("//main//span[contains(@class,'cifra') and normalize-space()='" + codigo + "']")).isDisplayed();
    }

    public String proveedorDelLote(String proveedor) {
        return visible(By.xpath("//main//span[contains(normalize-space(),'" + proveedor + "')]")).getText().trim();
    }

    public boolean seccionVisible(String titulo) {
        esperarQueDesaparezca(CARGANDO);
        return visible(By.xpath("//main//*[normalize-space(text())='" + titulo + "']")).isDisplayed();
    }

    public boolean hayError() {
        return existeVisible(By.cssSelector("main [role='alert']"));
    }
}
