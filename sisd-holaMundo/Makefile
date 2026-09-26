# Makefile del hola mundo - Tang Primer 25K (GW5A-25)
#
# Version autocontenida: se invoca desde esta misma carpeta.
#
#     make lint     make sim     make wave     make check
#
# En el repo del curso el flujo es el mismo, pero con el Makefile comun y la
# ruta del proyecto como variable:
#
#     make -C 00_infra lint SRC_DIR=01_unidades/u03_fsm/lab
#
# Los nombres de los objetivos son los mismos a proposito: lo que aprendas
# aqui sirve igual cuando trabajes dentro del repo del curso.
#
# Regla de oro: verifica con Verilator + Icarus ANTES de abrir Gowin EDA. El
# ciclo de iteracion pasa de minutos a segundos.

TOP       ?= top
SRC       := $(wildcard src/*.v)
TB        ?= tb/tb_$(TOP).v
BUILD     := build

IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
GTKWAVE   ?= gtkwave

.PHONY: help lint sim wave check synth load flash clean

help:
	@echo "Objetivos disponibles:"
	@echo "  lint   - Verilator --lint-only -Wall  (latches, anchos, sensitivity lists)"
	@echo "  sim    - compila y ejecuta el testbench con Icarus"
	@echo "  wave   - abre el VCD en GTKWave"
	@echo "  check  - lint + sim y resume los casos, como hace el CI"
	@echo "  synth  - sintetiza con Gowin EDA (requiere gw_sh en el PATH)"
	@echo "  clean  - borra $(BUILD)/"
	@echo ""
	@echo "Variables de synth:  GW_DEVICE, GW_FAMILY, GW_TOP"

$(BUILD):
	@mkdir -p $(BUILD)

lint:
	@test -n "$(SRC)" || { echo "No hay fuentes en src/"; exit 1; }
	$(VERILATOR) --lint-only -Wall --top-module $(TOP) $(SRC)

sim: | $(BUILD)
	$(IVERILOG) -g2012 -o $(BUILD)/sim.out $(SRC) $(TB)
	cd $(BUILD) && $(VVP) sim.out

wave: sim
	$(GTKWAVE) $(BUILD)/dump.vcd &

# El lint no aborta la simulacion: se quiere el reporte completo aunque haya
# hallazgos, para que el resumen los liste todos. Es lo mismo que hace el CI
# del curso, que guarda lint.log y sim.log y los consolida despues.
check: | $(BUILD)
	-$(VERILATOR) --lint-only -Wall --top-module $(TOP) $(SRC) 2> $(BUILD)/lint.log
	-$(IVERILOG) -g2012 -o $(BUILD)/sim.out $(SRC) $(TB) 2>&1 | tee $(BUILD)/sim.log
	-cd $(BUILD) && $(VVP) sim.out 2>&1 | tee -a sim.log
	@echo ""
	@echo "--- resumen ---"
	@echo "casos PASS     : $$(grep -c ': PASS' $(BUILD)/sim.log || true)"
	@echo "casos FAIL     : $$(grep -c ': FAIL' $(BUILD)/sim.log || true)"
	@echo "avisos de lint : $$(grep -cE '^%(Warning|Error)' $(BUILD)/lint.log || true)"
	@echo ""
	@echo "Dentro del repo del curso, 'make -C 00_infra check' ademas escribe"
	@echo "resultados.json, que es el contrato que lee el tablero de notas."

# Gowin EDA trae su propio Qt en IDE/lib. Si el enlazador mezcla ese con el
# del sistema, gw_sh aborta con «Cannot mix incompatible Qt library» y vuelca
# el core antes de leer una sola linea del .tcl. Anteponer su lib obliga a que
# todo Qt salga de la misma instalacion. Se resuelve en tiempo de ejecucion
# para no depender de donde tenga cada quien instalado el IDE.
GW_LIB = $$(dirname "$$(readlink -f "$$(command -v gw_sh)")")/../lib

# Verifica con lint y simulacion ANTES de llegar aqui: una sintesis tarda
# minutos y te dice lo mismo sobre si la logica es correcta.
synth:
	@command -v gw_sh >/dev/null || { echo "gw_sh no esta en el PATH (Gowin EDA)"; exit 1; }
	LD_LIBRARY_PATH="$(GW_LIB):$$LD_LIBRARY_PATH" gw_sh build.tcl

BOARD     ?= tangprimer25k
BITSTREAM ?= $(or $(firstword $(wildcard impl/pnr/project.fs impl/pnr/$(TOP).fs impl/pnr/*.fs)),impl/pnr/project.fs)

load:
	openFPGALoader -b $(BOARD) $(BITSTREAM)

flash:
	openFPGALoader -b $(BOARD) -f $(BITSTREAM)

clean:
	rm -rf $(BUILD) impl
