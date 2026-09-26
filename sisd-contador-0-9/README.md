# Asignación #2: Contador Reversible 0 al 9 con Pantalla LCD 1602 (I2C)

**Estudiante:** Urik Valenzuela (`2025-0469`) · `20250469@itla.edu.do`  
**Asignatura:** Sistemas Digitales con FPGA (TMC-212) · ITLA  
**Docente:** Prof. Wilkins Gabriel Cedano Del Rosario  
**Placa de Desarrollo:** Sipeed Tang Primer 25K (Chip Gowin GW5A-LV25MG121NC1/I0)  
**Periféricos Externos:** Pantalla LCD 1602 con módulo I2C PCF8574 (`0x27`) y 3 pulsadores externos en protoboard con resistencias pull-down.

---

## 1. Descripción del Proyecto

Implementación en Verilog 2005 sintetizable de un sistema digital de conteo reversible del 0 al 9 con control de estados y visualización en una pantalla LCD 1602 controlada por el bus I2C mediante el chip expansor PCF8574.

### Requerimientos Funcionales Cumplidos
1. **Ritmo de Conteo:** El conteo avanza a una frecuencia exacta de 1 Hz (1 número por segundo), implementado con un generador de pulsos de reloj enable (`tick_gen`) sin relojes derivados.
2. **Pulsador 1 (`btn_on_off`):** Alterna el sistema entre encendido (conteo activo) y reposo/apagado (`[SYSTEM: OFF]`). Al apagar, el conteo se detiene y la pantalla muestra el mensaje correspondiente.
3. **Pulsador 2 (`btn_mode`):** Alterna entre modo Ascendente (0 a 9) y Descendente (9 a 0), preservando el número actual en el que se encuentra el contador.
4. **Pulsador 3 (`btn_reset`):** Reset condicional:
   - En modo Ascendente: reinicia el contador a `0`.
   - En modo Descendente: reinicia el contador a `9`.
5. **Detección de Fin de Conteo (`is_done`):** Al alcanzar el límite (9 en modo ascendente o 0 en modo descendente), el contador se detiene y la pantalla muestra `"Count Completed!"`.
6. **Formato en Pantalla LCD 1602:**
   - **Línea 1:**
     - En reposo: `"[SYSTEM: OFF]   "`
     - Conteo Ascendente: `"Ascending.      "`, `"Ascending..     "`, `"Ascending...    "` (animación de puntos a 1 Hz).
     - Conteo Descendente: `"Descending.     "`, `"Descending..    "`, `"Descending...   "` (animación de puntos a 1 Hz).
     - Fin de conteo: `"Count Completed!"`.
   - **Línea 2:**
     - El dígito numérico aparece centrado en la columna 7 (`"       " + ASCII + "        "`), sin prefijos.

---

## 2. Arquitectura de Módulos (RTL)

El diseño sigue una arquitectura modular estricta de 9 bloques sintetizables, cumpliendo con la regla de 1 reloj maestro de 50 MHz (`clk`), cero latches inferidos y entradas sincronizadas contra metaestabilidad:

| Módulo | Archivo | Descripción |
| :--- | :--- | :--- |
| **`sync2ff`** | `rtl/sync2ff.v` | Sincronizador de 2 flip-flops en cascada para filtrar metaestabilidad en las entradas de los botones físicos. |
| **`debouncer`** | `rtl/debouncer.v` | Filtro antirrebote temporal (20 ms a 50 MHz) con generador de pulso de un ciclo de reloj en flanco positivo. |
| **`tick_gen`** | `rtl/tick_gen.v` | Generador de pulsos Clock Enable de 1 ciclo a 1 Hz exacto (conteo de 50,000,000 ciclos de 50 MHz). |
| **`counter_fsm`** | `rtl/counter_fsm.v` | Máquina de estados finitos que gestiona el valor del contador (0-9), el modo Up/Down, banderas `is_on`, `is_done` y la animación de puntos `dot_step`. |
| **`i2c_master`** | `rtl/i2c_master.v` | Capa física de transmisión I2C maestro en hardware (100 kHz) con control open-drain de SDA y SCL y FSM de 4 fases. |
| **`lcd_pcf8574`** | `rtl/lcd_pcf8574.v` | Controlador del expansor PCF8574 a HD44780 en modo de 4 bits, gestionando los pulsos del pin Enable y luz de fondo (Backlight). |
| **`lcd_controller`** | `rtl/lcd_controller.v` | Secuenciador de inicialización HD44780, multiplexor combinacional de los 32 caracteres y refresco continuo de ambas líneas. |
| **`top`** | `rtl/top.v` | Módulo top-level que interconecta los sincronizadores, antirrebotes, contador, controlador LCD y el circuito Power-On Reset (~21 ms). |

