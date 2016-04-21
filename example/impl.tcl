set BLUESPECDIR $env(BLUESPECDIR)
set PREFIX "/usr/local"
if [info exists env(PREFIX)] {
    set PREFIX "$env(PREFIX)"
}
set DMAC_DIR "$PREFIX/share/dmac"
if [info exists env(DMAC_DIR)] {
    set DMAC_DIR $env(DMAC_DIR)
} elseif [info exists env(DESTDIR)] {
    set DMAC_DIR "$env(DESTDIR)$PREFIX/share/dmac"
}

set board $env(BOARD)
puts "BOARD $board"
if {$board == {vc709} || $board == {nfsume}} {
    set partname {xc7vx690tffg1761-2}
    set boardpart {xilinx.com:vc709:part0:1.6}
} else {
    set partname {xc7k325tffg900-2}
    set boardpart {xilinx.com:kc705:part0:1.0}
}
create_project -force $board $board -part $partname
set_property board_part $boardpart [current_project]
add_files verilog
if {$board == {vc709} || $board == {nfsume}} {
    add_files -norecurse ./ip/$board/pcie3_7x_0/pcie3_7x_0.xci
} else {
    add_files -norecurse ./ip/$board/pcie2_7x_0/pcie2_7x_0.xci
}
add_files -fileset constrs_1 -norecurse $DMAC_DIR/connectal/constraints/$board.xdc
add_files -norecurse $DMAC_DIR/connectal/verilog/PositiveReset.v
add_files -norecurse "$BLUESPECDIR/Verilog.Vivado/BRAM2.v $BLUESPECDIR/Verilog.Vivado/SizedFIFO.v $BLUESPECDIR/Verilog/FIFO2.v"
add_files -norecurse "$BLUESPECDIR/Verilog/SyncFIFO1.v $BLUESPECDIR/Verilog/FIFO1.v"
add_files -norecurse $BLUESPECDIR/Verilog.Vivado/RegFile.v
add_files -norecurse "$BLUESPECDIR/Verilog/ResetInverter.v $BLUESPECDIR/Verilog/SyncResetA.v"
add_files -norecurse $BLUESPECDIR/Verilog/Counter.v
remove_files "verilog/vpi_wrapper_can_get_tlp.h verilog/vpi_wrapper_can_put_tlp.h verilog/vpi_wrapper_get_tlp.h verilog/vpi_wrapper_put_tlp.h"
set_property source_mgmt_mode None [current_project]
set_property top mkExample [current_fileset]
# Re-enabling previously disabled source management mode.
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_runs synth_1 -jobs 12
wait_on_run synth_1
launch_runs impl_1 -jobs 12
wait_on_run impl_1
open_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1
