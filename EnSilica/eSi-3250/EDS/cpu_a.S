#********************************************************************************************************
#                                               uC/CPU
#                                    CPU CONFIGURATION & PORT LAYER
#
#                    Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
#
#                                 SPDX-License-Identifier: APACHE-2.0
#
#               This software is subject to an open source license and is distributed by
#                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
#                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
#
#********************************************************************************************************

#********************************************************************************************************
#
#                                             CPU PORT FILE
#
#                                           EnSilica eSi-32nn
#                                             GNU C Compiler
#
#
# Filename : cpu_a.S
# Version  : V1.32.01
#********************************************************************************************************


#********************************************************************************************************
#                                            PUBLIC FUNCTIONS
#********************************************************************************************************

    .global  CPU_IntDis                                         /* Disable interrupts.                                  */
    .global  CPU_IntEn                                          /* Enable  interrupts.                                  */

    .global  CPU_IntSrcDis                                      /* Disable specific interrupt source.                   */
    .global  CPU_IntSrcEn                                       /* Enable  specific interrupt source.                   */
    .global  CPU_IntSrcPendClr                                  /* Clear   specific pending interrupt.                  */

    .global  CPU_SR_Save                                        /* Save    CPU status word & disable interrupts.        */
    .global  CPU_SR_Restore                                     /* Restore CPU status word.                             */

    .global  CPU_CntLeadZeros                                   /* Count leading zeros.                                 */

    .global  CPU_RevBits                                        /* Reverse the bits in a data value.                    */

    .global  CPU_GetEID                                         /* Get Exception ID register.                           */
    .global  CPU_GetGP                                          /* Get Global Displacement pointer.                     */
    .global  CPU_GetTC                                          /* Get Thread Control register.                         */

    .global  CPU_TS_TmrInit                                     /* Initialize & start CPU timestamp timer.              */
    .global  CPU_TS_TmrRd                                       /* Get current CPU timestamp timer count value.         */


#********************************************************************************************************
#                                       EXTERNAL GLOBAL VARIABLES
#********************************************************************************************************

    .extern  CPU_TS_TmrFreq_Hz                                  /* CPU timestamp timer frequency (in Hz).               */


#********************************************************************************************************
#                                       CODE GENERATION DIRECTIVES
#********************************************************************************************************

    .text


#********************************************************************************************************
#                                     DISABLE and ENABLE INTERRUPTS
#
# Description : Disable/Enable interrupts.
#
# Prototypes  : void  CPU_IntDis(void);
#               void  CPU_IntEn (void);
#********************************************************************************************************
    .type       CPU_IntDis, @function
CPU_IntDis:
    DISABLE arg0
    RET

    .type       CPU_IntEn, @function
CPU_IntEn:
    ENABLE
    RET


#********************************************************************************************************
#                                  CPU INTERRUPT SOURCE DISABLE/ENABLE
#
# Description : Disable/Enable an interrupt source.
#
# Prototypes  : void  CPU_IntSrcDis(CPU_INT08U  src);
#               void  CPU_IntSrcEn (CPU_INT08U  src);
#
# Note(s)     : (1) The numbering scheme used to identify interrupts is the index defined in Table 58 of
#                   'eSi-RISC Architecture Manual'.
#********************************************************************************************************

    .type       CPU_IntSrcDis, @function
CPU_IntSrcDis:
    CMP     arg0, 8
    BLU     1f
    CMP     arg0, __interrupts__+8
    BGE     1f
    ADD     arg0, -8
    L       arg1, 1
    SL      arg1, arg0
    RCSR    arg0, Interrupt, IM
    ANDNOT  arg0, arg1
    WCSR    Interrupt, IM, arg0
1:
    RET

    .type       CPU_IntSrcEn, @function
CPU_IntSrcEn:
    CMP     arg0, 8
    BLU     1f
    CMP     arg0, __interrupts__+8
    BGE     1f
    ADD     arg0, -8
    L       arg1, 1
    SL      arg1, arg0
    RCSR    arg0, Interrupt, IM
    OR      arg0, arg1
    WCSR    Interrupt, IM, arg0
