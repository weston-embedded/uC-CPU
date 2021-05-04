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
*                                             CPU PORT FILE
*
*                                                TI C28x
*                                           TI C/C++ Compiler
*
*
* Filename : cpu_c.c
* Version  : V1.32.01
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/

#include  <cpu.h>
#include  <cpu_core.h>


#ifdef __cplusplus
extern  "C" {
#endif


/*
*********************************************************************************************************
*                                            LOCAL DEFINES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                           LOCAL CONSTANTS
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                          LOCAL DATA TYPES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            LOCAL TABLES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                       LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                      LOCAL FUNCTION PROTOTYPES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                     LOCAL CONFIGURATION ERRORS
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                           CPU_IntSrcDis()
*
* Description : Disable an interrupt source.
*
* Argument(s) : int_id      Interrupt source in interrupt enable register.
*
* Return(s)   : none.
*
* Note(s)     : (1) The RESET interrupt cannot be disabled.
*********************************************************************************************************
*/

void  CPU_IntSrcDis (CPU_DATA  bit)
{
    CPU_SR_ALLOC();


    if (bit <= CPU_INT_RTOSINT) {
        CPU_CRITICAL_ENTER();
        IER = IER & ~(1u << (bit-1));
        CPU_CRITICAL_EXIT();
    }
}


/*
*********************************************************************************************************
*                                            CPU_IntSrcEn()
*
* Description : Enable an interrupt source.
*
* Argument(s) : int_id      Interrupt source in interrupt enable register.
*
* Return(s)   : none.
*
* Note(s)     : none.
*********************************************************************************************************
*/

void  CPU_IntSrcEn (CPU_DATA  bit)
{
    CPU_SR_ALLOC();


    if (bit <= CPU_INT_RTOSINT) {
        CPU_CRITICAL_ENTER();
        IER = IER | (1u << (bit-1));
        CPU_CRITICAL_EXIT();
    }
}


/*
*********************************************************************************************************
*                                          CPU_IntSrcPendClr()
*
* Description : Clear a pending interrupt.
*
* Argument(s) : bit     Bit of interrupt source in interrupt enable register (see 'CPU_IntSrcDis()').
*
* Return(s)   : none.
*
* Note(s)     : none.
*********************************************************************************************************
*/

void  CPU_IntSrcPendClr (CPU_DATA  bit)
{
                                                                /* The 'AND IFR' instruction cannot be used with ...    */
                                                                /* ... anything else than a 16bit constant.             */
    switch (bit) {
        case CPU_INT_RTOSINT:
             asm("        AND IFR, #0x7FFF");
             break;


        case CPU_INT_DLOGINT:
             asm("        AND IFR, #0xBFFF");
             break;


        case CPU_INT_INT14:
             asm("        AND IFR, #0xDFFF");
             break;


        case CPU_INT_INT13:
             asm("        AND IFR, #0xEFFF");
             break;


        case CPU_INT_INT12:
             asm("        AND IFR, #0xF7FF");
             break;


        case CPU_INT_INT11:
             asm("        AND IFR, #0xFBFF");
             break;


        case CPU_INT_INT10:
             asm("        AND IFR, #0xFDFF");
             break;


        case CPU_INT_INT9:
             asm("        AND IFR, #0xFEFF");
             break;


        case CPU_INT_INT8:
             asm("        AND IFR, #0xFF7F");
             break;


        case CPU_INT_INT7:
             asm("        AND IFR, #0xFFBF");
             break;


        case CPU_INT_INT6:
             asm("        AND IFR, #0xFFDF");
             break;


        case CPU_INT_INT5:
             asm("        AND IFR, #0xFFEF");
             break;


        case CPU_INT_INT4:
             asm("        AND IFR, #0xFFF7");
             break;


        case CPU_INT_INT3:
             asm("        AND IFR, #0xFFFB");
             break;


        case CPU_INT_INT2:
             asm("        AND IFR, #0xFFFD");
             break;


        case CPU_INT_INT1:
             asm("        AND IFR, #0xFFFE");
             break;


        default:                                                /* 'default' case intentionally empty.                  */
             break;
    }
}


#ifdef __cplusplus
}
#endif
