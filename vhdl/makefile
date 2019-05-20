FLAGS =
FLAG_FILE = head/flag.txt alu/alu_util/flag.txt util/fifo/flag.txt alu/alu_fifo/flag.txt alu/alu_rom/flag.txt alu/alu_calc/flag.txt alu/alu_dot_mul/flag.txt alu/alu_conv/flag.txt alu/alu_pool/flag.txt
GHW_FILE = util/fifo/fifo.ghw alu/alu_fifo/alu_fifo.ghw alu/alu_rom/alu_rom.ghw alu/alu_dot_mul/alu_dot_mul.ghw alu/alu/conv/alu_conv.ghw alu/alu_pool/alu_pool.ghw
WORKOBJ = work-obj93.cf

.PHONY: all clean

all: $(GHW_FILE)

clean:
	$(RM) $(FLAG_FILE)
	$(RM) $(GHW_FILE)
	$(RM) *.cf

head/flag.txt: $(wildcard head/*.vhd)
	ghdl -a $(FLAGS) head/head.vhd
	ghdl -a $(FLAGS) head/head_const.vhd
	echo > $@

alu/alu_util/flag.txt: $(wildcard alu/alu_util/*.vhd)
	ghdl -a $(FLAGS) alu/alu_util/alu_flag.vhd
	echo > $@

util/fifo/flag.txt: $(wildcard util/fifo/*.vhd)
	ghdl -a $(FLAGS) util/fifo/fifo.vhd
	ghdl -a $(FLAGS) util/fifo/fifo_tb.vhd
	ghdl -e $(FLAGS) fifo_tb
	echo > $@

alu/alu_fifo/flag.txt: $(wildcard alu/alu_fifo/*.vhd)
	ghdl -a $(FLAGS) alu/alu_fifo/alu_fifo.vhd
	ghdl -a $(FLAGS) alu/alu_fifo/alu_fifo_tb.vhd
	ghdl -e $(FLAGS) alu_fifo_tb
	echo > $@

alu/alu_rom/flag.txt: $(wildcard alu/alu_rom/*.vhd)
	ghdl -a $(FLAGS) alu/alu_rom/alu_rom.vhd
	ghdl -a $(FLAGS) alu/alu_rom/alu_rom_tb.vhd
	ghdl -e $(FLAGS) alu_rom_tb
	echo > $@

alu/alu_calc/flag.txt: $(wildcard alu/alu_calc/*.vhd)
	ghdl -a $(FLAGS) alu/alu_calc/alu_mul.vhd
	ghdl -a $(FLAGS) alu/alu_calc/alu_div.vhd
	ghdl -a $(FLAGS) alu/alu_calc/alu_sigmoid.vhd
	echo > $@

alu/alu_dot_mul/flag.txt: $(wildcard alu/alu_dot_mul/*.vhd)
	ghdl -a $(FLAGS) alu/alu_dot_mul/alu_dot_mul.vhd
	ghdl -a $(FLAGS) alu/alu_dot_mul/alu_dot_mul_tb.vhd
	ghdl -e $(FLAGS) alu_dot_mul_tb
	echo > $@

alu/alu_conv/flag.txt: $(wildcard alu/alu_conv/*.vhd)
	ghdl -a $(FLAGS) alu/alu_conv/alu_conv_control.vhd
	ghdl -a $(FLAGS) alu/alu_conv/alu_conv_calc.vhd
	ghdl -a $(FLAGS) alu/alu_conv/alu_conv.vhd
	ghdl -a $(FLAGS) alu/alu_conv/alu_conv_tb.vhd
	ghdl -e $(FLAGS) alu_conv_tb
	echo > $@

alu/alu_pool/flag.txt: $(wildcard alu/alu_pool/*.vhd)
	ghdl -a $(FLAGS) alu/alu_pool/alu_pool_h.vhd
	ghdl -a $(FLAGS) alu/alu_pool/alu_pool_v.vhd
	ghdl -a $(FLAGS) alu/alu_pool/alu_pool.vhd
	ghdl -a $(FLAGS) alu/alu_pool/alu_pool_tb.vhd
	ghdl -e $(FLAGS) alu_pool_tb
	echo > $@

util/fifo/fifo.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) fifo_tb --stop-time=40us --wave=$@

alu/alu_fifo/alu_fifo.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) alu_fifo_tb --stop-time=40us --wave=$@

alu/alu_rom/alu_rom.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) alu_rom_tb --stop-time=40us --wave=$@

alu/alu_dot_mul/alu_dot_mul.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) alu_dot_mul_tb --stop-time=100us --wave=$@

alu/alu_conv/alu_conv.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) alu_conv_tb --stop-time=200us --wave=$@

alu/alu_pool/alu_pool.ghw: $(FLAG_FILE)
	ghdl -r $(FLAGS) alu_pool_tb --stop-time=100us --wave=$@

