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
*                                           Atmel AVR32 UC3
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

        .file    "CPU_A"

        .section .text, "ax"

        .extern  _start


/*
*********************************************************************************************************
*                                              DEFINES
*********************************************************************************************************
*/

        .equ     CPU_SR_OFFSET,                            0    /* Status  Register offset in System Register           */
        .equ     CPU_SR_GM_OFFSET,                        16    /* Status  Register, Global Interrupt Mask Offset       */
        .equ     CPU_SR_GM_MASK,                  0x00010000    /* Status  Register, Global Interrupt Mask              */
        .equ     CPU_SR_EM_OFFSET,                        21    /* Status  Register, Exception Mask Offset              */
        .equ     CPU_SR_M0_MASK,                  0x00400000    /* Status  Register, Supervisor Execution Mode Mask     */
        .equ     CPU_SR_MX_OFFSET,                        22    /* Status  Register, Execution Mode Mask offset         */
        .equ     CPU_SR_MX_SUPERVISOR_MODE,       0x00000001    /* Status  Register, Execution Mode Supervisor          */
        .equ     CPU_COUNT_OFFSET,                0x00000108    /* Count   Register offset in System Register           */
        .equ     CPU_CONFIG0_OFFSET,              0x00000100    /* Config0 Register offset in System Register           */
        .equ     CPU_COMPARE_OFFSET,              0x0000010C    /* Compare Register offset in System Register           */


/*
*********************************************************************************************************
*                                          PUBLIC DECLARATIONS
*********************************************************************************************************
*/

        .global  CPU_SR_Save
        .global  CPU_SR_Restore
        .global  CPU_IntDis
        .global  CPU_IntEn
        .global  CPU_ExceptDis
        .global  CPU_ExceptEn
        .global  CPU_Reset
        .global  CPU_SysReg_Get_Count
        .global  CPU_SysReg_Get_Config0
        .global  CPU_SysReg_Set_Compare
        .global  CPU_SysReg_Get_Compare
        .global  CPU_CntLeadZeros


/*
*********************************************************************************************************
*                                      CRITICAL SECTION FUNCTIONS
*
* Description : These functions are used to enter and exit critical sections using Critical Method #3.
*
*                   CPU_SR  CPU_SR_Save (void)
*                          Get current global interrupt mask bit value from SR
*                          Disable interrupts
*                          Return global interrupt mask bit
*
*                   void  CPU_SR_Restore (CPU_SR  cpu_sr)
*                          Set global interrupt mask bit on SR according to parameter sr
*                          Return
*
* Argument(s) : cpu_sr      global interrupt mask status.
*
* Note(s)     : (1) Besides global interrupt mask bit, all other status register bits are kept unchanged.
*
*               (2) Two NOP are required for properly disable interrupts.
*********************************************************************************************************
*/

CPU_SR_Save:
        CSRFCZ  CPU_SR_GM_OFFSET                                /* Retrieve GM bit from SR                              */
        SRCS    R12                                             /* if (GM == 1) set R12                                 */
        SSRF    CPU_SR_GM_OFFSET                                /* set global interrupt mask (disable interrupts)       */
        NOP
        NOP
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_SR_Restore:
        PUSHM   R11                                             /* Save R11 into stack                                  */

        MFSR    R11, CPU_SR_OFFSET                              /* Retrieve current Status Register                     */
        LSR     R12, 1                                          /* Copy interrupt status to Carry                       */
        BST     R11, CPU_SR_GM_OFFSET                           /* Overwrite GM bit based on Carry                      */

        MTSR    CPU_SR_OFFSET, R11                              /* Restore Status Register GM with previous interrupt   */
                                                                /* ... status value                                     */

        POPM    R11                                             /* Restore R11 from stack                               */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


/*
*********************************************************************************************************
*                                      DISABLE/ENABLE INTERRUPTS
*
* Description : Disable/Enable interrupts by setting or clearing the global interrupt mask in the cpu
*               status register.
*
*                    void  CPU_IntDis (void)
*                           Set global interrupt mask bit on SR
*                           Return
*
*                    void  CPU_IntEn (void)
*                           Clear global interrupt mask bit on SR
*                           Return
*********************************************************************************************************
*/

CPU_IntDis:
        SSRF    CPU_SR_GM_OFFSET                                /* set global interrupt mask (disable interrupts)       */
        NOP
        NOP
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_IntEn:
        CSRF    CPU_SR_GM_OFFSET                                /* clear global interrupt mask (enable interrupts)      */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


/*
*********************************************************************************************************
*                                      DISABLE/ENABLE EXCEPTIONS
*
* Description : These functions are used to disable and enable exceptions by setting or clearing the
*               exception mask in the cpu status register.
*
*                   void  CPU_ExceptDis (void)
*                          Set exception mask bit on SR
*                          Return
*
*                   void  CPU_ExcepttEn (void)
*                          Clear exception mask bit on SR
*                          Return
*********************************************************************************************************
*/

