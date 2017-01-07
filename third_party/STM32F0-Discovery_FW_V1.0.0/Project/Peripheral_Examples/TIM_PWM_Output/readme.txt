/**
  @page TIM_PWM_Output TIM_PWM_Output
  
  @verbatim
  ******************** (C) COPYRIGHT 2012 STMicroelectronics *******************
  * @file    TIM_PWM_Output/readme.txt   
  * @author  MCD Application Team
  * @version V1.0.0
  * @date    23-March-2012
  * @brief   Description of the TIM PWM_Output example.
  ******************************************************************************
  *
  * Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/software_license_agreement_liberty_v2
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *   
  ******************************************************************************
   @endverbatim

@par Example Description 

This example shows how to configure the TIM1 peripheral to generate PWM signals 
with 4 different duty cycles (50%, 37.5%, 25% and 12.5%).

TIM1CLK = SystemCoreClock, Prescaler = 0, TIM1 counter clock = SystemCoreClock
SystemCoreClock is set to 48 MHz for STM32F0xx devices.

The objective is to generate PWM signal at 17.57 KHz:
  - TIM1_Period = (SystemCoreClock / 17570) - 1
The channel 1 duty cycle is set to 50%
The channel 2 duty cycle is set to 37.5%
The channel 3 duty cycle is set to 25%
The channel 4 duty cycle is set to 12.5%
The Timer pulse is calculated as follows:
  - ChannelxPulse = DutyCycle * (TIM1_Period - 1) / 100

The TIM1 waveform can be displayed using an oscilloscope.


@par Directory contents 

  - TIM_PWM_Output/stm32f0xx_conf.h    Library Configuration file
  - TIM_PWM_Output/stm32f0xx_it.c      Interrupt handlers
  - TIM_PWM_Output/stm32f0xx_it.h      Interrupt handlers header file
  - TIM_PWM_Output/main.c              Main program
  - TIM_PWM_Output/system_stm32f0xx.c  STM32F0xx system source file
  
@note The "system_stm32f0xx.c" file contains the system clock configuration for
      STM32F0xx devices, and is customized for use with STM32F0-Discovery Kit. 
      The STM32F0xx is configured to run at 48 MHz, following the three  
      configuration below:
        + PLL_SOURCE_HSI
           - HSI (~8 MHz) used to clock the PLL, and the PLL is used as system 
             clock source.  
        + PLL_SOURCE_HSE          
           - HSE (8 MHz) used to clock the PLL, and the PLL is used as system
             clock source.
           - The HSE crystal is not provided with the Discovery Kit, some 
             hardware modification are needed in manner to connect this crystal.
             For more details, refer to section "4.7 OSC clock" in "STM32F0 discovery kit User manual (UM1525)"
        + PLL_SOURCE_HSE_BYPASS   
           - HSE bypassed with an external clock (fixed at 8 MHz, coming from 
             ST-Link circuit) used to clock the PLL, and the PLL is used as 
             system clock source.
           - Some  hardware modification are needed in manner to bypass the HSE 
             with clock coming from the ST-Link circuit.
             For more details, refer to section "4.7 OSC clock" in "STM32F0 discovery kit User manual (UM1525)"
      User can select one of the three configuration in system_stm32f0xx.c file
      (default configuration is PLL_SOURCE_HSI).
         

@par Hardware and Software environment

  - This example runs on STM32F0xx Devices.
  
  - This example has been tested with STMicroelectronics STM32F0-Discovery (MB1034) 
    RevB and can be easily tailored to any other supported device and development board.
    
  - STM32F0-Discovery Set-up
   - Connect the TIM1 pins to an oscilloscope to monitor the different waveforms:
      - TIM1_CH1  pin (PA.08)
      - TIM1_CH2  pin (PA.09)
      - TIM1_CH3  pin (PA.10)
      - TIM1_CH4  pin (PA.11)


@par How to use it ? 

In order to make the program work, you must do the following :

 + EWARM
    - Open the TIM_PWM_Output.eww workspace 
    - Rebuild all files: Project->Rebuild all
    - Load project image: Project->Debug
    - Run program: Debug->Go(F5)

 + MDK-ARM
    - Open the TIM_PWM_Output.uvproj project
    - Rebuild all files: Project->Rebuild all target files
    - Load project image: Debug->Start/Stop Debug Session
    - Run program: Debug->Run (F5)    

 + TASKING
    - Open TASKING toolchain.
    - Click on File->Import, select General->'Existing Projects into Workspace' 
      and then click "Next". 
    - Browse to  TASKING workspace directory and select the project "TIM_PWM_Output"   
    - Rebuild all project files: Select the project in the "Project explorer" 
      window then click on Project->build project menu.
    - Run program: Select the project in the "Project explorer" window then click 
      Run->Debug (F11)

 + TrueSTUDIO for ARM
    - Open the TrueSTUDIO for ARM toolchain.
    - Click on File->Switch Workspace->Other and browse to TrueSTUDIO workspace 
      directory.
    - Click on File->Import, select General->'Existing Projects into Workspace' 
      and then click "Next". 
    - Browse to the TrueSTUDIO workspace directory and select the project "TIM_PWM_Output" 
    - Rebuild all project files: Select the project in the "Project explorer" 
      window then click on Project->build project menu.
    - Run program: Select the project in the "Project explorer" window then click 
      Run->Debug (F11)

 * <h3><center>&copy; COPYRIGHT STMicroelectronics</center></h3>
 */
