# Verification-of-UART_TX-by-UVM
## Design specifications are supervised by Eng. Ali El-Temsah:
  1) UART TX receive the new data on P_DATA Bus only when 
Data_Valid Signal is high.
  2) Registers are cleared using asynchronous active low reset
  3) Data_Valid is high for only 1 clock cycle
  4) Busy signal is high as long as UART_TX is transmitting the frame, 
otherwise low
  5) UART_TX couldn't accept any data on P_DATA during UART_TX 
processing, however Data_Valid get high.  

## Design Architecture:
![image](https://github.com/user-attachments/assets/a3cf9a5b-1abc-4213-a865-465d2233e49d)


## UART TX UVM environment: 
  1) Randomzing of data valid to be high for one cycle as specs.
  2) Monitoring when busy is high as now data is being transmitting.
  3) Testing odd, even parity, and non-parity behaviours.
  4) The testbench is executed using Synopsys VCS (DVE); however, due to confidentiality constraints, simulation results cannot be shared. Alternatively, a representative version will be provided via EDA Playground by using run.bash file


## TESTBENCH Architecture:
![UART](https://github.com/user-attachments/assets/88bf3f8d-792e-4fa9-924b-f6b7472eeb27)


## UVM TOPOLOGY
![image](https://github.com/user-attachments/assets/81f31649-affc-4623-a70d-e42860a0558d)


## Simulation results:
  ##### LOG
![image](https://github.com/user-attachments/assets/b11a1afb-b454-435e-9bb4-e07087d67c77)

 ##### Simulation of ODD PARITY FRAME busy high for 11 cycles, data is 01001001 when valid got high, so tx out equal 0(parity bit) in 10th cycle  of high busy.
![image](https://github.com/user-attachments/assets/94ab721f-b042-4f78-86ef-5a256972e608)

 ##### Simulation of EVEN PARITY FRAME, data is 10111110 when valid got high, so tx out equal 0 (parity bit) in 10th cycle of high busy.
![image](https://github.com/user-attachments/assets/ef5044b1-de82-47cd-9f4a-ac2d86ac430c)

 ##### Simulation of NON PARITY FRAME busy signal is high for 10 cycles.
![image](https://github.com/user-attachments/assets/89897d0b-3418-4cfa-8ad1-ff09a6c2f563)


 ## Assertions coverage 
![image](https://github.com/user-attachments/assets/bdc7c699-c510-48a6-890a-613442db5a1e)
![image](https://github.com/user-attachments/assets/077d6175-6667-469a-8136-945fe20324e2)


  





