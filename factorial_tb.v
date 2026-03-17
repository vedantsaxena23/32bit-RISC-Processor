module mp_risc_tb_2;
reg clk1, clk2;
integer k;
mp_risc mips (clk1, clk2);
// Generating two-phase clock
initial
begin
clk1 = 0; clk2 = 0;
repeat (50)
begin
#5 clk1 = 1; #5 clk1 = 0; // Positive-edge clock1, negative-edge clock1
#5 clk2 = 1; #5 clk2 = 0; // Positive-edge clock2, negative-edge clock2
end
end
// Initializing the MIPS processor memory and registers
initial
begin
for (k=0; k<31; k=k+1)
mips.Reg[k] = k; // Assigning values to general-purpose registers
mips.Mem[200] = 7; // Memory location 200 initialized with 7 (factorial input)
mips.Mem[0] = 32'h00c81810; // Memory location 0 initialized with instruction (LW R3,00C8)
mips.Mem[1] = 32'h00011001; // Memory location 1 initialized with instruction (ADDI R2,R0,1)
mips.Mem[2] = 32'h000739c5; // Memory location 2 initialized with instruction (0R R7,R7,R7)—DUMMY VARIABLE
mips.Mem[3] = 32'h0002188b; // Memory location 3 initialized with instruction (LOOP: MUL R2,R2,R3)
mips.Mem[4] = 32'h000118c3; // Memory location 4 initialized with instruction (SUBI R3,R3,1)
mips.Mem[5] = 32'h000739c5; // Memory location 5 initialized with instruction (0R R7,R7,R7) —DUMMY VARIABLE
mips.Mem[6] = 32'hfffc00d4; // Memory location 6 initialized with instruction (BNEQZ R3,LOOP, -4 OFFSET)
mips.Mem[7] = 32'h00c91011; // Memory location 7 initialized with instruction (SW R2,00C9)
mips.Mem[8] = 32'h0000003f; // Memory location 8 initialized with instruction (HALT)
mips.PC = 0; // Initialize program counter (PC) to 0
mips.HALTED = 0; // Initialize HALTED signal to 0 (not halted)
mips.TAKEN_BRANCH = 0; // Initialize TAKEN_BRANCH signal to 0
#2000 $display ("Mem[200] = %2d, Mem[201] = %6d", mips.Mem[200], mips.Mem[201]); // Display initial memory values
end
// VCD dump and monitor
initial
begin
$dumpfile ("mips.vcd"); // Define VCD dumpfile
$dumpvars (0, mp_risc_tb_2); // Dump variables for VCD
$monitor ("R2: %4d", mips.Reg[2]); // Monitor register R2
#3000 $finish; // Finish the simulation after some delay
end
endmodule
ASSEMBLY LANGUAGE PROGRAM:
LW R3,00C8;
ADDI R2,R0,1;
LOOP: MUL R2,R2,R3;
SUBI R3,R3,1;
BNEQZ R3,LOOP;
SW R2,00C9;
HLT