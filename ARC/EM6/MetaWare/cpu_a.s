;********************************************************************************************************
;                                               uC/CPU
;                                   CPU CONFIGURATION & PORT LAYER
;
;                   Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
;
;                                SPDX-License-Identifier: APACHE-2.0
;
;              This software is subject to an open source license and is distributed by
;               Silicon Laboratories Inc. pursuant to the terms of the Apache License,
;                   Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
;
;********************************************************************************************************

;********************************************************************************************************
;
;                                             CPU PORT FILE
;
;                                           Synopsys ARC EM6
;                                     DesignWare ARC C/C++ Compiler
;
;
; Filename : cpu_a.s
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                            PUBLIC FUNCTIONS
;********************************************************************************************************

    .global  CPU_IntDis                                         /* Disable interrupts.                                  */
    .global  CPU_IntEn                                          /* Enable  interrupts.                                  */

    .global  CPU_SR_Save                                        /* Save    CPU status word & disable interrupts.        */
    .global  CPU_SR_Restore                                     /* Restore CPU status word.                             */

    .global  CPU_CntLeadZeros                                   /* Count leading  zeros.                                */
    .global  CPU_CntTrailZeros                                  /* Count trailing zeros.                                */

    .global  CPU_TS_TmrInit                                     /* Initialize & start CPU timestamp timer.              */
    .global  CPU_TS_TmrRd                                       /* Get current CPU timestamp timer count value.         */


;********************************************************************************************************
;                                       EXTERNAL GLOBAL VARIABLES
;********************************************************************************************************

;    .extern  CPU_TS_TmrFreq_Hz                                  /* CPU timestamp timer frequency (in Hz).               */


;********************************************************************************************************
;                                                MACROS
;********************************************************************************************************

;********************************************************************************************************
;                                               FUNCTION
;
; Description : This macro declares a symbol of type function and aligns it to 4-bytes.
;
; Arguments   : fname   function to declare.
;
; Note(s)     : none.
;********************************************************************************************************

.macro  FUNCTION, fname
    .type   \&fname, @function
    .align  4
    \&fname:
.endm


;********************************************************************************************************
;                                       CODE GENERATION DIRECTIVES
;********************************************************************************************************

    .text


;********************************************************************************************************
;                                     DISABLE and ENABLE INTERRUPTS
;
; Description : Disable/Enable interrupts.
;
; Prototypes  : void  CPU_IntDis(void);
;               void  CPU_IntEn (void);
;********************************************************************************************************

FUNCTION CPU_IntDis
    CLRI
    J_S   [%blink]

FUNCTION CPU_IntEn
    SETI
    J_S   [%blink]


;********************************************************************************************************
;                                       CRITICAL SECTION FUNCTIONS
;
; Description : Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking, the
;               state of the interrupt disable flag is stored in the local variable 'cpu_sr' & interrupts
;               are then disabled ('cpu_sr' is allocated in all functions that need to disable interrupts).
;               The previous interrupt state is restored by copying 'cpu_sr' into the CPU's status register.
;
; Prototypes  : CPU_SR  CPU_SR_Save   (void);
;               void    CPU_SR_Restore(CPU_SR  cpu_sr);
;
; Note(s)     : (1) These functions are used in general like this :
;
;                       void  Task (void  *p_arg)
;                       {
;                           CPU_SR_ALLOC();                     /* Allocate storage for CPU status register */
;                               :
;                               :
;                           CPU_CRITICAL_ENTER();               /* cpu_sr = CPU_SR_Save();                  */
;                               :
;                               :
;                           CPU_CRITICAL_EXIT();                /* CPU_SR_Restore(cpu_sr);                  */
;                               :
;                       }
;********************************************************************************************************

FUNCTION CPU_SR_Save
    CLRI  %r0
    J_S   [%blink]

FUNCTION CPU_SR_Restore
    SETI  %r0
    J_S   [%blink]


