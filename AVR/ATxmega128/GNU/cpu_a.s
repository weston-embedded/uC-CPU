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
*                                           Atmel ATxmega128
*                                            GNU C Compiler
*
* Filename : cpu_a.s
* Version  : V1.32.01
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                             ASM HEADER
*********************************************************************************************************
*/

        .text


/*
*********************************************************************************************************
*                                              DEFINES
*********************************************************************************************************
*/

        .equ SREG, 0x3F                                         /* Status  Register                                     */


/*
*********************************************************************************************************
*                                          PUBLIC DECLARATIONS
*********************************************************************************************************
*/

        .global CPU_SR_Save
        .global CPU_SR_Restore


/*
*********************************************************************************************************
*                            DISABLE/ENABLE INTERRUPTS USING OS_CRITICAL_METHOD #3
*
* Description : These functions are used to disable and enable interrupts using OS_CRITICAL_METHOD #3.
*
*               CPU_SR  CPU_SR_Save (void)
*                     Get current value of SREG
*                     Disable interrupts
*                     Return original value of SREG
*
*               void  CPU_SR_Restore (OS_CPU_SR cpu_sr)
*                     Set SREG to cpu_sr
*                     Return
*********************************************************************************************************
*/

CPU_SR_Save:
        IN      R16,SREG                                        /* Get current state of interrupts disable flag         */
        CLI                                                     /* Disable interrupts                                   */
        RET                                                     /* Return original SREG value in R16                    */


CPU_SR_Restore:
        OUT     SREG,R16                                        /* Restore SREG                                         */
        RET                                                     /* Return                                               */
