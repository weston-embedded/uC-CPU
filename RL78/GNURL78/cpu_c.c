/*
*********************************************************************************************************
*                                               uC/CPU
*                                    CPU CONFIGURATION & PORT LAYER
*
*                    Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
*
*                                 SPDX-License-Identifier: APACHE-2.0
*
*               This software is subject to an open source license and is distributed by
*                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
*                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
*
*********************************************************************************************************
*/

/********************************************************************************************************
*
*                                            CPU PORT FILE
*
*                                      Renesas RL78 Specific code
*                                          GNU RL78 C Compiler
*
* Filename : cpu_c.c
* Version  : V1.32.01
*********************************************************************************************************
*/

#include  <cpu.h>


/********************************************************************************************************
*                                    set_interrupt_state & get_interrupt_state
*
* Description: Set or retrieve interrupt priority level.
* KPIT GNU Work around for set and get interrupt states
*********************************************************************************************************
*/

void __set_interrupt_state(CPU_INT08U cpu_sr){
    if (cpu_sr)
        asm("EI");
    else
        asm("DI");
}

CPU_INT08U __get_interrupt_state(void){

    CPU_INT08U  cpu_sr;


    asm(" MOV  A, PSW");                                        /* Get Process Status Word Register PSW value           */
    asm(" SHR  A, 7");                                          /* Save only the Interrupt Enabled (IE) Bit             */
    asm(" MOV  %0, A" : "=r"(cpu_sr));                          /* Save IE bit value into cpu_sr                        */       //__asm

    return(cpu_sr);
}
