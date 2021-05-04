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
;                                           Freescale MC9S12
;                                             Codewarrior
;
; Filename : cpu_a.s
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                           PUBLIC FUNCTIONS
;********************************************************************************************************

        xdef  CPU_SR_Save
        xdef  CPU_SR_Restore


;********************************************************************************************************
;                                               EQUATES
;********************************************************************************************************


;********************************************************************************************************
;                                  SAVE THE CCR AND DISABLE INTERRUPTS
;                                                  &
;                                              RESTORE CCR
;
; Description : These function implements OS_CRITICAL_METHOD #3
;
; Arguments   : The function prototypes for the two functions are:
;               1) CPU_SR  CPU_SR_Save(void);
;                             where CPU_SR is the contents of the CCR register prior to disabling
;                             interrupts.
;               2) void    CPU_SR_Restore(CPU_SR cpu_sr);
;                             'cpu_sr' the the value of the CCR to restore.
;
; Note(s)     : 1) It's assumed that the compiler uses the D register to pass a single 16-bit argument
;                  to and from an assembly language function.
;********************************************************************************************************

CPU_SR_Save:
    tfr  ccr,b                         ; It's assumed that 8-bit return value is in register B
    sei                                ; Disable interrupts
    rtc                                ; Return to caller with D containing the previous CCR

CPU_SR_Restore:
    tfr  b,ccr                         ; B contains the CCR value to restore, move to CCR
    rtc


;********************************************************************************************************
;                                     CPU ASSEMBLY PORT FILE END
;********************************************************************************************************
