use WORK.RISC_pack.ALL;
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity MEM_PHASE is
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
end MEM_PHASE;

architecture BEHAVE of MEM_PHASE is  
    type DATA_RAM_TYPE is array (0 to (2**(DATA_ADDRESS_WIDTH-1) -1)) of DATA_TYPE;
    signal DATA_RAM: DATA_RAM_TYPE := (others => x"0000"); 
    signal DOUT: DATA_TYPE;
    signal EN, WE, EN_EXT: bit;
    signal DEST_EN: bit;
    signal WE_EXT_int: bit;
    
    begin
        ADDR_DECODER: process(OP_RESULT_MEM, OPC_MEM)
        begin
            WE <= '0' after 5 ns;
            EN <= '0' after 5 ns;
            WE_EXT_int <= '0' after 5 ns;
            EN_EXT <= '0' after 5 ns;
            if ((OP_RESULT_MEM < x"0100") and (OPC_MEM = ldo)) then
                EN <= '1' after 5 ns;
            elsif ((OP_RESULT_MEM < x"0100") and (OPC_MEM = sto)) then
                EN <= '1' after 5 ns;
                WE <= '1' after 5 ns;
            elsif ((OP_RESULT_MEM = x"0100") and (OPC_MEM = ldo)) then
                EN_EXT <= '1' after 5 ns;
            elsif ((OP_RESULT_MEM = x"0100") and (OPC_MEM = sto)) then
                WE_EXT_int <= '1' after 5 ns;         
            end if;
        end process ADDR_DECODER;
        
        WE_EXT <= WE_EXT_int;
        
        DEST_EN <= '1' after 5 ns when  OPC_MEM = addo or OPC_MEM = subo or OPC_MEM = ando or OPC_MEM = oro or
                                        OPC_MEM = xoro or OPC_MEM = slao or OPC_MEM = srao or OPC_MEM = mvo or
                                        OPC_MEM = addilo or OPC_MEM = addiho or OPC_MEM = ldo
                                  else '0' after 5 ns;
                                    
        -- Synchronous RAM in "write-first" mode 
        RAM_P: process(CLK)
        begin
            if falling_edge(CLK) then
                if EN then
                    if WE then
                        DATA_RAM(conv_integer(OP_RESULT_MEM(7 downto 0))) <= REG_MEM after 5 ns;
                        DOUT <= REG_MEM after 5 ns;
                    else
                        DOUT <= DATA_RAM(conv_integer(OP_RESULT_MEM(7 downto 0))) after 5 ns; 
                    end if;    
                end if;
            end if;
        end process RAM_P;    
        
        -- MEM/WB Pipeline Register includes DATA multiplexer
        MEM_WB_Interface: process(RESET, CLK)
        begin
            if RESET then
                DATA_WB <= (others => '0') after 5 ns;
                DEST_WB <= (others => '0') after 5 ns;
                DEST_EN_WB <= '0' after 5 ns;
            elsif rising_edge(CLK) then
                if EN_EXT and not WE_EXT_int then
                    DATA_WB <= IN_EXT after 5 ns;
                elsif EN and not WE then
                    DATA_WB <= DOUT after 5 ns;     
                else
                    DATA_WB <= OP_RESULT_MEM after 5 ns;
                end if;
            
            DEST_WB <= DEST_MEM after 5 ns;
            DEST_EN_WB <= DEST_EN after 5 ns;
            end if; 
        end process MEM_WB_Interface;
        
        -- Registered Output (16 Bit)
        GPO: process(RESET, CLK)
        begin
            if RESET then 
                OUT_EXT <= (others => '0') after 5 ns;
            elsif rising_edge(CLK) then
                if WE_EXT_int then
                    OUT_EXT <= REG_MEM after 5 ns;
                end if;             
            end if;
        end process GPO;

end BEHAVE;  