1:
    RET


#********************************************************************************************************
#                                    CPU INTERRUPT SOURCE PEND CLEAR
#
# Description : Acknowledge, or clear the pending status, of an interrupt.
#
# Prototype   : void  CPU_IntSrcPendClr(CPU_INT08U  src);
#
# Note(s)     : (1) The numbering scheme used to identify interrupts is the index defined in Table 58 of
#                   'eSi-RISC Architecture Manual'.
#********************************************************************************************************

    .type       CPU_IntSrcPendClr, @function
CPU_IntSrcPendClr:
    CMP     arg0, 8
    BLU     1f
    CMP     arg0, __interrupts__+8
    BGE     1f
    ADD     arg0, -8
    L       arg1, 1
    SL      arg1, arg0
    WCSR    Interrupt, IA, arg1
1:
    RET


#********************************************************************************************************
#                                       CRITICAL SECTION FUNCTIONS
#
# Description : Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking, the
#               state of the interrupt disable flag is stored in the local variable 'cpu_sr' & interrupts
#               are then disabled ('cpu_sr' is allocated in all functions that need to disable interrupts).
#               The previous interrupt state is restored by copying 'cpu_sr' into the CPU's status register.
#
# Prototypes  : CPU_SR  CPU_SR_Save   (void);
#               void    CPU_SR_Restore(CPU_SR  cpu_sr);
#
# Note(s)     : (1) These functions are used in general like this :
#
#                       void  Task (void  *p_arg)
#                       {
#                           CPU_SR_ALLOC();                     /* Allocate storage for CPU status register */
#                               :
#                               :
#                           CPU_CRITICAL_ENTER();               /* cpu_sr = CPU_SR_Save();                  */
#                               :
#                               :
#                           CPU_CRITICAL_EXIT();                /* CPU_SR_Restore(cpu_sr);                  */
#                               :
#                       }
#********************************************************************************************************

    .type       CPU_SR_Save, @function
CPU_SR_Save:
    DISABLE arg0
    RET

    .type       CPU_SR_Restore, @function
CPU_SR_Restore:
    RESTORE arg0
    RET


#********************************************************************************************************
#                                           CPU_CntLeadZeros()
#                                          COUNT LEADING ZEROS
#
# Description : Counts the number of contiguous, most-significant, leading zero bits before the
#                   first binary one bit in a data value.
#
# Prototype   : CPU_DATA  CPU_CntLeadZeros(CPU_DATA  val);
#
# Argument(s) : val         Data value to count leading zero bits.
#
# Return(s)   : Number of contiguous, most-significant, leading zero bits in 'val'.
#
# Note(s)     : (1) (a) Supports 32-bit data value size as configured by 'CPU_DATA' (see 'cpu.h
#                       CPU WORD CONFIGURATION  Note #1').
#
#                   (b) For 32-bit values :
#
#                             b31  b30  b29  ...  b04  b03  b02  b01  b00    # Leading Zeros
#                             ---  ---  ---       ---  ---  ---  ---  ---    ---------------
#                              1    x    x         x    x    x    x    x            0
#                              0    1    x         x    x    x    x    x            1
#                              0    0    1         x    x    x    x    x            2
#                              :    :    :         :    :    :    :    :            :
#                              :    :    :         :    :    :    :    :            :
#                              0    0    0         1    x    x    x    x           27
#                              0    0    0         0    1    x    x    x           28
#                              0    0    0         0    0    1    x    x           29
#                              0    0    0         0    0    0    1    x           30
#                              0    0    0         0    0    0    0    1           31
#                              0    0    0         0    0    0    0    0           32
#
#
#               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_LEAD_ZEROS_ASM_PRESENT is
#                   #define'd in 'cpu_cfg.h' or 'cpu.h'.
#********************************************************************************************************

    .type       CPU_CntLeadZeros, @function
