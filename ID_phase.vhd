use WORK.RISC_pack.ALL;
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity ID_PHASE is 
port (  CLK: in bit;
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
        OPC_EX: out OPCODE_TYPE);        
end ID_PHASE;

architecture DECODE of ID_PHASE is 

    signal REG_A, REG_B: DATA_TYPE;
    signal SRC1, SRC2: REGISTER_ADDRESS_TYPE;
    signal JUMP_TAKEN: bit;
    signal JUMP_DEST: PC_ADDRESS_TYPE;
    signal OPC_ID_int: OPCODE_TYPE;
    
    component REGFILE
        port (  CLK, RESET: in bit;
                SRC1, SRC2: in REGISTER_ADDRESS_TYPE;
                DATA: in DATA_TYPE;
                DEST: in REGISTER_ADDRESS_TYPE;
                EN: in bit;
                
                REG_A, REG_B: out DATA_TYPE);
            
    end component; 
    
    begin
        OPDEC: process(I_ID)
        begin
            case I_ID(15 downto 11) is 
                when "00000" => OPC_ID_int <= nopo after 5 ns;
                when "00001" => OPC_ID_int <= addo after 5 ns;
                when "00010" => OPC_ID_int <= subo after 5 ns;
                when "00011" => OPC_ID_int <= ando after 5 ns;
                when "00100" => OPC_ID_int <= oro after 5 ns;
                when "00101" => OPC_ID_int <= xoro after 5 ns;
                when "00110" => OPC_ID_int <= slao after 5 ns;
                when "00111" => OPC_ID_int <= srao after 5 ns;
                when "01000" => OPC_ID_int <= mvo after 5 ns;
                when "01001" => OPC_ID_int <= addilo after 5 ns;
                when "01010" => OPC_ID_int <= addiho after 5 ns;
                when "01011" => OPC_ID_int <= ldo after 5 ns;
                when "01100" => OPC_ID_int <= sto after 5 ns;
                when "01101" => OPC_ID_int <= jmpo after 5 ns;
                when "01110" => OPC_ID_int <= bneo after 5 ns;
                when "01111" => OPC_ID_int <= blto after 5 ns;
                when "10000" => OPC_ID_int <= bgeo after 5 ns;
                when others => OPC_ID_int <= nopo after 5 ns;
            end case;
        end process OPDEC;
        
        -- Register selection MUXes
        SRC1_MUX: process(I_ID, OPC_ID_int)
        begin
            case OPC_ID_int is 
                when addilo | addiho => SRC1 <= to_bitvector(I_ID(10 downto 8));
                when others => SRC1 <= to_bitvector(I_ID(7 downto 5));
            end case;
        end process SRC1_MUX;

        SRC2_MUX: process(I_ID, OPC_ID_int)
        begin
            case OPC_ID_int is 
                when sto => SRC2 <= to_bitvector(I_ID(10 downto 8));
                when others => SRC2 <= to_bitvector(I_ID(4 downto 2));
            end case;  
        end process SRC2_MUX;            

        -- Address ALU for branch target calculation includes address mux
        ADDR_ALU: process(OPC_ID_int, PC_ID, I_ID)
        begin
            JUMP_DEST <= I_ID(PC_ADDRESS_WIDTH-1 downto 0) after 5 ns;
            if (OPC_ID_int = bneo) or (OPC_ID_int = blto) or (OPC_ID_int = bgeo) then
                JUMP_DEST <= I_ID(PC_ADDRESS_WIDTH-1 downto 0) + PC_ID after 5 ns;
            end if;
        end process ADDR_ALU;
        
        -- Jump_taken generator
        JUMP_TAKEN_P: process(OPC_ID_int, ZFLAG, NFLAG)
        begin
            JUMP_TAKEN <= '0' after 5 ns;
            if ((OPC_ID_int = jmpo) 
                or ((OPC_ID_int = bneo) and (ZFLAG = '0'))
                or ((OPC_ID_int = blto) and (NFLAG = '1'))
                or ((OPC_ID_int = bgeo) and ((NFLAG = '0' ) or (ZFLAG = '1')))) then 
                JUMP_TAKEN <= '1' after 5 ns;
            end if;               
        end process JUMP_TAKEN_P;
        
        -- Registerfile component instantiation
        dut: REGFILE port map (CLK, RESET, SRC1, SRC2, DATA_WB, DEST_WB, DEST_EN_WB, REG_A, REG_B);
        
        -- ID/EX Pipeline Registers
        ID_EX_Interface: process(RESET, CLK)
        begin
            if RESET then
                REG_A_EX <= (others => '0') after 5 ns;
                REG_B_EX <= (others => '0') after 5 ns;
                IMM_EX <= (others => '0') after 5 ns;
                DEST_EX <= (others => '0') after 5 ns;
                OPC_EX <= nopo after 5 ns;
            elsif rising_edge(CLK) then
                REG_A_EX <= REG_A after 5 ns;
                REG_B_EX <= REG_B after 5 ns;
                IMM_EX <= I_ID(7 downto 0) after 5 ns;
                DEST_EX <= to_bitvector(I_ID(10 downto 8)) after 5 ns;
                OPC_EX <= OPC_ID_int after 5 ns;
            end if;
        end process ID_EX_Interface;
        
        JUMP_TAKEN_EX <= JUMP_TAKEN;
        JUMP_DEST_EX <= JUMP_DEST;
end DECODE;
        

