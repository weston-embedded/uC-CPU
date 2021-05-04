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
*                                              MIPS32 4K
*                                                MPLAB
*
* Filename : cpu_a.s
* Version  : V1.32.01
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                           PUBLIC FUNCTIONS
*********************************************************************************************************
*/

    .global  CPU_SR_Save
    .global  CPU_SR_Restore
    .global  CPU_CntLeadZeros


/*
*********************************************************************************************************
*                                      CODE GENERATION DIRECTIVES
*********************************************************************************************************
*/

    .section .text,code
    .set noreorder


/*
**********************************************************************************************************
*                                      CRITICAL SECTION FUNCTIONS
*
* Description : Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking, the
*               state of the interrupt disable flag is stored in the local variable 'cpu_sr' & interrupts
*               are then disabled ('cpu_sr' is allocated in all functions that need to disable interrupts).
*               The previous interrupt state is restored by copying 'cpu_sr' into the CPU's status register.
*
* Prototypes  : CPU_SR  CPU_SR_Save(void);
*               void    CPU_SR_Restore(CPU_SR cpu_sr);
**********************************************************************************************************
*/

    .ent CPU_SR_Save
CPU_SR_Save:

    di    $2                                   /* Disable interrupts, and move the old value of the... */
    jr.hb $31                                  /* ...Status register into v0 ($2)                      */
    nop

    .end CPU_SR_Save


    .ent CPU_SR_Restore
CPU_SR_Restore:

    mtc0  $4, $12, 0                           /* Restore the status register to its previous state    */
    jr.hb $31
    nop

    .end CPU_SR_Restore


/*
*********************************************************************************************************
*                                         CPU_CntLeadZeros()
*
* Description : Count the number of contiguous, most-significant, leading zero bits in a data value.
*
* Argument(s) : val         Data value to count leading zero bits.
*
* Return(s)   : Number of contiguous, most-significant, leading zero bits in 'val', if NO error(s).
*               0, otherwise.
*
* Note(s)     : (1) (a) Supports the following data value sizes :
*
*                       (1)  8-bits - N/A
*                       (2) 16-bits - N/A
*                       (3) 32-bits - M4K core (see MIPS clz documentation)
*                       (4) 64-bits - N/A
*
*                       See also 'cpu_def.h  CPU WORD CONFIGURATION  Note #1'.
*
*
*                       (3) For 32-bit values :
*
*                             b31  b30  b29  ...  b04  b03  b02  b01  b00    # Leading Zeros
*                             ---  ---  ---       ---  ---  ---  ---  ---    ---------------
*                              1    x    x         x    x    x    x    x            0
*                              0    1    x         x    x    x    x    x            1
*                              0    0    1         x    x    x    x    x            2
*                              :    :    :         :    :    :    :    :            :
*                              :    :    :         :    :    :    :    :            :
*                              0    0    0         1    x    x    x    x           27
*                              0    0    0         0    1    x    x    x           28
*                              0    0    0         0    0    1    x    x           29
*                              0    0    0         0    0    0    1    x           30
*                              0    0    0         0    0    0    0    1           31
*                              0    0    0         0    0    0    0    0           32
*
*
*
* Note(s) : (1) This functions is used when CPU_CFG_LEAD_ZEROS_ASM_PRESENT is defined in cpu.h/cpu_cfg.h.
*               This function has been implemented to use the Count Leading Zeros (CLZ) instruction
*               present in the M4K core.
*           (2) This function was located here because it is hardware dependant, and is part of the port.
*               The function prototype exists in cpu.h.  It is needed because this assembler routine is
*               called from C.
*           (3) See MIPS documentation for explanation of why the same GP register is used for source and
*               desitination of the clz instruction.
*********************************************************************************************************
*/

    .ent CPU_CntLeadZeros
CPU_CntLeadZeros:

    clz   $4, $4                               /* Count leading zeros in value passed into GP $4       */
    jr    $31
    addu  $2, $4, $0                           /* Result is returned to caller in GP $2                */

    .end CPU_CntLeadZeros
