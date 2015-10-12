set BLUESPECDIR $env(BLUESPECDIR)

create_project vc709 vc709 -part xc7vx690tffg1761-2
set_property board_part xilinx.com:vc709:part0:1.6 [current_project]
add_files verilog
add_files -norecurse ../src/ip/vc709/pcie3_7x_0/pcie3_7x_0.xci
add_files -fileset constrs_1 -norecurse ../src/connectal/constraints/vc709.xdc
remove_files "verilog/mkMMURequestInverter.v verilog/mkMMURequestInverterV.v verilog/mkMemServerIndicationInverter.v verilog/mkMemServerIndicationInverterV.v verilog/mkMemServerRequestInverter.v verilog/mkMemServerRequestInverterV.v verilog/mkDmaRequestInverter.v verilog/mkDmaRequestInverterV.v verilog/mkMMUIndicationInverter.v verilog/mkMMUIndicationInverterV.v verilog/mkDmaIndicationInverter.v verilog/mkDmaIndicationInverterV.v verilog/mkEHR2BSV.v"
add_files -norecurse ../src/connectal/verilog/PositiveReset.v
add_files -norecurse "$BLUESPECDIR/Verilog.Vivado/BRAM2.v $BLUESPECDIR/Verilog.Vivado/SizedFIFO.v $BLUESPECDIR/Verilog/FIFO2.v"
update_compile_order -fileset sources_1
add_files -norecurse "$BLUESPECDIR/Verilog/SyncFIFO1.v $BLUESPECDIR/Verilog/FIFO1.v"
add_files -norecurse $BLUESPECDIR/Verilog.Vivado/RegFile.v
update_compile_order -fileset sources_1
add_files -norecurse "$BLUESPECDIR/Verilog/ResetInverter.v $BLUESPECDIR/Verilog/SyncResetA.v"
add_files -norecurse $BLUESPECDIR/Verilog/Counter.v

remove_files "verilog/mkDmaIndicationWrapperMemPortalPipes.v verilog/mkDmaRequestWrapperMemPortalPipes.v verilog/mkMMUIndicationWrapperMemPortalPipes.v verilog/mkMemServerIndicationWrapperMemPortalPipes.v verilog/mkDmaIndicationProxySynth.v verilog/mkDmaRequestProxySynth.v verilog/mkMMURequestProxySynth.v verilog/mkMemServerRequestProxySynth.v verilog/mkPcieGearbox.v"
remove_files "verilog/mkMemServerIndicationInput.v verilog/mkMMUIndicationInput.v verilog/mkDmaIndicationInput.v verilog/mkDmaRequestOutput.v verilog/mkMMURequestOutput.v verilog/mkMemServerRequestOutput.v"
remove_files "verilog/mkDmaRequestOutputPipes.v verilog/mkMMURequestOutputPipes.v verilog/mkMemServerRequestOutputPipes.v"
remove_files "verilog/vpi_wrapper_can_get_tlp.h verilog/vpi_wrapper_can_put_tlp.h verilog/vpi_wrapper_get_tlp.h verilog/vpi_wrapper_put_tlp.h"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_runs synth_1 -jobs 12
wait_on_run synth_1
launch_runs impl_1 -jobs 12
wait_on_run impl_1
open_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1
