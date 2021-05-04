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
;                                              Fujitsu FR
;                                           Softune Compiler
;
; Filename : cpu_a.asm
; Version  : V1.32.01
;********************************************************************************************************

        .PROGRAM    CPU_A


;********************************************************************************************************
;                                           PUBLIC FUNCTIONS
;********************************************************************************************************

        .EXPORT     _CPU_SR_Save
        .EXPORT     _CPU_SR_Restore

        .section    CODE, code, align=4


;********************************************************************************************************
;                                   CRITICAL SECTION FUNCTIONS
;
; Description : Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking you
;               would store the state of the interrupt disable flag in the local variable 'cpu_sr' and then
;               disable interrupts.  You would restore the interrupt disable state by copying back 'cpu_sr'
;               into the CPU's status register.
;
; Prototypes  : CPU_SR  CPU_SR_Save   (void);
;               void    CPU_SR_Restore(CPU_SR cpu_sr);
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


_CPU_SR_Save:
        MOV         PS, R4                   ; Save state of PS
        ANDCCR      #0xEF                    ; Disable interrupts
        RET

_CPU_SR_Restore:
        MOV         R4, PS                   ; Restore state of PS
        RET


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************

        .END
