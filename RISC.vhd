library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use WORK.RISC_pack.ALL;

entity RISC is
    port(   CLK: in bit;
            RESET_A: in bit;
            IN_EXT: in DATA_TYPE;
            
            OUT_EXT: out DATA_TYPE;
            WE_EXT: out bit);
end RISC;

architecture BEHAVIOUR of RISC is
    
    component IF_PHASE
        port(   CLK: in bit;
                RESET: in bit;
                JUMP_TAKEN_EX: in bit;
                JUMP_DEST_EX: in PC_ADDRESS_TYPE;
                
                PC_ID: out PC_ADDRESS_TYPE;
                I_ID: out INSTRUCTION_TYPE);             
    end component;    
    
    component ID_PHASE
        port(   CLK: in bit;
                RESET: in bit;
                PC_ID: in PC_ADDRESS_TYPE;
                I_ID: in INSTRUCTION_TYPE;
                DATA_WB: in DATA_TYPE;
                DEST_WB: in REGISTER_ADDRESS_TYPE;
                DEST_EN_WB: in bit;
                ZFLAG, NFLAG: in bit;
                
                JUMP_TAKEN_EX: out bit;
                JUMP_DEST_EX: out PC_ADDRESS_TYPE;
                REG_A_EX: out DATA_TYPE;
                REG_B_EX: out DATA_TYPE;
                IMM_EX: out std_logic_vector(7 downto 0);
                DEST_EX: out REGISTER_ADDRESS_TYPE;
                OPC_EX: out OPCODE_TYPE
                );
    end component;

    component EX_PHASE
        port(   CLK: in bit;
                RESET: in bit;
                REG_A_EX: in DATA_TYPE;
                REG_B_EX: in DATA_TYPE;
                IMM_EX: in std_logic_vector(7 downto 0);
                DEST_EX: in REGISTER_ADDRESS_TYPE;
                OPC_EX: in OPCODE_TYPE;
                
                ZFLAG, NFLAG: out bit;
                OP_RESULT_MEM: out DATA_TYPE;
                REG_MEM: out DATA_TYPE;
                DEST_MEM: out REGISTER_ADDRESS_TYPE;
                OPC_MEM: out OPCODE_TYPE
                );
    end component;            

    component MEM_PHASE
        port(   CLK: in bit;
                RESET: in bit;
                OP_RESULT_MEM: in DATA_TYPE;
                REG_MEM: in DATA_TYPE;
                DEST_MEM: in REGISTER_ADDRESS_TYPE;
                OPC_MEM: in OPCODE_TYPE;
                IN_EXT: in DATA_TYPE;
                
                DATA_WB: out DATA_TYPE;
                DEST_WB: out REGISTER_ADDRESS_TYPE;
                DEST_EN_WB: out bit;
                OUT_EXT: out DATA_TYPE;
                WE_EXT: out bit);         
    end component;     
                
                
   -- signal declaration 
   signal TEMP, RESET: bit;
   signal JUMP_TAKEN_EX: bit;
   signal JUMP_DEST_EX, PC_ID: PC_ADDRESS_TYPE;
   signal I_ID: INSTRUCTION_TYPE;
   signal OPC_EX, OPC_MEM: OPCODE_TYPE;
   signal DEST_EX, DEST_MEM, DEST_WB: REGISTER_ADDRESS_TYPE;
   signal DEST_EN_WB: bit;
   signal NFLAG, ZFLAG: bit;
   signal REG_A_EX, REG_B_EX, OP_RESULT_MEM, REG_MEM, DATA_WB: DATA_TYPE;
   signal IMM_EX: std_logic_vector(7 downto 0);
   
   begin 
   
       ASYNC_RESET: process(CLK)
       begin
           if CLK = '1' and CLK'event then
               TEMP <= RESET_A after 5 ns;
               RESET <= TEMP after 5 ns;
           end if;
       end process ASYNC_RESET;
       
       IF_INST: IF_PHASE
            port map(CLK, RESET, JUMP_TAKEN_EX, JUMP_DEST_EX, PC_ID, I_ID);
       
       ID_INST: ID_PHASE
            port map(CLK, RESET, PC_ID, I_ID, DATA_WB, DEST_WB, DEST_EN_WB, ZFLAG, NFLAG, 
            JUMP_TAKEN_EX, JUMP_DEST_EX, REG_A_EX, REG_B_EX, IMM_EX, DEST_EX, OPC_EX);     
    
       EX_INST: EX_PHASE
            port map(CLK, RESET, REG_A_EX, REG_B_EX, IMM_EX, DEST_EX, OPC_EX, ZFLAG, NFLAG,
            OP_RESULT_MEM, REG_MEM, DEST_MEM, OPC_MEM);
         
       MEM_INST: MEM_PHASE
            port map(CLK, RESET, OP_RESULT_MEM, REG_MEM, DEST_MEM, OPC_MEM, IN_EXT, DATA_WB, 
            DEST_WB, DEST_EN_WB, OUT_EXT, WE_EXT);

end BEHAVIOUR;