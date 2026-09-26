# Repositorio de Asignaciones — Sistemas Digitales con FPGA

**Instituto Tecnológico de Las Américas (ITLA)**  
**Asignatura:** Sistemas Digitales con FPGA (TMC-212)  
**Docente:** Prof. Wilkins Gabriel Cedano Del Rosario  
**Estudiante:** Urik Valenzuela  
**Matrícula:** `2025-0469`  
**Correo Institucional:** `20250469@itla.edu.do`  
**Hardware de Laboratorio:** Placa de desarrollo Sipeed Tang Primer 25K (Gowin GW5A-LV25MG121NC1/I0)

---

## 1. Estructura del Repositorio

Este repositorio contiene las asignaciones prácticas y proyectos desarrollados durante el curso, diseñados bajo el estándar IEEE 1364-2005 (Verilog 2005) sintetizable y validados en hardware físico:

```text
sisd-2025-0469/
├── README.md                          # Documentación general del repositorio
├── .vscode/                           # Configuración del entorno VSCodium / VS Code
│   └── settings.json                  # Reglas de linting Verilator y rutas de inclusión
├── sisd-holaMundo/                    # Asignación #1: Validación de Toolchain y Hola Mundo
│   ├── README.md                      # Documentación técnica de la asignación #1
│   ├── Makefile                       # Flujo automatizado (lint, sim, wave, synth, load)
│   ├── src/                           # Código RTL sintetizable (top.v)
│   ├── tb/                            # Banco de pruebas (tb_top.v)
│   ├── build.tcl                      # Script de síntesis Gowin EDA
│   └── top.cst                        # Restricciones de pines (Tang Primer 25K)
└── sisd-contador-0-9/                 # Asignación #2: Contador Reversible 0-9 con LCD 1602
    ├── README.md                      # Documentación técnica de la asignación #2
    ├── AI_LOG.md                      # Bitácora transparente de asistencia por IA
    ├── Makefile                       # Flujo automatizado de compilación y pruebas
    ├── rtl/                           # 8 módulos RTL modulares y sincronizados
    │   ├── top.v                      # Top-level con circuito Power-On Reset
    │   ├── counter_fsm.v              # FSM de conteo 0-9, Up/Down, ON/OFF, Reset condicional
    │   ├── tick_gen.v                 # Generador de pulsos enable a 1 Hz exacto (50 MHz)
    │   ├── debouncer.v                # Filtro antirrebote de 20 ms con pulso de flanco
    │   ├── sync2ff.v                  # Sincronizador de 2 etapas contra metaestabilidad
    │   ├── lcd_controller.v           # Inicialización HD44780 y generador de mensajes dinámicos
    │   ├── lcd_pcf8574.v              # Puente 4-bit para expansor PCF8574
    │   └── i2c_master.v               # Maestro I2C físico a 100 kHz open-drain
    ├── tb/                            # Banco de pruebas integral (tb_top.v)
    ├── constraints/                   # Restricciones físicas de pines
    │   └── top.cst                    # Mapeo físico de pines y puertos PMOD
    └── docs/                          # Recursos adicionales de diseño
```

---

## 2. Resumen de Asignaciones

### Asignación #1: Montaje de Toolchain y Hola Mundo (`sisd-holaMundo`)
* **Objetivo:** Puesta a punto y verificación integral del flujo de desarrollo open-source y propietario para la FPGA Sipeed Tang Primer 25K.
* **Descripción:** Conexión combinacional entre un pulsador activo en bajo y un diodo LED activo en alto, validando la cadena completa de linting estático, simulación funcional, síntesis PnR y programación SRAM.
* **Cobertura de Pruebas:** 5 casos PASS comprobando todas las polaridades y rebotes lógicos.

### Asignación #2: Contador Reversible 0 al 9 con LCD 1602 I2C (`sisd-contador-0-9`)
* **Objetivo:** Diseño síncrono de un sistema de control digital embebido con periféricos en bus serie I2C y entradas de usuario.
* **Características Clave:**
  - Reloj síncrono único a 50 MHz (`clk`), sin relojes derivados y libre de latches inferidos.
  - Sincronización contra metaestabilidad (2 FF) y filtrado antirrebote de 20 ms en todos los pulsadores.
  - Generador de pulsos *Clock Enable* a 1 Hz exacto.
  - FSM de conteo con avance paso a paso, modos Ascendente/Descendente preservando el dígito, y Reset condicional (0 en Up, 9 en Down).
  - Detección de fin de conteo (`is_done`) con detención automática y mensaje `"Count Completed!"`.
  - Animación de puntos suspensivos a 1 Hz (`.`, `..`, `...`).
  - Interfaz de capa física I2C maestro a 100 kHz con salidas open-drain hacia el expansor PCF8574 (`0x27`).
* **Cobertura de Pruebas:** 12 casos de verificación integral PASS (100% de cobertura funcional).

---

## 3. Requisitos del Entorno de Desarrollo

Para compilar, simular y programar los diseños en hardware se requiere:

* **Herramientas de Simulación y Linting:**
  - `verilator` (v5.020 o superior): Chequeo estático de sintaxis y reglas de diseño.
  - `iverilog` (v12 o superior con soporte IEEE 1364-2005 / -g2012): Compilador de simulación.
  - `vvp`: Motor de ejecución en tiempo de simulación.
  - `gtkwave`: Visualizador de ondas en formato VCD.
* **Herramientas de Síntesis y Programación:**
  - `Gowin EDA` (`gw_sh`): Herramienta oficial para síntesis lógica y Place & Route de Gowin.
  - `openFPGALoader`: Utilidad para la descarga y programación del bitstream vía JTAG/USB.

---

## 4. Guía de Ejecución Rápida

Cada carpeta de asignación incluye un `Makefile` autosuficiente. Para ejecutar las validaciones:

### Asignación #1 (`sisd-holaMundo`)
```bash
cd sisd-holaMundo
make lint    # Análisis estático de sintaxis con Verilator
make sim     # Simulación con Icarus Verilog
make check   # Informe consolidado de verificación (5/5 PASS)
make synth   # Síntesis de bitstream con Gowin EDA
make load    # Carga temporal a la SRAM de la Tang Primer 25K
```

### Asignación #2 (`sisd-contador-0-9`)
```bash
cd sisd-contador-0-9
make lint    # Verificación de sintaxis RTL con Verilator (0 avisos)
make sim     # Simulación del testbench integral de 12 casos
make wave    # Inspección de señales I2C y FSM en GTKWave
make check   # Reporte formal de verificación (12/12 PASS)
make synth   # Generación del bitstream (.fs) con Gowin EDA
make load    # Programación a la SRAM de la FPGA
```

---

## 5. Directrices de Calidad e Integridad Académica

* **Estándar de Código:** Todo el código RTL cumple con Verilog 2005 sintetizable, libre de metaestabilidad, con resets síncronos y asignaciones no bloqueantes (`<=`) en bloques secuenciales.
* **Transparencia en el Uso de IA:** En cumplimiento con las normas del curso y del ITLA, la asignación #2 cuenta con un archivo [`sisd-contador-0-9/AI_LOG.md`](file:///run/media/urikv/WD_BLACK/ITLA/School/C6/Sistemas%20Digitales/Homework/sisd-2025-0469/sisd-contador-0-9/AI_LOG.md) que documenta cada consulta realizada, la asistencia recibida y la validación técnica humana efectuada.
