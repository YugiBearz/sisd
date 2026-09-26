# Registro de Asistencia por IA — Sistemas Digitales con FPGA (ITLA)

**Estudiante:** Urik Valenzuela  
**Matrícula:** 2025-0469  
**Correo:** 20250469@itla.edu.do  
**Asignatura:** Sistemas Digitales con FPGA (TMC-212) · ITLA  
**Asignación:** #2 — Contador Reversible 0 al 9 con LCD 1602 (I2C)

---

## Bitácora de Consultas y Modificaciones

| Fecha | Herramienta | Prompt / Consulta Realizada | Resumen de la Respuesta y Acción Tomada | Verificación / Validación Humana |
| :--- | :--- | :--- | :--- | :--- |
| 2026-09-25 | Antigravity AI | "Activa el modo de desarrollo para la asignatura... Crear un contador del 0 al 9" | Inicialización del proyecto Asignación #2 en sisd-contador-0-9 y configuración de directrices .clinerules con protocolo Analyze, Ask and Proceed. | Revisión humana del archivo .clinerules en VSCodium y creación de commits incrementales. |
| 2026-09-25 | Antigravity AI | "Implementar módulos de sincronización y filtrado de botones" | Diseño e implementación de `sync2ff.v` (2 flip-flops) y `debouncer.v` (filtro 20 ms + pulso de flanco). | Simulación con testbench dedicado `tb_sync2ff.v` e inspección en GTKWave. |
| 2026-09-25 | Antigravity AI | "Generador de reloj 1 Hz y FSM de conteo 0-9 reversible" | Implementación de `tick_gen.v` (divisor 50 MHz a 1 Hz) y `counter_fsm.v` con modos Up/Down, ON/OFF, Reset condicional y animación de puntos. | Verificación de sintaxis Verilog 2005 y análisis estático con Verilator (0 errores, 0 latches). |
| 2026-09-25 | Antigravity AI | "Capa física I2C y controlador de expansor PCF8574" | Implementación modular espaciada de `i2c_master.v` (FSM 4 fases open-drain) y `lcd_pcf8574.v` (desglose de nibbles y pulsos Enable). | Verificación de temporización I2C a 100 kHz y linting con Verilator. |
| 2026-09-25 | Antigravity AI | "Controlador de pantalla y formateador de texto LCD 1602" | Implementación de `lcd_controller.v`: inicialización HD44780 en 4 bits, generación dinámica de mensajes (Línea 1) y dígito centrado (Línea 2). | Verificación de cobertura en multiplexor combinacional y FSM de refresco. |
| 2026-09-25 | Antigravity AI | "Integración Top-Level, Restricciones CST y Testbench Integral" | Integración en `top.v` con POR (~21 ms), asignación física en `constraints/top.cst` y creación de `tb/tb_top.v` con 12 casos de prueba. | Ejecución de `make check`: 12 casos PASS, 0 fallos, 0 avisos de linting en Verilator e Icarus Verilog. |
| 2026-09-25 | Antigravity AI | "Resolución de advertencias de linter en tb_top.v y configuración VSCodium" | Se agregaron directivas condicionales `VERILATOR` en los bancos de pruebas para resolución jerárquica autónoma sin duplicación en Icarus Verilog, y se configuró `.vscode/settings.json`. | Verificación en VSCodium y CLI: 0 errores, 0 avisos, 12 casos PASS en Asignación #2 y 5 casos PASS en Asignación #1. |
| 2026-09-25 | Antigravity AI | "Actualización de README.md en asignaciones y creación del README.md raíz" | Redacción técnica exhaustiva de los README.md para las Asignaciones #1 y #2, eliminación de referencias a plantillas y creación del README.md principal del repositorio `sisd-2025-0469`. | Revisión de estructura, verificación de comandos `make check` y confirmación de estándares académicos. |

---

> **Nota de Cumplimiento:**  
> Este registro se mantiene de forma transparente de acuerdo a las directrices de integridad académica del curso de Sistemas Digitales con FPGA del ITLA.
