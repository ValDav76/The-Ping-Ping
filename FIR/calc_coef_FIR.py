import numpy as np
from scipy.signal import firwin

fs = 48000      # échantillonnage
fc = 5000       # fréquence de coupure

# Passe-bas
h_low = firwin(numtaps=8, cutoff=fc, fs=fs, pass_zero='lowpass')

# Passe-haut
h_high = firwin(numtaps=9, cutoff=fc, fs=fs, pass_zero='highpass')

print("Coef Passe bas : ")
print(h_low) 

print("Coef passe haut : ")
print(h_high)