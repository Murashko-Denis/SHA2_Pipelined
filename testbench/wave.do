onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /tb_sha2_pipelined/cnt
add wave -noupdate /tb_sha2_pipelined/strobe
add wave -noupdate /tb_sha2_pipelined/clk
add wave -noupdate /tb_sha2_pipelined/valid
add wave -noupdate -radix hexadecimal /tb_sha2_pipelined/hash_out
add wave -noupdate -radix hexadecimal /tb_sha2_pipelined/message_abc
add wave -noupdate -radix hexadecimal /tb_sha2_pipelined/message_denis
add wave -noupdate -radix hexadecimal /tb_sha2_pipelined/message_null
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {659 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {206 ps} {726 ps}
