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
;                                             CPU PORT FILE
;
;                                                TI C28x
;                                           TI C/C++ Compiler
;
;
; Filename : cpu_a.asm
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                           PUBLIC FUNCTIONS
;********************************************************************************************************

    .def   _CPU_IntDis
    .def   _CPU_IntEn

    .def   _CPU_SR_Save
    .def   _CPU_SR_Restore

    .def   _CPU_CntLeadZeros

    .def   _CPU_RevBits


;********************************************************************************************************
;                                                EQUATES
;********************************************************************************************************


;********************************************************************************************************
;                                      CODE GENERATION DIRECTIVES
;********************************************************************************************************
                                                                ; Set text section and reset local labels.
    .text
    .newblock


;********************************************************************************************************
;                                      DISABLE/ENABLE INTERRUPTS
;
; Description : Disable/Enable interrupts.
;
; Prototypes  : void  CPU_IntDis(void);
;               void  CPU_IntEn (void);
;********************************************************************************************************

    .asmfunc
_CPU_IntDis:
    DINT
    LRETR
    .endasmfunc

    .asmfunc
_CPU_IntEn:
    EINT
    LRETR
    .endasmfunc


;********************************************************************************************************
;                                  SAVE/RESTORE CPU STATUS REGISTER
;
; Description : Save/Restore the state of CPU interrupts, if possible.
;
;               (1) (c) For CPU_CRITICAL_METHOD_STATUS_LOCAL, the state of the interrupt status flag is
;                       stored in the local variable 'cpu_sr' & interrupts are then disabled ('cpu_sr' is
;                       allocated in all functions that need to disable interrupts).  The previous interrupt
;                       status state is restored by copying 'cpu_sr' into the CPU's status register.
;
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
    .asmfunc
_CPU_SR_Save:
    PUSH    ST1
    DINT
    POP    @AL
    AND     AL, #1
    LRETR
    .endasmfunc

    .asmfunc
_CPU_SR_Restore:
    PUSH    ST1
    POP     AR0
    AND     AR0, #0xFFFE
    OR      AL, AR0
    PUSH    AL
    POP     ST1
    LRETR
    .endasmfunc


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
; Note(s)     : (1) (a) Supports up to the following data value sizes, depending on the configured
;                       size of 'CPU_DATA' (see 'cpu.h  CPU WORD CONFIGURATION  Note #1') :
;
;                       (1)  8-bits
;                       (2) 16-bits
;                       (3) 32-bits
;                       (4) 64-bits
;
;                   (b) (1) For  8-bit values :
;
;                                  b07  b06  b05  b04  b03  b02  b01  b00    # Leading Zeros
;                                  ---  ---  ---  ---  ---  ---  ---  ---    ---------------
;                                   1    x    x    x    x    x    x    x            0
;                                   0    1    x    x    x    x    x    x            1
;                                   0    0    1    x    x    x    x    x            2
;                                   0    0    0    1    x    x    x    x            3
;                                   0    0    0    0    1    x    x    x            4
;                                   0    0    0    0    0    1    x    x            5
;                                   0    0    0    0    0    0    1    x            6
;                                   0    0    0    0    0    0    0    1            7
;                                   0    0    0    0    0    0    0    0            8
;
;
;                       (2) For 16-bit values :
;
;                             b15  b14  b13  ...  b04  b03  b02  b01  b00    # Leading Zeros
;                             ---  ---  ---       ---  ---  ---  ---  ---    ---------------
;                              1    x    x         x    x    x    x    x            0
;                              0    1    x         x    x    x    x    x            1
;                              0    0    1         x    x    x    x    x            2
;                              :    :    :         :    :    :    :    :            :
;                              :    :    :         :    :    :    :    :            :
;                              0    0    0         1    x    x    x    x           11
;                              0    0    0         0    1    x    x    x           12
;                              0    0    0         0    0    1    x    x           13
;                              0    0    0         0    0    0    1    x           14
;                              0    0    0         0    0    0    0    1           15
;                              0    0    0         0    0    0    0    0           16
;
;
;                       (3) For 32-bit values :
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
;                       (4) For 64-bit values :
;
;                             b63  b62  b61  ...  b04  b03  b02  b01  b00    # Leading Zeros
;                             ---  ---  ---       ---  ---  ---  ---  ---    ---------------
;                              1    x    x         x    x    x    x    x            0
;                              0    1    x         x    x    x    x    x            1
;                              0    0    1         x    x    x    x    x            2
;                              :    :    :         :    :    :    :    :            :
;                              :    :    :         :    :    :    :    :            :
;                              0    0    0         1    x    x    x    x           59
;                              0    0    0         0    1    x    x    x           60
;                              0    0    0         0    0    1    x    x           61
;                              0    0    0         0    0    0    1    x           62
;                              0    0    0         0    0    0    0    1           63
;                              0    0    0         0    0    0    0    0           64
;
;               (2) MUST be defined in 'cpu_a.asm' (or 'cpu_c.c') if CPU_CFG_LEAD_ZEROS_ASM_PRESENT
;                   is #define'd in 'cpu_cfg.h' or 'cpu.h'.
;********************************************************************************************************

    .asmfunc
_CPU_CntLeadZeros:
    MOV     AH, AL
    AND     AL, #0x8000
    SBF     $1, NEQ
    OR      AL, #0xFFFF
    CSB     ACC
    MOV     AL, T
    ADD     AL, #1
    LRETR
$1:
    MOV     AL, #0
    LRETR
    .endasmfunc


;********************************************************************************************************
;                                            CPU_RevBits()
;                                            REVERSE BITS
;
; Description : Reverses the bits in a data value.
;
; Prototypes  : CPU_DATA  CPU_RevBits(CPU_DATA  val);
;
; Argument(s) : val         Data value to reverse bits.
;
; Return(s)   : Value with all bits in 'val' reversed (see Note #1).
;
; Note(s)     : (1) The final, reversed data value for 'val' is such that :
;
;                       'val's final bit  0       =  'val's original bit  N
;                       'val's final bit  1       =  'val's original bit (N - 1)
;                       'val's final bit  2       =  'val's original bit (N - 2)
;
;                               ...                           ...
;
;                       'val's final bit (N - 2)  =  'val's original bit  2
;                       'val's final bit (N - 1)  =  'val's original bit  1
;                       'val's final bit  N       =  'val's original bit  0
;********************************************************************************************************

    .asmfunc
_CPU_RevBits:
    FLIP    AL
    LRETR
    .endasmfunc


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************
    .end
