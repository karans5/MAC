m import os
import random
from pathlib import Path
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from model_mac import *
#print("reading mac32 values")
# Helper function to read inputs from a file
def read_macint32_file(file_path):
    a = []
    b = []
    c = []
    with open(file_path+'A_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            a.append(value)  # Append the value to the list
    with open(file_path+'B_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            b.append(value)  # Append the value to the list
    with open(file_path+'C_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            c.append(value)  # Append the value to the list
    return list(zip(a,b,c))
#print("macint32 values=",read_macint32_file('/home/karan/Downloads/CS6230_project1_v2/test_cases/int8 MAC/'))

def read_macfp32_file(file_path):
    a = []  # List to store the values
    b = []
    c = []
    with open(file_path+'A_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            a.append(value)  # Append the value to the list
    with open(file_path+'B_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            b.append(value)  # Append the value to the list
    with open(file_path+'C_decimal.txt', 'r') as file:
        next(file)  # Skip header if present
        for line in file:
            value = line.strip()
            c.append(value)  # Append the value to the list
    return list(zip(a,b,c))
#print("mac32 values=",read_macfp32_file('/home/karan/Downloads/CS6230_project1_v2/test_cases/bf16 MAC/'))


@cocotb.test()
async def test_mac(dut):
    '''Test the MAC module'''

    # Initialize and start the clock
    clock = Clock(dut.CLK, 10, units="us")
    cocotb.start_soon(clock.start(start_high=False))

    # Reset the DUT
    dut.RST_N.value = 0
    await RisingEdge(dut.CLK)
    dut.RST_N.value = 1
    await RisingEdge(dut.CLK)

    # Integer MAC Test (select = 0)
    await test_mac_int(dut, '/home/karan/Downloads/CS6230_project1_v2/test_cases/int8 MAC/', select=0)

    # Floating-Point MAC Test (select = 1)
    await test_mac_fp(dut, '/home/karan/Downloads/CS6230_project1_v2/test_cases/bf16 MAC/', select=1)

    # Export coverage data
    coverage_db.export_to_yaml(filename="coverage_mac.yml")


async def test_mac_int(dut, input_file, select):
    '''Test the MAC module with the specified integer mode.'''

    # Set S1/S2 mode (integer or floating-point)
    dut.set_S1_or_S2_mode.value = select
    dut.EN_set_S1_or_S2.value = 1  # Enable mode selection
    await RisingEdge(dut.CLK)
    assert dut.RDY_set_S1_or_S2.value == 1, "RDY_set_S1_or_S2 not asserted"
    dut.EN_set_S1_or_S2.value = 0  # Disable after setting mode

    # Read input values from the file
    input_values = read_macint32_file(input_file)

    for a, b, c in input_values:
        # Set value of A and wait for RDY signal
        dut.get_A_value.value = a
        dut.EN_get_A.value = 1  # Enable A input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_A.value == 1, "RDY_get_A not asserted"
        dut.EN_get_A.value = 0  # Disable after setting

        # Set value of B and wait for RDY signal
        dut.get_B_value.value = b
        dut.EN_get_B.value = 1  # Enable B input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_B.value == 1, "RDY_get_B not asserted"
        dut.EN_get_B.value = 0  # Disable after setting

        # Set value of C and wait for RDY signal
        dut.get_C_value.value = c
        dut.EN_get_C.value = 1  # Enable C input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_C.value == 1, "RDY_get_C not asserted"
        dut.EN_get_C.value = 0  # Disable after setting

        # Simulate expected output using mac_model
        expected_output = mac_model(a, b, c, select)

        # Wait for the MAC output to be ready
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_MAC.value == 1, "RDY_get_MAC not asserted"

        # Check the output against the expected value
        assert int(dut.get_MAC.value) == expected_output, \
            f"Mismatch: DUT = {int(dut.get_MAC.value)}, Expected = {expected_output}"
            dut._log.info(f"Integer MAC Output: {int(dut.get_MAC.value)}")


async def test_mac_fp(dut, input_file, select):
    '''Test the MAC module with the specified floating mode.'''

    # Set S1/S2 mode (integer or floating-point)
    dut.set_S1_or_S2_mode.value = select
    dut.EN_set_S1_or_S2.value = 1  # Enable mode selection
    await RisingEdge(dut.CLK)
    assert dut.RDY_set_S1_or_S2.value == 1, "RDY_set_S1_or_S2 not asserted"
    dut.EN_set_S1_or_S2.value = 0  # Disable after setting mode

    # Read input values from the file
    input_values = read_macfp32_file(input_file)

    for a, b, c in input_values:
        # Set value of A and wait for RDY signal
        dut.get_A_value.value = a
        dut.EN_get_A.value = 1  # Enable A input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_A.value == 1, "RDY_get_A not asserted"
        dut.EN_get_A.value = 0  # Disable after setting

        # Set value of B and wait for RDY signal
        dut.get_B_value.value = b
        dut.EN_get_B.value = 1  # Enable B input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_B.value == 1, "RDY_get_B not asserted"
        dut.EN_get_B.value = 0  # Disable after setting

        # Set value of C and wait for RDY signal
        dut.get_C_value.value = c
        dut.EN_get_C.value = 1  # Enable C input
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_C.value == 1, "RDY_get_C not asserted"
        dut.EN_get_C.value = 0  # Disable after setting

        # Simulate expected output using mac_model
        # Convert to float for floating-point operation
        expected_output = mac_model(float(a), float(b), float(c), select)

        # Wait for the MAC output to be ready
        await RisingEdge(dut.CLK)
        assert dut.RDY_get_MAC.value == 1, "RDY_get_MAC not asserted"

        # Check the output against the expected value
        assert float(dut.get_MAC.value) == expected_output, \
            f"Mismatch: DUT = {float(dut.get_MAC.value)}, Expected = {expected_output}"
            dut._log.info(f"Floating-Point MAC Output: {float(dut.get_MAC.value)}")


