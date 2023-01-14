use WORK.RISC_pack.ALL;
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity EX_PHASE is

    port (  CLK: in bit;
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
            OPC_MEM: out OPCODE_TYPE);
end EX_PHASE;


architecture BEHAVE of EX_PHASE is 

    signal OPA, OPB: DATA_TYPE;
    signal OP_RESULT: DATA_TYPE;
    signal ZFLG, NFLG: bit;
    constant ZERO: std_logic_vector(DATA_WIDTH downto 0) := (others => '0');
    
    begin 
    OPA <= REG_A_EX;
    
    OPB_MUX: process(REG_B_EX, IMM_EX, OPC_EX)
    begin
        case OPC_EX is 
            when addo | subo | ando | oro | xoro => OPB <= REG_B_EX after 5 ns;
            when others => OPB <= Zero_ext(IMM_EX, DATA_WIDTH) after 5 ns;
        end case;
    end process OPB_MUX;
    
    ALU: process(OPA, OPB, OPC_EX)
    begin 
        OP_RESULT <= (others => '0');
        case OPC_EX is 
            when addo => OP_RESULT <= OPA + OPB after 5 ns;
            when subo => OP_RESULT <= OPA - OPB after 5 ns;
            when ando => OP_RESULT <= OPA and OPB after 5 ns;
            when oro => OP_RESULT <= OPA or OPB after 5 ns;
            when xoro => OP_RESULT <= OPA xor OPB after 5 ns;
            when slao => OP_RESULT <= OPA(DATA_WIDTH-2 downto 0) & '0' after 5 ns;
            when srao => OP_RESULT <= OPA(DATA_WIDTH-1) & OPA(DATA_WIDTH-1 downto 1) after 5 ns;
            when mvo | ldo | sto => OP_RESULT(DATA_WIDTH-1 downto 0) <= OPA after 5 ns;
            when addilo => OP_RESULT <= OPA(15 downto 8) & (OPA(7 downto 0) + OPA(7 downto 0)) after 5 ns;
            when addiho => OP_RESULT <= (OPA(15 downto 8) + OPA(7 downto 0)) & OPA(7 downto 0) after 5 ns;
            when others => null;
        end case;
    end process ALU;
   
   FLAG_GEN: process(OP_RESULT)
   begin
        ZFLG <= '0' after 5 ns;
        if OP_RESULT = ZERO then
            ZFLG <= '1' after 5 ns;
        end if;
        NFLG <= To_Bit(OP_RESULT(DATA_WIDTH-2)) after 5 ns; 
   end process FLAG_GEN;     
   
   EX_MEM_Interface: process(RESET, CLK)
   begin
        if RESET = '1' then
            OP_RESULT_MEM <= (others => '0') after 5 ns;
            REG_MEM <= (others => '0') after 5 ns;
            DEST_MEM <= (others => '0') after 5 ns;
            OPC_MEM <= nopo after 5 ns;
            ZFLAG <= '0' after 5 ns;
            NFLAG <= '0' after 5 ns;
        elsif CLK = '1' and CLK'event then
            OP_RESULT_MEM <= OP_RESULT after 5 ns;
            REG_MEM <= REG_B_EX after 5 ns;
            DEST_MEM <= DEST_EX after 5 ns;
            OPC_MEM <= OPC_EX after 5 ns;
            ZFLAG <= ZFLG after 5 ns;
            NFLAG <= NFLG after 5 ns;
        end if;     
   end process EX_MEM_Interface;
end BEHAVE;
