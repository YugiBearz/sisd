# ============================================================================
#  Script de Sintesis Headless Gowin EDA (build.tcl)
#  Dispositivo: GW5A-LV25MG121NC1/I0 (Tang Primer 25K)
#  Autor: Urik Valenzuela · Matricula: 2025-0469 · 20250469@itla.edu.do
# ============================================================================

set device  "GW5A-LV25MG121NC1/I0"
set family  "GW5A-25A"
set top_mod "top"

puts "== Dispositivo: $family $device, Top: $top_mod =="
set_device -name $family $device

# Agregar fuentes Verilog
foreach f [glob -nocomplain rtl/*.v src/*.v] {
    puts "== Agregando fuente: $f =="
    add_file $f
}

# Agregar archivo de restricciones fisicas
if {[file exists constraints/top.cst]} {
    puts "== Agregando restricciones: constraints/top.cst =="
    add_file constraints/top.cst
} elseif {[file exists top.cst]} {
    puts "== Agregando restricciones: top.cst =="
    add_file top.cst
}

# Agregar restricciones de temporizacion si existen
if {[file exists constraints/top.sdc]} {
    puts "== Agregando timing constraints: constraints/top.sdc =="
    add_file constraints/top.sdc
} elseif {[file exists top.sdc]} {
    puts "== Agregando timing constraints: top.sdc =="
    add_file top.sdc
} else {
    puts "AVISO: no hay archivo .sdc detectado."
}

# Liberar pines de doble proposito para utilizacion como GPIO
set_option -use_sspi_as_gpio 1
set_option -use_cpu_as_gpio  1

# Sintesis, Place & Route y Generacion de Bitstream
set_option -top_module $top_mod
run syn
run pnr

puts "== Proceso de compilacion completado con exito =="

