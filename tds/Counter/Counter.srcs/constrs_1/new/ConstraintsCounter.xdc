#horloge sur un bouton
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CLK]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports CLK]

# signaux binaires
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports EN]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports RST]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports LOAD]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports SENS]

# Din
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {Din[0]}]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {Din[1]}]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {Din[2]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports {Din[3]}]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {Din[4]}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {Din[5]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {Din[6]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {Din[7]}]

# Dout
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {Dout[0]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {Dout[1]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {Dout[2]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {Dout[3]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {Dout[4]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {Dout[5]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {Dout[6]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {Dout[7]}]