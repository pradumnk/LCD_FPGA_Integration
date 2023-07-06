transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/clkdiv.v}
vlog -vlog01compat -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/spi.v}
vlog -vlog01compat -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/db {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/db/pll_altpll.v}
vlog -sv -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/ball_sv.sv}
vlog -sv -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/tft_sv.sv}
vlog -sv -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/top_module_sv.sv}

vlog -vlog01compat -work work +incdir+C:/Users/prady/OneDrive/Documents/Quartus/tft_integration {C:/Users/prady/OneDrive/Documents/Quartus/tft_integration/tb_top_module.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_top_module

add wave *
view structure
view signals
run -all