CPU_CntLeadZeros:
    CLZ     arg0, arg0
    RET


#********************************************************************************************************
#                                             CPU_RevBits()
#                                             REVERSE BITS
#
# Description : Reverses the bits in a data value.
#
# Prototypes  : CPU_DATA  CPU_RevBits(CPU_DATA  val);
#
# Argument(s) : val         Data value to reverse bits.
#
# Return(s)   : Value with all bits in 'val' reversed (see Note #1).
#
# Note(s)     : (1) The final, reversed data value for 'val' is such that :
#
#                       'val's final bit  0       =  'val's original bit  N
#                       'val's final bit  1       =  'val's original bit (N - 1)
#                       'val's final bit  2       =  'val's original bit (N - 2)
#
#                               ...                           ...
#
#                       'val's final bit (N - 2)  =  'val's original bit  2
#                       'val's final bit (N - 1)  =  'val's original bit  1
#                       'val's final bit  N       =  'val's original bit  0
#********************************************************************************************************

    .type       CPU_RevBits, @function
CPU_RevBits:
    REV     arg0, arg0
    RET


#********************************************************************************************************
#                                              CPU_GetEID()
#
# Description : Read the EID CSR.
#
# Prototypes  : CPU_DATA  CPU_GetEID(void);
#
# Argument(s) : none.
#
# Return(s)   : Value of the EID CSR the Thread bank.
#
# Note(s)     : none.
#********************************************************************************************************

    .type       CPU_GetEID, @function
CPU_GetEID:
    RCSR    arg0, Thread, EID
    RET


#********************************************************************************************************
#                                              CPU_GetGP()
#
# Description : Get the Global Displacement pointer.
#
# Prototypes  : CPU_DATA  CPU_GetGP(void);
#
# Argument(s) : none.
#
# Return(s)   : Value of the gp (r31) register.
#
# Note(s)     : none.
#********************************************************************************************************

    .type       CPU_GetGP, @function
CPU_GetGP:
    MV      arg0, gp
    RET


#********************************************************************************************************
#                                              CPU_GetTC()
#
# Description : Get the Thread Control CSR.
#
# Prototypes  : CPU_DATA  CPU_GetTC(void);
#
# Argument(s) : none.
#
# Return(s)   : Value of the TC CSR the Thread bank.
#
# Note(s)     : none.
#********************************************************************************************************

    .type       CPU_GetTC, @function
CPU_GetTC:
    RCSR    arg0, Thread, TC
    RET


#********************************************************************************************************
#                                            CPU_TS_TmrInit()
#
# Description : Initialize & start CPU timestamp timer.
#
# Prototypes  : void  CPU_TS_TmrInit(void);
#
# Argument(s) : none.
#
# Return(s)   : none.
#
# Note(s)     : none.
#********************************************************************************************************

    .type       CPU_TS_TmrInit, @function
CPU_TS_TmrInit:
    L       arg0, 0
    NOT     arg0, arg0
    WCSR    CycleCounter, Wrap, arg0
    RCSR    arg0, Configuration, FREQ0
    RCSR    arg1, Configuration, FREQ1
    SL      arg1, 16
    OR      arg0, arg1
    L       arg1, (gp+[CPU_TS_TmrFreq_Hz])
    SW      (arg1), arg0
    RET


#********************************************************************************************************
#                                           CPU_TS_TmrRd()
#
# Description : Get current CPU timestamp timer count value.
#
# Prototypes  : CPU_TS_TMR  CPU_TS_TmrRd(void);
#
# Argument(s) : none.
#
# Return(s)   : Timestamp timer count.
#
# Note(s)     : none.
#********************************************************************************************************

    .type       CPU_TS_TmrRd, @function
CPU_TS_TmrRd:
    RCSR    arg0, CycleCounter, Cnt
    RET


#********************************************************************************************************
#                                     CPU ASSEMBLY PORT FILE END
#********************************************************************************************************

.end
