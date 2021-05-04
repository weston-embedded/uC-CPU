;********************************************************************************************************
;                                               uC/CPU
;                                    CPU CONFIGURATION & PORT LAYER
;
;                    Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
;
;                                 SPDX-License-Identifier: APACHE-2.0
;
;               This software is subject to an open source license and is distributed by
;                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
;                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
;
;********************************************************************************************************

;********************************************************************************************************
;
;                                            CPU PORT FILE
;
;                                               ARMv8-A
;                                           ARM C Compiler
;
; Filename : cpu_a.s
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                           PUBLIC FUNCTIONS
;********************************************************************************************************

        EXPORT  CPU_IntDis
        EXPORT  CPU_IntEn

        EXPORT  CPU_SR_Save
        EXPORT  CPU_SR_Restore

        EXPORT  CPU_WaitForInt
        EXPORT  CPU_WaitForEvent

        EXPORT  CPU_CntLeadZeros
        EXPORT  CPU_CntTrailZeros


;********************************************************************************************************
;                                      CODE GENERATION DIRECTIVES
;********************************************************************************************************

        AREA |.text|, CODE, READONLY, ALIGN=4
        PRESERVE8


;********************************************************************************************************
;                                    DISABLE and ENABLE INTERRUPTS
;
; Description : Disable/Enable interrupts.
;
; Prototypes  : void  CPU_IntDis(void);
;               void  CPU_IntEn (void);
;********************************************************************************************************

CPU_IntDis FUNCTION

        MSR     DAIFSet, #3
        DSB     SY
        RET

        ENDFUNC


CPU_IntEn FUNCTION

        DSB     SY
        MSR     DAIFClr, #3
        RET

        ENDFUNC


;********************************************************************************************************
;                                      CRITICAL SECTION FUNCTIONS
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

CPU_SR_Save FUNCTION

        MRS      x0, DAIF
        MSR      DAIFSet, #3
        DSB      SY
        RET

        ENDFUNC


CPU_SR_Restore FUNCTION

        DSB     SY
        MOV     x1, #0xC0
		ANDS    x0, x0, x1
		B.NE    CPU_SR_Restore_Exit
		MSR     DAIFClr, #3
CPU_SR_Restore_Exit
        RET

        ENDFUNC


;********************************************************************************************************
;                                         WAIT FOR INTERRUPT
;
; Description : Enters sleep state, which will be exited when an interrupt is received.
;
; Prototypes  : void  CPU_WaitForInt (void)
;
; Argument(s) : none.
;********************************************************************************************************

CPU_WaitForInt FUNCTION

        DSB SY
        WFI                                     ; Wait for interrupt
        RET

        ENDFUNC


;********************************************************************************************************
;                                         WAIT FOR EXCEPTION
;
; Description : Enters sleep state, which will be exited when an exception is received.
;
; Prototypes  : void  CPU_WaitForExcept (void)
;
; Argument(s) : none.
;********************************************************************************************************

CPU_WaitForEvent FUNCTION

        DSB SY
        WFE                                     ; Wait for exception
        RET

        ENDFUNC


;********************************************************************************************************
;                                         CPU_CntLeadZeros()
;                                        COUNT LEADING ZEROS
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

CPU_CntLeadZeros FUNCTION

        CLZ     x0, x0                          ; Count leading zeros
        RET

        ENDFUNC


;********************************************************************************************************
;                                         CPU_CntTrailZeros()
;                                        COUNT TRAILING ZEROS
;
; Description : Counts the number of contiguous, least-significant, trailing zero bits before the
;                   first binary one bit in a data value.
;
; Prototype   : CPU_DATA  CPU_CntTrailZeros(CPU_DATA  val);
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
;
;               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_TRAIL_ZEROS_ASM_PRESENT is
;                   #define'd in 'cpu_cfg.h' or 'cpu.h'.
;********************************************************************************************************

CPU_CntTrailZeros FUNCTION

        RBIT    x0, x0                          ; Reverse bits
        CLZ     x0, x0                          ; Count trailing zeros
        RET

        ENDFUNC


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************

        END
