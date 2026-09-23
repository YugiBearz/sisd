# Plantilla Base para Proyectos FPGA — ITLA
**Convención Oficial del Curso (Sección 0.2):** `rtl/`, `tb/`, `sim/`, `constraints/`, `docs/`, `build/`  
**Placa:** Sipeed Tang Primer 25K (Gowin GW5A-LV25MG121NC1/I0)  
**Estudiante:** Urik Valenzuela (`2025-0469`) · `20250469@itla.edu.do`  

---

## Estructura del Proyecto

```text
template-fpga/
├── rtl/            # Código Verilog sintetizable (.v)
│   └── top.v       # Módulo top-level con encabezado de estudiante
├── tb/             # Testbenches (no sintetizables)
│   └── tb_top.v    # Testbench auto-verificable
├── sim/            # Salidas de simulación (.vcd, .lxt)
├── constraints/    # Archivo de pines
│   └── top.cst     # IO_LOC / IO_PORT para Tang Primer 25K
├── docs/           # Notas, esquemáticos, datasheets
├── build/          # Archivos generados por el IDE (bitstream, reportes)
│   └── impl/
├── .vscode/        # Configuración y tareas para VSCodium
│   └── tasks.json
├── Makefile        # Automatización (lint, sim, wave, check, synth, load, flash)
├── build.tcl       # Script de síntesis headless Gowin EDA
├── AI_LOG.md       # Bitácora de transparencia de IA (exigida por ITLA)
└── .gitignore      # Ignora build/, impl/, *.vcd
```

---

## Cómo usar esta plantilla para una nueva tarea o Code Challenge

1. **Duplica esta carpeta:**
   ```bash
   cd "/run/media/urikv/WD_BLACK/ITLA/School/C6/Sistemas Digitales/Homework"
   cp -r template-fpga CC1-NuevaTarea
   ```

2. **Abre la nueva carpeta en VSCodium:**
   ```bash
   codium CC1-NuevaTarea
   ```

3. **Flujo de desarrollo:**
   * **`Ctrl + Shift + B`** o `make check`: Verificación instantánea con Verilator + Icarus.
   * `make wave`: Inspeccionar formas de onda en GTKWave (`sim/dump.vcd`).
   * `make synth`: Generar bitstream en Gowin EDA.
   * `make load`: Cargar a la FPGA por USB.
   * `make clean`: Limpiar temporales.
