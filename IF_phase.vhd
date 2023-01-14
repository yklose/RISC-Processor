use WORK.RISC_pack.ALL;
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity IF_PHASE is 

    port (  CLK : in bit;
            RESET: in bit;
            JUMP_TAKEN_EX: in bit;
            JUMP_DEST_EX: in PC_ADDRESS_TYPE;
            
            PC_ID: out PC_ADDRESS_TYPE;
            I_ID: out INSTRUCTION_TYPE);
end IF_PHASE;

architecture BEHAVIOUR of IF_PHASE is

    -- 256x16 bit instruction ROM
    type INSTR_ROM_TYPE is array (0 to ((2**PC_ADDRESS_WIDTH) -1)) of INSTRUCTION_TYPE;
    
    constant INSTR_ROM: INSTR_ROM_TYPE := 
    (
        x"4911", x"4A22", x"4B33", x"4C44", x"4D55", x"6820", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0B70", x"0000", x"0000", x"1374", x"0000", x"0000", x"6814", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"16AC", x"0000", x"7005", x"0F28", x"0000", x"0000", x"0000", x"6860",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        x"6120", x"5A20", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
        others => (x"0000")
    );
    
    signal PC_ACT : PC_ADDRESS_TYPE; 
    signal EN : bit;
    
    begin
        EN <= '1';
        
        PC: process(CLK, RESET)
        begin
            if RESET = '1' then
                PC_ACT <= (others => '1') after 5 ns;
            elsif CLK='0' and CLK'event then
                if JUMP_TAKEN_EX = '1' then 
                    PC_ACT <= JUMP_DEST_EX after 5 ns;
                else
                    PC_ACT <= PC_ACT + 1 after 5 ns; 
                end if;    
            end if;
        end process PC;    
            
        ROM_P: process (CLK)
        begin 
            if (CLK='1' and CLK'event) then 
                if EN = '1' then
                    I_ID <= INSTR_ROM(conv_integer(PC_ACT)) after 5 ns;
                end if;
            end if;
        end process ROM_P;
        
        IF_ID: process(CLK, RESET)
        begin
            if RESET = '1' then
                PC_ID <= (others => '0') after 5 ns;
            elsif CLK = '1' and CLK'event then
                PC_ID <= PC_ACT after 5 ns;
            end if;
        end process IF_ID;
        
    
end BEHAVIOUR;