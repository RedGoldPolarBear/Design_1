


# generate the Verilog
run-verilog:
	sbt run

# Test the Chisel design
run-test:
	sbt test

# Configure the Basys3 or NexysA7 board with open source tools

config:
	openocd -f 7series.txt
