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
;                                      Renesas RX Specific code
;                                          GNU RX C Compiler
;
; Filename : cpu_a.s
; Version  : V1.32.01
;********************************************************************************************************


;********************************************************************************************************
;                                           PUBLIC FUNCTIONS
;********************************************************************************************************

	.global     _set_ipl
	.global     _get_ipl
	.global     _set_intb

	.text


;********************************************************************************************************
;                                        set_ipl() & get_ipl()
;
; Description: Set or retrieve interrupt priority level.
;********************************************************************************************************

_set_ipl:
    PUSH R2
    MVFC PSW, R2
    AND  #-0F000001H, R2
    SHLL #24, R1
    OR   R1, R2
    MVTC R2, PSW
    POP  R2
    RTS


_get_ipl:
    MVFC PSW, R1
    SHLR #24, R1
    AND  #15, R1
    RTS


;********************************************************************************************************
;                                            set_intb()
;
; Description: Set the interrupt base register
;********************************************************************************************************

_set_intb:
    PUSH R2
    mvtc R1, intb
    POP  R2
    RTS


    .END
