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
;                                               MCF5272
;                                            GNU C Compiler
;
; Filename : cpu_a.s
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                        PUBLIC DECLARATIONS
;********************************************************************************************************

        .global  CPU_SR_Save
        .global  CPU_SR_Restore


;********************************************************************************************************
;                                CPU_SR_Save() for OS_CRITICAL_METHOD #3
;
; Description : This functions implements the OS_CRITICAL_METHOD #3 function to preserve the state of the
;               interrupt disable flag in order to be able to restore it later.
;
; Arguments   : none
;
; Returns     : It is assumed that the return value is placed in the D0 register as expected by the
;               compiler.
;********************************************************************************************************

        .text

CPU_SR_Save:
        MOVE    %SR,%D0                                         /* Copy SR into D0                                      */
        MOVE.L  %D0,-(%A7)                                      /* Save D0                                              */
        ORI.L   #0x0700,%D0                                     /* Disable interrupts                                   */
        MOVE    %D0,%SR
        MOVE.L  (%A7)+,%D0                                      /* Restore original state of SR                         */
        RTS

;********************************************************************************************************
;                               CPU_SR_Restore() for OS_CRITICAL_METHOD #3
;
; Description : This functions implements the OS_CRITICAL_METHOD #function to restore the state of the
;               interrupt flag.
;
; Arguments   : cpu_sr   is the contents of the SR to restore.  It is assumed that this 'argument' is
;                        passed in the D0 register of the CPU by the compiler.
;
; Returns     : None
;********************************************************************************************************

CPU_SR_Restore:
        MOVE    %D0,%SR
        RTS


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************

        END
