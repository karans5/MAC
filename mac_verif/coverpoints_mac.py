from cocotb_coverage.coverage import *

mac_coverage = coverage_section(
    CoverPoints('mac.a', vname='a', bins=[0, 1, 32767, -32768, 16384, -16384]),
    CoverPoints('mac.b', vname='b', bins=[0, 1, 32767, -32768, 16384, -16384]),
    CoverPoints('mac.c', vname='c', bins=[0, 1, 2147483647, -2147483648, 1073741824, -1073741824]),
    CoverPoints('mac.select', vname='select', bins=[0, 1]),
    CoverPoints('mac.output', vname='output', bins=[0, 1, 2147483647, -2147483648]),
    
    CrossCoverage('cross_a_b', items=['mac.a', 'mac.b']),
    CrossCoverage('cross_a_b_c', items=['mac.a', 'mac.b', 'mac.c']),
    CrossCoverage('cross_a_b_select', items=['mac.a', 'mac.b', 'mac.select']),
    CrossCoverage('cross_c_select', items=['mac.c', 'mac.select']),
)
