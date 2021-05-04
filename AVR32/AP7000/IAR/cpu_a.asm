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
*                                          Atmel AVR32 AP7000
*                                            IAR C Compiler
*
* Filename : cpu_a.asm
* Version  : V1.32.01
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                             ASM HEADER
*********************************************************************************************************
*/

        MODULE  CPU_A

        RSEG    CODE32:CODE


/*
*********************************************************************************************************
*                                              DEFINES
*********************************************************************************************************
*/

CPU_SR_OFFSET              EQU                             0    /* Status  Register offset in System Register           */
CPU_SR_GM_OFFSET           EQU                            16    /* Status  Register, Global Interrupt Mask Offset       */
CPU_SR_EM_OFFSET           EQU                            21    /* Status  Register, Exception Mask Offset              */
CPU_COUNT_OFFSET           EQU                    0x00000108    /* Count   Register offset in System Register           */
CPU_CONFIG0_OFFSET         EQU                    0x00000100    /* Config0 Register offset in System Register           */
CPU_COMPARE_OFFSET         EQU                    0x0000010C    /* Compare Register offset in System Register           */


/*
*********************************************************************************************************
*                                          PUBLIC DECLARATIONS
*********************************************************************************************************
*/

        PUBLIC  CPU_SR_Save
        PUBLIC  CPU_SR_Restore
        PUBLIC  CPU_IntDis
        PUBLIC  CPU_IntEn
        PUBLIC  CPU_ExceptDis
        PUBLIC  CPU_ExceptEn
        PUBLIC  CPU_SysReg_Get_Count
        PUBLIC  CPU_SysReg_Get_Config0
        PUBLIC  CPU_SysReg_Set_Compare
        PUBLIC  CPU_SysReg_Get_Compare
        PUBLIC  CPU_CntLeadZeros


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
*               (2) Six NOP are required for properly disable interrupts.
*********************************************************************************************************
*/

CPU_SR_Save:
        CSRFCZ  CPU_SR_GM_OFFSET                                /* Retrieve GM bit from SR                              */
        SRCS    R12                                             /* if (GM == 1) set R12                                 */
        SSRF    CPU_SR_GM_OFFSET                                /* set global interrupt mask (disable interrupts)       */
        NOP
        NOP
        NOP
        NOP
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
        NOP
        NOP
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

                END
