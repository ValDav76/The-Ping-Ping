# CS4272 specifications

Le contolleur instancie l'IP I2C core d'opencores pour la partie contrôle du CS4272.

Le CS4272 est en mode `MODE_CTRL`. 

## Interfaces du module

Le module dispose de plusieurs interfaces permettant d'assurer la communication avec les différents périphériques du système.

### 1. Interface système

- `clk` : horloge principale du module.
- `rst` : signal de réinitialisation.
- `time_now` : vecteur de 64 bits contenant la référence temporelle actuelle, destiné à l'horodatage des données.

### 2. Interface AXI4-Stream – Émission

Cette interface permet de transmettre des échantillons audio vers un module externe conformément au protocole AXI4-Stream.

- `m_axis_tdata` : données audio à transmettre, sur `G_DATA_WIDTH` bits.
- `m_axis_tready` : indique que le récepteur est prêt à accepter des données.
- `m_axis_tvalid` : indique que les données présentes sur `m_axis_tdata` sont valides.
- `m_axis_tlast` : indique le dernier transfert d'un paquet.
- `m_axis_tuser` : identifie le canal audio associé à l'échantillon (gauche ou droite).

### 3. Interface AXI4-Stream – Réception

Cette interface permet de recevoir des échantillons audio provenant d'un module externe.

- `s_axis_tdata` : données audio reçues, sur `G_DATA_WIDTH` bits.
- `s_axis_tready` : indique que le module est prêt à recevoir des données.
- `s_axis_tvalid` : indique que les données présentes sur `s_axis_tdata` sont valides.
- `s_axis_tlast` : indique le dernier transfert d'un paquet.
- `s_axis_tuser` : identifie le canal audio associé à l'échantillon (gauche ou droite).

### 4. Interface I2C

Cette interface permet de communiquer avec les périphériques I2C, notamment le codec audio CS4272, afin de configurer ses registres internes.

- `scl_i` : entrée de lecture de l'état de la ligne d'horloge I2C.
- `scl_o` : valeur pilotée sur la ligne SCL.
- `scl_oe` : activation de la commande de sortie de la ligne SCL.
- `sda_i` : entrée de lecture de l'état de la ligne de données I2C.
- `sda_o` : valeur pilotée sur la ligne SDA.
- `sda_oe` : activation de la commande de sortie de la ligne SDA.

**Remarque :** l'interface utilise une commande de sortie séparée de la lecture des lignes, adaptée à une implémentation avec sorties open-drain et résistances de pull-up externes.

### 5. Interface audio CS4272 – I2S

Cette interface assure la communication audio série avec le codec CS4272.

- `CS_RSTN` : signal de réinitialisation du codec, actif à l'état bas.
- `MCLK` : horloge maître fournie au codec.
- `LRCK` : horloge de sélection du canal gauche ou droit.
- `SCLK` : horloge de transmission des données série.
- `CS_SDIN` : données audio transmises au codec.
- `CS_SDOUT` : données audio reçues depuis le codec.


## Architecture

Le controlleur permet l'initialisation du CS4272 et la conversion série de l'interface I2C en parallèle axi_stream. 

- `i2c_sequencer` : séquenceur qui gère la lecture/écriture via l'IP I2C
  - Master wihsbone pour `I2C Core
  - Interface personnalisé pour `CS4272_init`