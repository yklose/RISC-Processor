use WORK.RISC_pack.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- 16-Bit TS diver for two busses REG_A and REG_B 
entity INT_BUSDRV is 
    port(   ASEL, BSEL: in bit;
            REG_VAL: in DATA_TYPE;
            ABUS, BBUS: out DATA_TYPE);
end INT_BUSDRV;

architecture BEHAVE of INT_BUSDRV is 
begin
    ABUS <= REG_VAL after 10 ns when ASEL else (others => 'Z') after 10 ns;
    BBUS <= REG_VAL after 10 ns when BSEL else (others => 'Z') after 10 ns;
end BEHAVE;


-- 16 Bit register with Enable input
use WORK.RISC_pack.ALL;
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;

entity REG is 
    port(   CLK, RESET, CSEL: in bit;
            DATA: in DATA_TYPE;
            REG_VAL: out DATA_TYPE);
end REG; 
architecture BEHAVE of REG is
begin 
    P1: process(CLK, RESET)
        begin
            if RESET then
                REG_VAL <= (others => '0') after 5 ns; 
            elsif falling_edge(CLK) then 
            -- store at falling clock edge
                if CSEL then
                    REG_VAL <= DATA after 5 ns; 
                end if;
            end if;    
    end process P1;    
end BEHAVE; 


-- Register count x Data Type Bit Registerfile
use WORK.RISC_pack.ALL;
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity REGFILE is 
    port(   CLK, RESET: in bit; 
            SRC1, SRC2: in REGISTER_ADDRESS_TYPE;
            DATA: in DATA_TYPE;
            DEST: in REGISTER_ADDRESS_TYPE;
            EN: in bit;
            
            REG_A, REG_B: out DATA_TYPE);
end REGFILE;        
        
        

architecture BEHAVE of REGFILE is  
    signal REGFILE: REGISTER_FILE_TYPE;
    signal ASEL, BSEL: bit_vector(REGISTER_COUNT-1 downto 0);
    signal DEST_SEL: bit_vector(REGISTER_COUNT-1 downto 0);
    
    component INT_BUSDRV
        port(   ASEL, BSEL: in bit;
                REG_VAL: in DATA_TYPE;
                ABUS, BBUS: out DATA_TYPE);
    end component; 

    component REG
        port(   CLK, RESET, CSEL: in bit;
                DATA: in DATA_TYPE;
                REG_VAL: out DATA_TYPE);
    end component;
 
    begin
        DX_A: process(SRC1)
            begin
                ASEL <= (others => '0') after 5 ns;
                ASEL(conv_integer(to_stdlogicvector(SRC1))) <= '1' after 5 ns; 
        end process DX_A;
        
        DX_B: process(SRC2)
            begin
                BSEL <= (others => '0') after 5 ns;
                BSEL(conv_integer(to_stdlogicvector(SRC2))) <= '1' after 5 ns; 
        end process DX_B;
        
        DX_DEST: process (DEST, EN)
            begin
                DEST_SEL <= (others => '0') after 5 ns;
                if EN then
                    DEST_SEL(conv_integer(to_stdlogicvector(DEST))) <= '1' after 5 ns; 
                end if;
        end process DX_DEST;
    
    -- READ: Generate TS-outputs for 8 Registers
    RDGEN: for I in 0 to REGISTER_COUNT-1 generate
        TSN: INT_BUSDRV
            port map(ASEL(I), BSEL(I), REGFILE(I), REG_A, REG_B);
    end generate RDGEN;
   
    -- WRITE: Generate 8 registers
    WRGEN: for I in 0 to REGISTER_COUNT-1 generate
        WR: REG
            port map(CLK, RESET, DEST_SEL(I), DATA, REGFILE(I));
    end generate WRGEN;

end BEHAVE;        

