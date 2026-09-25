# ============================================================================
#  Makefile — Plantilla Base para Sistemas Digitales con FPGA (ITLA)
#  Tang Primer 25K (GW5A-25 / GW5A-LV25MG121NC1/I0)
#  Convención oficial del curso: rtl/, tb/, sim/, constraints/, docs/, build/
#  Autor: Urik Valenzuela · Matricula: 2025-0469 · 20250469@itla.edu.do
# ============================================================================

TOP       ?= top
SRC       := $(wildcard rtl/*.v src/*.v)
TB        ?= tb/tb_$(TOP).v
BUILD     := build
SIM_DIR   := sim
BOARD     ?= tangprimer25k
BITSTREAM ?= impl/pnr/$(TOP).fs

IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
GTKWAVE   ?= gtkwave

.PHONY: help lint sim wave check synth load flash clean

help:
	@echo "Objetivos disponibles en este proyecto:"
	@echo "  make lint   - Verilator: chequeo estatico de sintaxis (-Wall --lint-only)"
	@echo "  make sim    - Icarus Verilog: compila y ejecuta el testbench"
	@echo "  make wave   - GTKWave: abre las formas de onda (sim/dump.vcd)"
	@echo "  make check  - lint + sim: informe consolidado (como en el CI)"
	@echo "  make synth  - Gowin EDA: genera el bitstream (impl/pnr/$(TOP).fs)"
	@echo "  make load   - openFPGALoader: carga rapida a la SRAM de la placa"
	@echo "  make flash  - openFPGALoader: grabacion permanente en la memoria Flash"
	@echo "  make clean  - Limpia las carpetas temporales build/, impl/ y sim/*.vcd"

$(BUILD):
	@mkdir -p $(BUILD) $(SIM_DIR)

lint:
	@test -n "$(SRC)" || { echo "ERROR: No hay archivos Verilog en rtl/ o src/"; exit 1; }
	$(VERILATOR) --lint-only -Wall --top-module $(TOP) $(SRC)

sim: | $(BUILD)
	$(IVERILOG) -g2012 -o $(BUILD)/sim.out $(SRC) $(TB)
	$(VVP) $(BUILD)/sim.out

wave: sim
	$(GTKWAVE) $(SIM_DIR)/dump.vcd &

check: | $(BUILD)
	-$(VERILATOR) --lint-only -Wall --top-module $(TOP) $(SRC) 2> $(BUILD)/lint.log
	-$(IVERILOG) -g2012 -o $(BUILD)/sim.out $(SRC) $(TB) 2>&1 | tee $(BUILD)/sim.log
	-$(VVP) $(BUILD)/sim.out 2>&1 | tee -a $(BUILD)/sim.log
	@echo ""
	@echo "--- resumen de verificacion ---"
	@echo "casos PASS     : $$(grep -c ': PASS' $(BUILD)/sim.log || true)"
	@echo "casos FAIL     : $$(grep -c ': FAIL' $(BUILD)/sim.log || true)"
	@echo "avisos de lint : $$(grep -cE '^%(Warning|Error)' $(BUILD)/lint.log || true)"
	@echo "-------------------------------"

# Resolucion de bibliotecas Qt integradas de Gowin para evitar colisiones
GW_LIB = $$(dirname "$$(readlink -f "$$(command -v gw_sh)")")/../lib

synth:
	@command -v gw_sh >/dev/null || { echo "ERROR: gw_sh no esta en el PATH (Gowin EDA)"; exit 1; }
	LD_LIBRARY_PATH="$(GW_LIB):$$LD_LIBRARY_PATH" gw_sh build.tcl

load:
	openFPGALoader -b $(BOARD) $(BITSTREAM)

flash:
	openFPGALoader -b $(BOARD) -f $(BITSTREAM)

clean:
	rm -rf $(BUILD) impl $(SIM_DIR)/*.vcd $(SIM_DIR)/*.vvp $(SIM_DIR)/*.out
