# Projet FPGA

## Arborescence

```text
.
├── project.ini
├── README.md
├── rtl/
│   └── components/
│       ├── cs4272_controler/doc/
│       ├── i2c_core/
│       │   ├── doc/
│       │   └── rtl/
│       └── system_timer/rtl/
└── sim/
    ├── Makefile
    └── cocotb/
        └── system_timer/
            ├── Makefile
            └── test_system_timer.py
```

- **`rtl/components/`** contient les blocs matériels indépendants et leur
  documentation.
- **`sim/cocotb/<composant>/`** regroupe le test et le Makefile de simulation
  propres à chaque composant.
- **`sim/Makefile`** lance les tests de tous les composants.
- **`project.ini`** décrit la configuration d’exemple du test `system_timer`.

## Lancer le test du timer

Avec GHDL et cocotb installés, depuis la racine du projet :

```bash
make -C sim/cocotb/system_timer
```

Pour enregistrer une waveform au format VCD :

```bash
make -C sim/cocotb/system_timer WAVES=1
```

Le fichier est généré dans
`sim/cocotb/system_timer/sim_build/system_timer.vcd`. La commande
`make -C sim WAVES=1` lance tous les tests avec waveforms.
