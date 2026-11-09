# fonctionnement détaillé du séquenceur I2C

```mermaid
stateDiagram-v2
    [*] --> RESET
    %% State d'initialisation

    RESET          --> SET_PRERlo
    SET_PRERlo     --> SET_PRERhi     : wb_ack_i
    SET_PRERhi     --> SET_CTRL_REG   : wb_ack_i
    SET_CTRL_REG   --> WAIT_ISR_INIT  : wb_ack_i 
    WAIT_ISR_INIT  --> CLEAN_ISR_INIT : wb_inta_o
    CLEAN_ISR_INIT --> WAIT           : wb_ack_i

    %% attention à bien activer l'interuption

    %% Fin intialisation

    WAIT            --> SET_TRS_REG     : start_req
    SET_TRS_REG     --> SET_CMD_REG     : wb_ack_i
    SET_CMD_REG     --> WAIT_ISR        : wb_ack_i
    WAIT_ISR        --> CLEAN_ISR       : wb_inta_i
    CLEAN_ISR       --> READ_ACK        : wb_ack_i
    READ_ACK        --> ERROR_ACK       : wb_ack_i & ACK = 1
    READ_ACK        --> SET_TRS_REG     : wb_ack_i & ACK = 0 & cnt_cmd < 2
    READ_ACK        --> WR_DONE         : wb_ack_i & ACK = 0 & cnt_cmd = 2 & rw = 1
    WR_DONE         --> WAIT    
    READ_ACK        --> SET_NACK        : wb_ack_i & ACK = 0 & cnt_cmd = 2 & rw = 0
    SET_NACK        --> RD_WAIT_ISR     : wb_ack_i
    RD_WAIT_ISR     --> RD_CLEAN_ISR    : wb_inta_o
    RD_CLEAN_ISR    --> RD_DONE         : wb_ack_i
    RD_DONE         --> WAIT
    ERROR_ACK       --> WAIT



```

# Description des états

## Initialisation 

Pendant l'initialisation, le séquenceur vient paramètrer l'IP I2C_CORE. 


| Etat         | Description | 
|--------------|-------------|
|`SET_PRERlo`  | paramétrage des prescale |
|`SET_PRERhi`  | paramétrage des prescale |
|`SET_CTRL_REG`| Enable de l'IP + activation ISR |

## Fonctionnement nominal

L'IP passe dans l'état `WAIT` et attend de recevoir un `start_req`

`rw`, `dev_addr`, `reg_addr` et `wr_data` sont stocké en registre au changement d'état.

L'IP répète ensuite 3 fois une suite d'état qui permet de réaliser une transaction I2C.

```mermaid
stateDiagram-v2
    SET_TRS_REG --> SET_CMD_REG
    SET_CMD_REG --> WAIT_ISR
    WAIT_ISR    --> CLEAN_ISR
    CLEAN_ISR   --> READ_ACK
    READ_ACK    --> SET_TRS_REG
```

Un compteur `cnt_cmd` compte le nombre de transaction I2C réalisé. 
En fonction du compteur, les entrées des états ne sont pas les mêmes. 

On distingue deux modes de fonctionnement : WRITE et READ

Voici les états de transactions I2C en fonction du compteur `cnt_cmd`

En mode WRITE : 

| cnt_cmd | STA | STO | WR | DATA |
|---------|-----|-----|----|------|
| 0       | 1   | 0   | 1  | adresse_I2C |
| 1       | 0   | 0   | 1  | adresse_registre |
| 2       | 0   | 1   | 1  | donnée |

En mode READ : 

| cnt_cmd | STA | STO | WR | DATA |
|---------|-----|-----|----|------|
| 0       | 1   | 0   | 1  | adresse_I2C |
| 1       | 0   | 0   | 1  | adresse_registre |
| 2       | 1   | 0   | 1  | adresse_I2C |

