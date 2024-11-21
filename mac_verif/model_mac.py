#importing mac_coverage
import cocotb
from coverpoints_mac import mac_coverage

@mac_coverage
def refmodel(a, b, c, select: int):

    # Determine input type for coverage
    input_type = (
        'integer' if isinstance(a, int) and isinstance(b, int) and isinstance(c, int) else
        'fractional' if any(isinstance(x, float) for x in [a, b, c]) else
        'negative' if any(x < 0 for x in [a, b, c]) else 'other'
    )

    # Perform MAC operation based on `select` input
    if select == 0:  # Integer MAC operation
        result = (int(a) * int(b)) + int(c)
    elif select == 1:  # Floating-point MAC operation
        result = (float(a) * float(b)) + float(c)
    else:
        raise ValueError("Invalid select input! Use 0 for integer, 1 for floating-point.")

    print(f"[MAC Model] a={a}, b={b}, c={c}, select={select}, result={result}, type={input_type}")
    return result