---

## 3. Mapeo Físico de Pines (`constraints/top.cst`)

| Señal | Pin Tang Primer 25K | Tipo I/O | Modo Pull | Función |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | **E2** | LVCMOS33 | NONE | Reloj maestro integrado de 50 MHz |
| `rst_btn` | **H11** | LVCMOS33 | PULL_DOWN | Botón S1 integrado en la placa base (Reset manual) |
| `io_sda` | **K1** | LVCMOS33 | PULL_UP | Línea bidireccional I2C SDA (Datos) |
| `io_scl` | **K2** | LVCMOS33 | PULL_UP | Línea bidireccional I2C SCL (Reloj) |
| `btn_on_off` | **F5** | LVCMOS33 | PULL_DOWN | Pulsador externo 1: ON / OFF (PMOD) |
| `btn_mode` | **G7** | LVCMOS33 | PULL_DOWN | Pulsador externo 2: Modo Ascendente / Descendente (PMOD) |
| `btn_reset` | **H7** | LVCMOS33 | PULL_DOWN | Pulsador externo 3: Reset condicional (PMOD) |

---

## 4. Verificación y Simulación (`tb/tb_top.v`)

El banco de pruebas integral es 100% auto-verificable e implementa 12 casos de prueba formales para validar todo el sistema:

```bash
make check
```

### Resultados de la Verificación Formal:
```text
============================================================
  SIMULACION INTEGRAL: CONTADOR 0-9 CON LCD 1602 (ITLA)
  Estudiante: Urik Valenzuela (2025-0469)
============================================================
[L1] caso 1: PASS - Estado inicial correcto (count=0, UP, ON, !done)
[L1] caso 2: PASS - Conteo ascendente avanza a 3 con pulsos tick_1hz
[L1] caso 3: PASS - Conteo ascendente llega a 9 exitosamente
[L1] caso 4: PASS - Bandera is_done activada y conteo retenido en 9
[L1] caso 5: PASS - Modo cambio a Descendente preservando conteo en 9
[L1] caso 6: PASS - Conteo descendente decrementa correctamente a 7
[L1] caso 7: PASS - Conteo descendente llega a 0 exitosamente
[L1] caso 8: PASS - Bandera is_done activada en modo descendente reteniendo 0
[L1] caso 9: PASS - Reset condicional en modo descendente reinicio a 9
[L1] caso 10: PASS - Reset condicional en modo ascendente reinicio a 0
[L1] caso 11: PASS - Boton ON/OFF pone el sistema en reposo (!is_on)
[L1] caso 12: PASS - Conteo pausado e inmune a ticks mientras esta apagado
============================================================
  RESUMEN: 12 CASOS PASS | 0 CASOS FAIL
  VERIFICACION EXITOSA: TODOS LOS CASOS PASS
============================================================

--- resumen de verificacion ---
casos PASS     : 12
casos FAIL     : 0
avisos de lint : 0
-------------------------------
```

---

## 5. Instrucciones de Uso

- **Verificación estática con Verilator:** `make lint`
- **Simulación con Icarus Verilog:** `make sim`
- **Inspección de formas de onda en GTKWave:** `make wave`
- **Informe consolidado (CI local):** `make check`
- **Generación de Bitstream con Gowin EDA:** `make synth`
- **Carga rápida a la FPGA vía USB:** `make load`
- **Limpieza de temporales:** `make clean`
