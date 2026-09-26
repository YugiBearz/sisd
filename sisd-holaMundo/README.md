# Asignación #1: Montaje de Toolchain y Hola Mundo en FPGA

**Estudiante:** Urik Valenzuela (`2025-0469`) · `20250469@itla.edu.do`  
**Asignatura:** Sistemas Digitales con FPGA (TMC-212) · ITLA  
**Docente:** Prof. Wilkins Gabriel Cedano Del Rosario  
**Placa de Desarrollo:** Sipeed Tang Primer 25K (Chip Gowin GW5A-LV25MG121NC1/I0)  

---

## 1. Descripción del Proyecto

Implementación en Verilog 2005 del programa base "Hola Mundo" para la placa Sipeed Tang Primer 25K conectada a su placa dock base.

El objetivo de esta asignación es la validación integral y comprobación del toolchain de desarrollo de punta a punta:
1. **Análisis Estático (Linting):** Verificación con Verilator con directivas `-Wall --lint-only`.
2. **Simulación Funcional:** Simulación con Icarus Verilog (`iverilog`) y ejecución con `vvp`.
3. **Inspección de Señales:** Generación de archivos VCD para visualización en GTKWave.
4. **Síntesis y PnR:** Síntesis mediante Gowin EDA (`gw_sh` / `build.tcl`).
5. **Programación Física:** Carga a la memoria SRAM de la FPGA a través del programador openFPGALoader.

---

## 2. Funcionamiento del Circuito (`src/top.v`)

El circuito conecta un pulsador a un diodo LED mediante lógica puramente combinacional:
- Al presionar el pulsador (`btn_raw`), el LED (`led`) se ilumina.
- En estado de reposo, el LED permanece apagado.
- Incluye parámetros de polaridad (`BUTTON_ACTIVE_LOW` y `LED_ACTIVE_LOW`) para adaptar el comportamiento a los niveles eléctricos específicos de la placa base.

---

## 3. Mapeo Físico de Pines (`top.cst`)

| Señal | Pin Tang Primer 25K | Tipo I/O | Modo Pull | Función |
| :--- | :---: | :---: | :---: | :--- |
| `btn_raw` | **F5** | LVCMOS33 | PULL_UP | Pulsador S0 de la placa dock |
| `led` | **G11** | LVCMOS33 | NONE | Diodo LED D0 de la placa dock |

---

## 4. Instrucciones de Ejecución

- **Verificación estática:** `make lint`
- **Simulación del testbench:** `make sim`
- **Inspección de ondas:** `make wave`
- **Chequeo integral:** `make check`
- **Generación de Bitstream:** `make synth`
- **Carga rápida a la FPGA:** `make load`
- **Limpieza de archivos:** `make clean`
