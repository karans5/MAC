from cocotb_coverage.coverage import *

from itertools import combinations

def generate_bitwalking_outputs(num_bits, total_size, pattern="ones"):
    if num_bits > total_size:
        raise ValueError("num_bits cannot exceed total_size")
    if pattern not in ["ones", "zeros"]:
        raise ValueError("pattern must be either 'ones' or 'zeros'")
    
    results = []
    bit_positions = combinations(range(total_size), num_bits)
    
    if pattern == "ones":
        # Generate walking ones (specified number of 1s, rest 0s)
        for positions in bit_positions:
            binary = 0
            for pos in positions:
                binary |= (1 << (total_size - 1 - pos))
            results.append(binary)
    elif pattern == "zeros":
        # Generate walking zeros (specified number of 0s, rest 1s)
        for positions in bit_positions:
            binary = (1 << total_size) - 1
            for pos in positions:
                binary &= ~(1 << (total_size - 1 - pos))
            results.append(binary)
    return results

a,b,c = [],[],[]
for num in range(2):
    a += generate_bitwalking_outputs(num, 16, "ones")
    b += generate_bitwalking_outputs(num, 16, "ones")
    c += generate_bitwalking_outputs(num, 32, "ones")
a += [0, 1, 65535]
b += [0, 1, 65535]
c += [0, 1, 4294967295]

mac_coverage = coverage_section(
    CoverPoint('mac.a', vname='a', bins=a),
    CoverPoint('mac.b', vname='b', bins=b),
    CoverPoint('mac.c', vname='c', bins=c),
    CoverPoint('mac.select', vname='select', bins=[0, 1]),
    CoverCross('mac.select_X_a', items=['mac.select','mac.a']),
    CoverCross('mac.select_X_b', items=['mac.select','mac.b']),
    CoverCross('mac.select_X_c', items=['mac.select','mac.c'])
)
