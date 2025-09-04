# COE overdrive LUT generator
#
# I2S Format :
# MSB first
# 16 or 24 bits (for now 16)
# two's complements
# 
# Adress 0x0000 => sample 0x0000, 0x0001 => 0x0001 ...
import numpy as np
from math import pi
import matplotlib.pyplot as plt

def int_to_complement2(value, nb_bits):
    # Calculer la plage valide

    value = int(value)
    
    max_pos = (1 << (nb_bits - 1)) - 1      # 2^(n-1) - 1
    max_neg = -(1 << (nb_bits - 1))         # -2^(n-1)
    
    # Vérifier les limites
    if value > max_pos or value < max_neg:
        raise ValueError(f"Valeur {value} hors limites [{max_neg}, {max_pos}] pour {nb_bits} bits")
    
    # Si positif ou zéro, retourner directement
    if value >= 0:
        return value
    
    # Si négatif, calculer le complément à 2
    return (1 << nb_bits) + value


def write_coe_file(data, filename, width=16):
    """
    Écrit un fichier COE pour BRAM Xilinx
    
    Args:
        data: Liste de valeurs entières
        filename: Nom du fichier .coe
        radix: Base (2, 8, 10, 16)
        width: Largeur en bits pour le formatage
    """
    with open(filename, 'w') as f:
        f.write(f"memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        
        for i, value in enumerate(data):
            value = int_to_complement2(value, width)
            hex_digits = (width + 3) // 4  # Nombre de digits hexa nécessaires
            line = f"{value:0{hex_digits}X}"
            
            # Dernière ligne sans virgule, autres avec virgule
            if i == len(data) - 1:
                f.write(line + ";")
            else:
                f.write(line + ",\n")

def write_register(data, filename, width=16):
    with open(filename, 'w') as f:
        for i, value in enumerate(data):
            value = int_to_complement2(value, width)
            hex_digits = (width + 3) // 4  # Nombre de digits hexa nécessaires
            line = f"{i} => x\"{value:0{hex_digits}X}\""
            
            # Dernière ligne sans virgule, autres avec virgule
            if i != len(data) - 1:
                line += ","

            f.write(line + "\n")

def calc_over_drive(nb_bits, gain):
    # Generate input values
    bits_tab = np.arange(-2**(nb_bits-1), 2**(nb_bits-1), 256)
    print(bits_tab)
    # Normalize to [-1, 1]
    data_norm = np.float32(bits_tab) / 2**(nb_bits-1)

    # Apply arctan waveshaper
    data_out = (2/pi) * np.arctan(gain * data_norm)

    # Scale to 16-bit PCM range
    data_out = np.int16(data_out * 2**(nb_bits-1))
    
    return data_out


data = calc_over_drive(16, 1)
fig, ax = plt.subplots()
ax.plot(data)
plt.savefig("plot.png", dpi=300)   # tu peux mettre .png, .jpg, .pdf...
plt.close(fig)            # libérer la mémoire



write_coe_file(data, 'overdrive.coe', width=16)
write_register(data, 'overdrive.txt')

