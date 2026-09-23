# Plantilla Base para Proyectos FPGA — ITLA
**Placa:** Sipeed Tang Primer 25K (Gowin GW5A-LV25MG121NC1/I0)  
**Estudiante:** Urik Valenzuela (`2025-0469`) · `20250469@itla.edu.do`  

---

## Cómo usar esta plantilla para una nueva tarea o Code Challenge

Para iniciar una nueva práctica o asignación sin empezar desde cero:

1. **Duplica esta carpeta** asignándole el nombre de tu nueva asignación:
   ```bash
   cd "/run/media/urikv/WD_BLACK/ITLA/School/C6/Sistemas Digitales"
   cp -r template-fpga mi-nueva-tarea
   ```

2. **Abre la nueva carpeta en VSCodium:**
   ```bash
   codium mi-nueva-tarea
   ```

3. **Escribe tu lógica y banco de pruebas:**
   * Módulos sintetizables en: `src/`
   * Testbench auto-verificable en: `tb/`
   * Pines físicos en: `top.cst`

---

## Flujo de Trabajo Rápido

* **Verificación de lógica (en 1 segundo):**
  Presiona `Ctrl + Shift + B` en VSCodium o ejecuta:
  ```bash
  make check
  ```

* **Ver formas de onda en GTKWave:**
  ```bash
  make wave
  ```

* **Compilar a hardware (Sintetizar bitstream):**
  ```bash
  make synth
  ```

* **Cargar a la placa Tang Primer 25K:**
  * Prueba rápida (SRAM): `make load`
  * Grabado permanente (Flash): `make flash`

* **Limpiar archivos generados:**
  ```bash
  make clean
  ```
