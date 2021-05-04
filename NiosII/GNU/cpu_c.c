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

/*
*********************************************************************************************************
*
*                                            CPU PORT FILE
*
*                                               Nios II
*                                            GNU C Compiler
*
* Filename : cpu_c.c
* Version  : V1.32.01
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/

#define    MICRIUM_SOURCE
#include  <cpu.h>
#include  <cpu_core.h>

#ifdef __cplusplus
extern  "C" {
#endif


/*
*********************************************************************************************************
*                                            CPU_SR_Save()
*
* Description : This function disables interrupts for critical sections of code.
*
* Argument(s) : none.
*
* Return(s)   : The CPU's status register, so that interrupts can later be returned to their original
*               state.
*
* Note(s)     : none.
*********************************************************************************************************
*/

CPU_SR  CPU_SR_Save (void)
{
    return (alt_irq_disable_all());
}


/*
*********************************************************************************************************
*                                          CPU_SR_Restore()
*
* Description : Restores interrupts after critical sections of code.
*
* Argument(s) : cpu_sr    The interrupt status that will be restored.
*
* Return(s)   : none.
*
* Note(s)     : none.
*********************************************************************************************************
*/

void  CPU_SR_Restore (CPU_SR  cpu_sr)
{
    alt_irq_enable_all(cpu_sr);
}

#ifdef __cplusplus
}
#endif
