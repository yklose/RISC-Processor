library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- define RISC package
package RISC_pack is

-- List of instructions
type OPCODE_TYPE is (nopo, addo, subo, ando, oro, xoro, slao, srao, mvo, addilo, addiho, ldo, sto, jmpo, bneo, blto, bgeo);

constant DATA_WIDTH : natural := 16;
constant INSTRUCTION_WIDTH : natural := 16;
constant OPCODE_WIDTH : natural := 5;
constant REGISTER_ADDRESS_WIDTH : natural := 3;
constant REGISTER_COUNT : natural := 8;
constant PC_ADDRESS_WIDTH : natural := 8;
constant DATA_ADDRESS_WIDTH : natural := 9; 

subtype DATA_TYPE is std_logic_vector(DATA_WIDTH-1 downto 0);
subtype INSTRUCTION_TYPE is std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
subtype PC_ADDRESS_TYPE is std_logic_vector(PC_ADDRESS_WIDTH-1 downto 0);
subtype DATA_ADDRESS_TYPE is std_logic_vector(DATA_ADDRESS_WIDTH-1 downto 0);
subtype REGISTER_ADDRESS_TYPE is bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);

type REGISTER_FILE_TYPE is array(0 to REGISTER_COUNT-1) of DATA_TYPE;

-- function prototype
function To_StdLogic (b : Bit) RETURN std_logic;
function Zero_ext (INP : std_logic_vector; L : natural) RETURN std_logic_vector;
end RISC_pack;

package body RISC_pack is 

-- type conversion from bit to std_logic
function To_StdLogic (b: bit) return std_logic is 
    variable result : std_logic;
    begin 
        Result := '0' when b else '1';
    return RESULT;
end To_StdLogic;

-- Zero extentsion input to L bits (L must be larger than INP'lenght)
function Zero_ext (INP: std_logic_vector; L : natural) return std_logic_vector is 
    variable result: std_logic_vector(L-1 downto 0);
    
    begin 
        result(INP'length-1 downto 0) := INP;
        for J in L-1 downto INP'length loop
            result(J) := '0';
        end loop;
    return result;
end Zero_ext;

end RISC_pack;