;********************************************************************************************************
;                                           CPU_CntLeadZeros()
;                                          COUNT LEADING ZEROS
;
; Description : Counts the number of contiguous, most-significant, leading zero bits before the
;                   first binary one bit in a data value.
;
; Prototype   : CPU_DATA  CPU_CntLeadZeros(CPU_DATA  val);
;
; Argument(s) : val         Data value to count leading zero bits.
;
; Return(s)   : Number of contiguous, most-significant, leading zero bits in 'val'.
;
; Note(s)     : (1) (a) Supports 32-bit data value size as configured by 'CPU_DATA' (see 'cpu.h
;                       CPU WORD CONFIGURATION  Note #1').
;
;                   (b) For 32-bit values :
;
;                             b31  b30  b29  ...  b04  b03  b02  b01  b00    # Leading Zeros
;                             ---  ---  ---       ---  ---  ---  ---  ---    ---------------
;                              1    x    x         x    x    x    x    x            0
;                              0    1    x         x    x    x    x    x            1
;                              0    0    1         x    x    x    x    x            2
;                              :    :    :         :    :    :    :    :            :
;                              :    :    :         :    :    :    :    :            :
;                              0    0    0         1    x    x    x    x           27
;                              0    0    0         0    1    x    x    x           28
;                              0    0    0         0    0    1    x    x           29
;                              0    0    0         0    0    0    1    x           30
;                              0    0    0         0    0    0    0    1           31
;                              0    0    0         0    0    0    0    0           32
;
;
;               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_LEAD_ZEROS_ASM_PRESENT is
;                   #define'd in 'cpu_cfg.h' or 'cpu.h'.
;********************************************************************************************************

FUNCTION CPU_CntLeadZeros
    MOV    %r1, 31
    FLS.F  %r0, %r0
    MOV.Z  %r0, -1
    SUB    %r0, %r1, %r0
    J_S    [%blink]


;********************************************************************************************************
;                                          CPU_CntTrailZeros()
;                                         COUNT TRAILING ZEROES
;
; Description : Count the number of contiguous, least-significant, trailing zero bits in a data value.
;
; Argument(s) : val         Data value to count trailing zero bits.
;
; Return(s)   : Number of contiguous, least-significant, trailing zero bits in 'val'.
;
; Note(s)     : (1) (a) Supports 32-bit data value size as configured by 'CPU_DATA' (see 'cpu.h
;                       CPU WORD CONFIGURATION  Note #1').
;
;                   (b) For 32-bit values :
;
;                             b31  b30  b29  b28  b27  ...  b02  b01  b00    # Trailing Zeros
;                             ---  ---  ---  ---  ---       ---  ---  ---    ----------------
;                              x    x    x    x    x         x    x    1            0
;                              x    x    x    x    x         x    1    0            1
;                              x    x    x    x    x         1    0    0            2
;                              :    :    :    :    :         :    :    :            :
;                              :    :    :    :    :         :    :    :            :
;                              x    x    x    x    1         0    0    0           27
;                              x    x    x    1    0         0    0    0           28
;                              x    x    1    0    0         0    0    0           29
;                              x    1    0    0    0         0    0    0           30
;                              1    0    0    0    0         0    0    0           31
;                              0    0    0    0    0         0    0    0           32
;
;               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_LEAD_ZEROS_ASM_PRESENT is
;                   #define'd in 'cpu_cfg.h' or 'cpu.h'.
;********************************************************************************************************

FUNCTION CPU_CntTrailZeros
    FFS.F  %r0, %r0
    MOV.Z  %r0, 32
    J_S  [%blink]


;********************************************************************************************************
;                                            CPU_TS_TmrInit()
;
; Description : Initialize & start CPU timestamp timer.
;
; Prototypes  : void  CPU_TS_TmrInit(void);
;
; Argument(s) : none.
;
; Return(s)   : none.
;
; Note(s)     : none.
;********************************************************************************************************

FUNCTION CPU_TS_TmrInit
    J_S   [%blink]


;********************************************************************************************************
;                                           CPU_TS_TmrRd()
;
; Description : Get current CPU timestamp timer count value.
;
; Prototypes  : CPU_TS_TMR  CPU_TS_TmrRd(void);
;
; Argument(s) : none.
;
; Return(s)   : Timestamp timer count.
;
; Note(s)     : none.
;********************************************************************************************************

FUNCTION CPU_TS_TmrRd
    MOV  %r0, 0
    J_S  [%blink]


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************

.end
