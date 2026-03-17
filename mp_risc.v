module mp_risc(clk1, clk2);

  input clk1, clk2; // Two-phase clock

  reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
  reg EX_MEM_cond,EX_MEM_cond2;
  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
  reg [31:0] Reg [0:31]; // Register bank (32 x 32)
  reg [31:0] Mem [0:1023]; // 1024 x 32 memory

  parameter ADD=6'b000000, ADDI=6'b000001, SUB=6'b000010, SUBI=6'b000011, AND=6'b000100, OR=6'b000101,
            XOR=6'b000110, ANDI=6'b000111, ORI=6'b001000, SLT=6'b001001, SLTI=6'b001010, MUL=6'b001011,
            SLL=6'b001100, SLLI=6'b001101, SRL=6'b001110, SRLI=6'b001111, LW=6'b010000, SW=6'b010001,
            SEQ=6'b010010, SNEQ=6'b010011, BNEQZ=6'b010100, BEQZ=6'b010101, BEQ=6'b010110, BNEQ=6'b010111,
            XORI=6'b011000, JMP=6'b011001, HLT=6'b111111;
           

  parameter RR_ALU=4'b0000, RM_ALU=4'b0001, LOAD=4'b0010, STORE=4'b0011,
            BRANCH=4'b0100, BRANCH2=4'b0101, BRANCH3=4'b0110, HALT=4'b0111;
  reg HALTED;
  // Set after HLT instruction is completed (in WB stage)
  reg TAKEN_BRANCH;
  // Required to disable instructions after branch

  always @(posedge clk1) // IF Stage
  begin
    if (HALTED == 0)
    begin
      if (((EX_MEM_IR[5:0] == BEQZ) && (EX_MEM_cond == 1)) ||
          ((EX_MEM_IR[5:0] == BNEQZ) && (EX_MEM_cond == 0)) ||
          ((EX_MEM_IR[5:0] == BEQ) && (EX_MEM_cond2 == 1)) ||
          ((EX_MEM_IR[5:0] == BNEQ) && (EX_MEM_cond2 == 0)) ||
			  (EX_MEM_IR[5:0] == JMP))
      begin
        IF_ID_IR <= Mem[EX_MEM_ALUOut];
        TAKEN_BRANCH <= #2 1'b1;
        IF_ID_NPC <= EX_MEM_ALUOut + 1;
        PC <= EX_MEM_ALUOut + 1;
      end
      else
      begin
        IF_ID_IR <= Mem[PC];
        IF_ID_NPC <= PC + 1;
        PC <= PC + 1;
		  TAKEN_BRANCH <= #2 1'b0;
      end
    end
  end

  always @(posedge clk2) // ID Stage
  begin
    if (HALTED == 0)
    begin
      if (IF_ID_IR[10:6] == 5'b00000) ID_EX_A <= 0;
      else ID_EX_A <= Reg[IF_ID_IR[10:6]]; // "rs"
      if (IF_ID_IR[15:11] == 5'b00000) ID_EX_B <= 0;
      else ID_EX_B <= Reg[IF_ID_IR[15:11]]; // "rt"
      ID_EX_NPC <= IF_ID_NPC;
      ID_EX_IR <= IF_ID_IR;
      ID_EX_Imm <= {{16{IF_ID_IR[31]}}, {IF_ID_IR[31:16]}};

      case (IF_ID_IR[5:0])
        ADD, SUB, AND, OR, SLT, MUL, XOR, SLL, SRL, SEQ, SNEQ: ID_EX_type <= RR_ALU;
        ADDI, SUBI, SLTI, ANDI, ORI, XORI, SLLI, SRLI: ID_EX_type <= RM_ALU;
        LW: ID_EX_type <= LOAD;
        SW: ID_EX_type <= STORE;
        BNEQZ, BEQZ: ID_EX_type <= BRANCH;
        BEQ, BNEQ: ID_EX_type <= BRANCH2;
		  JMP:ID_EX_type <= BRANCH3;
        HLT: ID_EX_type <= HALT;
        default: ID_EX_type <= HALT; // Invalid opcode
      endcase
    end
  end

  always @(posedge clk1) // EX Stage
  begin
    if (HALTED == 0)
    begin
      EX_MEM_type <= ID_EX_type;
      EX_MEM_IR <= ID_EX_IR;
      

      case (ID_EX_type)
        RR_ALU:
        begin
          case (ID_EX_IR[5:0]) // "opcode"
            ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
            SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
            AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;
            OR: EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;
            SLT: EX_MEM_ALUOut <= ID_EX_A < ID_EX_B;
            MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;
            XOR: EX_MEM_ALUOut <= ID_EX_A ^ ID_EX_B;
	         SEQ: EX_MEM_ALUOut <= ID_EX_A == ID_EX_B;
            SNEQ: EX_MEM_ALUOut <= ID_EX_A !== ID_EX_B;		 
            SRL: EX_MEM_ALUOut <= ID_EX_A >> ID_EX_B;
            SLL: EX_MEM_ALUOut <= ID_EX_A << ID_EX_B;
            default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
          endcase
        end

        RM_ALU:
        begin
          case (ID_EX_IR[5:0]) // "opcode"
            ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
            SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm;
            SLTI: EX_MEM_ALUOut <= ID_EX_A < ID_EX_Imm;
            ANDI: EX_MEM_ALUOut <= ID_EX_A & ID_EX_Imm;
            ORI: EX_MEM_ALUOut <= ID_EX_A | ID_EX_Imm;
            XORI: EX_MEM_ALUOut <= ID_EX_A ^ ID_EX_Imm;
            SLLI: EX_MEM_ALUOut <= ID_EX_A << ID_EX_Imm;
            SRLI: EX_MEM_ALUOut <= ID_EX_A >> ID_EX_Imm;
            default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
          endcase
        end

        LOAD, STORE:
        begin
          EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
          EX_MEM_B <= ID_EX_B;
        end

        BRANCH:
        begin
          EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
          EX_MEM_cond <= (ID_EX_A == 0);
        end

        BRANCH2:
        begin
          EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
          EX_MEM_cond2 <= (ID_EX_A == ID_EX_B);
        end
		  
		  BRANCH3:
		  begin
		    EX_MEM_ALUOut <=ID_EX_Imm;
		  end	 
      endcase
    end
  end

  always @(posedge clk2) // MEM Stage
  begin
    if (HALTED == 0)
    begin
      MEM_WB_type <= EX_MEM_type;
      MEM_WB_IR <= EX_MEM_IR;

      case (EX_MEM_type)
        RR_ALU, RM_ALU:
          MEM_WB_ALUOut <= EX_MEM_ALUOut;
        LOAD:
          MEM_WB_LMD <= Mem[EX_MEM_ALUOut];
        STORE:
        begin
          if (TAKEN_BRANCH == 0) // Disable write
            Mem[EX_MEM_ALUOut] <= EX_MEM_B;
        end
      endcase
    end
  end

  always @(posedge clk1) // WB Stage
  begin
    if (TAKEN_BRANCH == 0) // Disable write if branch taken
    begin
      case (MEM_WB_type)
        RR_ALU:
          Reg[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut; // "rd"
        RM_ALU:
          Reg[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut; // "rt"
        LOAD:
          Reg[MEM_WB_IR[15:11]] <= MEM_WB_LMD; // "rt"
        HALT:
          HALTED <= 1'b1;
      endcase
    end
  end

endmodule
