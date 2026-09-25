# Sintesis e implementacion con Gowin EDA para la Tang Primer 25K.
#
# Lo invoca `make synth`, desde esta misma carpeta: todas las rutas de aqui
# son relativas al directorio del proyecto.
#
# El dispositivo se comprobo contra la base de datos de la propia instalacion
# de Gowin (IDE/data/device/device_info.csv), no contra la hoja de datos:
#     GW5A-LV25MG121NC1/I0   familia GW5A-25A   encapsulado MBGA121N
#
# La cabecera del .cst de ejemplo de Sipeed dice GW5A-LV25MG121NES. Es otra
# variante del mismo encapsulado; si tu instalacion no reconoce el valor por
# defecto, pasa el tuyo sin tocar este archivo:
#     GW_DEVICE="GW5A-LV25MG121NES" make synth

proc env_o_defecto {nombre defecto} {
    global env
    if {[info exists env($nombre)] && $env($nombre) ne ""} {
        return $env($nombre)
    }
    return $defecto
}

set dispositivo [env_o_defecto GW_DEVICE "GW5A-LV25MG121NC1/I0"]
set familia     [env_o_defecto GW_FAMILY "GW5A-25A"]
set top         [env_o_defecto GW_TOP    "top"]

puts "== dispositivo: $familia $dispositivo, top: $top"

set_device -name $familia $dispositivo

# Fuentes RTL. El testbench no entra: no es sintetizable.
set fuentes [glob -nocomplain src/*.v src/*.sv]
if {[llength $fuentes] == 0} {
    puts "ERROR: no hay fuentes en src/"
    exit 1
}
foreach f $fuentes {
    puts "== add_file $f"
    add_file -type verilog $f
}

# Restricciones de pines. Sin .cst la sintesis corre igual, pero el bitstream
# no sirve para la placa: se avisa en lugar de fingir que todo fue bien.
set restricciones [glob -nocomplain *.cst src/*.cst]
if {[llength $restricciones] == 0} {
    puts "AVISO: no hay .cst; el resultado no es programable en la placa"
} else {
    foreach c $restricciones {
        puts "== add_file $c"
        add_file -type cst $c
    }
}

# Restricciones de temporizacion. El hola mundo es combinacional y no trae
# .sdc: no hay reloj que restringir, asi que el aviso de abajo es lo esperado.
# En cuanto anadas un reloj, anade tambien su create_clock o no habra analisis
# de temporizacion ni Fmax en el informe.
set temporizacion [glob -nocomplain *.sdc src/*.sdc]
if {[llength $temporizacion] == 0} {
    puts "AVISO: no hay .sdc; no habra analisis de temporizacion ni Fmax"
} else {
    foreach s $temporizacion {
        puts "== add_file $s"
        add_file -type sdc $s
    }
}

# El reloj de la placa entra por E2, que en el GW5A-25A es tambien SSPI_WPN,
# un pin de doble proposito. Sin liberarlo, el place & route aborta con
#     ERROR (PR2017): 'clk' cannot be placed ... dedicated pin (CPU/SSPI)
# y no genera bitstream. El ejemplo oficial de Sipeed no lo declara porque su
# .gprj ya lleva estas opciones; un flujo por .tcl tiene que ponerlas.
#
# El hola mundo no usa E2 y funcionaria sin estas dos lineas. Se dejan puestas
# porque este proyecto es el punto de partida del resto: el dia que anadas el
# reloj, el fallo aparece en place & route con un mensaje que no menciona la
# causa, y se pierde media tarde.
set_option -use_sspi_as_gpio 1
set_option -use_cpu_as_gpio 1

set_option -top_module $top
set_option -output_base_name $top
set_option -verilog_std v2001

run all