CPU_ExceptDis:
        SSRF    CPU_SR_EM_OFFSET                                /* set exception mask (disable exceptions)              */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_ExceptEn:
        CSRF    CPU_SR_EM_OFFSET                                /* clear exceptions mask (enable exceptions)            */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


/*
*********************************************************************************************************
*                                              RESET CPU
*
* Description : This function is used to reset the CPU by returning to the reset vector.
*
*               void  CPU_Reset (void)
*                      if (current SR == 001b) {
*                          Push       PC  (START)
*                          Push clean SR  (GM | M0)
*                          RETS
*                      } else {
*                          Push clean R8  (0x08080808)
*                          Push clean R9  (0x09090909)
*                          Push clean R10 (0x10101010)
*                          Push clean R11 (0x11111111)
*                          Push clean R12 (0x00000000)
*                          Push clean LR  (0x14141414)
*                          Push       PC  (START)
*                          Push clean SR  (GM | M0)
*                          RETE
*                      }
*********************************************************************************************************
*/

CPU_Reset:
        MFSR    R8, CPU_SR_OFFSET
        BFEXTU  R8, R8, CPU_SR_MX_OFFSET, 3
        CP.W    R8, CPU_SR_MX_SUPERVISOR_MODE
        BRNE    CPU_Reset_RETE

        MOV     R8, LO(_start)
        ORH     R8, HI(_start)
        MOV     R9, LO(CPU_SR_GM_MASK | CPU_SR_M0_MASK)
        ORH     R9, HI(CPU_SR_GM_MASK | CPU_SR_M0_MASK)
        STM     --SP, R8-R9                                     /* Push PC and SR                                       */
        RETS


CPU_Reset_RETE:
        MOV     R8,  0x0808
        ORH     R8,  0x0808
        MOV     R9,  0x0909
        ORH     R9,  0x0909
        MOV     R10, 0x1010
        ORH     R10, 0x1010
        MOV     R11, 0x1111
        ORH     R11, 0x1111
        MOV     R12, 0x0000
        ORH     R12, 0x0000
        MOV     LR,  0x1414
        ORH     LR,  0x1414
        STM     --SP, R8-R12, LR                                /* Push R8-R12, LR                                      */
        MOV     R8, LO(_start)
        ORH     R8, HI(_start)
        MOV     R9, LO(CPU_SR_GM_MASK | CPU_SR_M0_MASK)
        ORH     R9, HI(CPU_SR_GM_MASK | CPU_SR_M0_MASK)
        STM     --SP, R8-R9                                     /* Push PC and SR                                       */
        RETE


/*
*********************************************************************************************************
*                                      GET/SET SYSTEM REGISTERS
*
* Description : These functions are used to get/set specific system registers.
*
*                   CPU_INT32U   CPU_SysReg_Get_Count (void)
*                   CPU_INT32U   CPU_SysReg_Get_Config0 (void)
*                   CPU_INT32U   CPU_SysReg_Get_Compare (void)
*                   void         CPU_SysReg_Set_Compare (CPU_INT32U value)
*********************************************************************************************************
*/

CPU_SysReg_Get_Count:
        MFSR    R12, CPU_COUNT_OFFSET                           /* Retrieve COUNT system register                       */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_SysReg_Get_Config0:
        MFSR    R12, CPU_CONFIG0_OFFSET                         /* Retrieve CONFIG0 system register                     */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_SysReg_Get_Compare:
        MFSR    R12, CPU_COMPARE_OFFSET                         /* Retrieve COMPARE system register                     */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


CPU_SysReg_Set_Compare:
        MTSR    CPU_COMPARE_OFFSET, R12                         /* Save COMPARE system register                         */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


/*
*********************************************************************************************************
*                                         CPU_CntLeadZeros()
*                                        COUNT LEADING ZEROS
*
* Description : Counts the number of contiguous, most-significant, leading zero bits before the
*                   first binary one bit in a data value.
*
* Prototype   : CPU_DATA  CPU_CntLeadZeros(CPU_DATA  val);
*
* Argument(s) : val         Data value to count leading zero bits.
*
* Return(s)   : Number of contiguous, most-significant, leading zero bits in 'val'.
*
* Note(s)     : (1) (a) Supports 32-bit data value size as configured by 'CPU_DATA' (see 'cpu.h
*                       CPU WORD CONFIGURATION  Note #1').
*
*                   (b) For 32-bit values :
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
*               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_LEAD_ZEROS_ASM_PRESENT
*                   is #define'd in 'cpu_cfg.h' or 'cpu.h'.
*********************************************************************************************************
*/

CPU_CntLeadZeros:
        CLZ     R12, R12                                        /* Count leading zeros                                  */
        MOV     PC, LR                                          /* Restore Program Counter (return)                     */


/*
*********************************************************************************************************
*                                     CPU ASSEMBLY PORT FILE END
*********************************************************************************************************
*/
