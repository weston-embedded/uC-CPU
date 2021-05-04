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
*                                               MIPS14k
*                                              MicroMips
*
* Filename : cpu_a.s
* Version  : V1.32.01
*********************************************************************************************************
*/

#define _ASMLANGUAGE

/*
*********************************************************************************************************
*                                            PUBLIC FUNCTIONS
*********************************************************************************************************
*/

        .globl      CPU_SR_Save
        .globl      CPU_SR_Restore

/*
*********************************************************************************************************
*                                              EQUATES
*********************************************************************************************************
*/

.text


/*
*********************************************************************************************************
*                                          DISABLE INTERRUPTS
*                                      CPU_SR  CPU_SR_Save(void);
*
* Description: This function saves the state of the Status register and then disables interrupts via this
*              register.  This objective is accomplished with a single instruction, di.  The di
*              instruction's operand, $2, is the general purpose register to which the Status register's
*              value is saved.  This value can be read by C functions that call OS_CPU_SR_Save().
*
* Arguments  : None
*
* Returns    : The previous state of the Status register
*********************************************************************************************************
*/

    .ent CPU_SR_Save
CPU_SR_Save:

    jr    $31
    di    $2                                   /* Disable interrupts, and move the old value of the... */
                                               /* ...Status register into v0 ($2)                      */
    .end CPU_SR_Save


/*
*********************************************************************************************************
*                                          ENABLE INTERRUPTS
*                                   void CPU_SR_Restore(CPU_SR sr);
*
* Description: This function must be used in tandem with CPU_SR_Save().  Calling CPU_SR_Restore()
*              causes the value returned by CPU_SR_Save() to be placed in the Status register.
*
* Arguments  : The value to be placed in the Status register
*
* Returns    : None
*********************************************************************************************************
*/

    .ent CPU_SR_Restore
CPU_SR_Restore:

    jr    $31
    mtc0  $4, $12, 0                           /* Restore the status register to its previous state    */

    .end CPU_SR_Restore


/*
*********************************************************************************************************
*                                     CPU ASSEMBLY PORT FILE END
*********************************************************************************************************
*/
