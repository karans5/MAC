#import os
#import random
#from pathlib import Path
#import cocotb
#from cocotb.clock import Clock
#from cocotb.triggers import RisingEdge
#from model_mac import *
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
    return a,b,c
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
    return a,b,c
#print("mac32 values=",read_macfp32_file('/home/karan/Downloads/CS6230_project1_v2/test_cases/bf16 MAC/'))


@cocotb.test()
async def test_mac(dut):
    '''Test to check MAC'''
    clock = Clock(dut.CLK, 10, units="us")
    cocotb.start_soon(clock.start(start_high=False))
    dut.RST_N.value = 0
    await RisingEdge(dut.CLK)
    dut.RST_N.value = 1

    # Read inputs from the file
    input_values = read_input_file('mac_inputs.txt')

    # Test with select = 0 (integer MAC)
    dut._log.info('MACINT32 operation (select=0)')
    dut.select.value = 0

    for a, b, c in input_values:
        dut.a.value = a
        dut.b.value = b
        dut.c.value = c

        # Simulate mac_model and get expected output
        expected_output = mac_model(a, b, c, select=0)

        # Wait for the result to propagate
        await RisingEdge(dut.CLK)

        # Compare DUT output with model output
        assert int(dut.output.value) == expected_output, \
            f'Mismatch: DUT = {int(dut.output.value)}, Expected = {expected_output}'
        dut._log.info(f'Integer MAC Output: {int(dut.output.value)}')

    # Test with select = 1 (floating-point MAC)
    dut._log.info('MACFP32 operation (select=1)')
    dut.select.value = 1

    for a, b, c in input_values:
        # Convert integers to floats for floating-point operation
        fa, fb, fc = float(a), float(b), float(c)

        dut.a.value = fa
        dut.b.value = fb
        dut.c.value = fc

        # Simulate mac_model for floating-point and get expected output
        expected_output = mac_model(fa, fb, fc, select=1)

        # Wait for the result to propagate
        await RisingEdge(dut.CLK)

        # Compare DUT output with model output
        assert float(dut.output.value) == expected_output, \
            f'Mismatch: DUT = {float(dut.output.value)}, Expected = {expected_output}'
        dut._log.info(f'Floating-Point MAC Output: {float(dut.output.value)}')


