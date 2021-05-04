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
*                                           Synopsys ARC EM6
*                                     DesignWare ARC C/C++ Compiler
*
*
* Filename : cpu_c.c
* Version  : V1.32.01
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                             INCLUDE FILES
*********************************************************************************************************
*/

#include  <arc/arc_intrinsics.h>
#include  <cpu.h>
#include  <cpu_core.h>


#ifdef __cplusplus
extern  "C" {
#endif


/*
*********************************************************************************************************
*                                             LOCAL DEFINES
*********************************************************************************************************
*/

#define  CPU_USECS_PER_SEC                     (1000000ULL)
#define  CPU_INT_PRIO_SHIFT                    (1u)
#define  CPU_INT_PRIO_WIDTH                    (0xFu)


/*
*********************************************************************************************************
*                                            LOCAL CONSTANTS
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            LOCAL DATA TYPES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                              LOCAL TABLES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                         LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                       LOCAL FUNCTION PROTOTYPES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                       LOCAL CONFIGURATION ERRORS
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                           CPU_IntLevelSet()
*
* Description : Set the interrupt priority operating level.
*
* Argument(s) : level   interrupt priority operating level.
*
* Return(s)   : None.
*
* Note(s)     : None.
*********************************************************************************************************
*/

void  CPU_IntLevelSet (CPU_INT08U  level)
{
    level &= CPU_INT_PRIO_WIDTH;
    _kflag(level << CPU_INT_PRIO_SHIFT);
}


/*
*********************************************************************************************************
*                                         CPU_IntVectTableSet()
*
* Description : Set Interrupt Vector Table base pointer.
*
* Argument(s) : p_table     pointer to base of interrupt vector table.
*
* Return(s)   : None.
*
* Note(s)     : (1) Must be 1Kbyte aligned.
*********************************************************************************************************
*/

void  CPU_IntVectTableSet (CPU_FNCT_VOID  *p_table)
{
    CPU_SR_ALLOC();


    CPU_CRITICAL_ENTER();
    CPU_AR_WR(CPU_AR_INT_VECTOR_BASE, (CPU_INT32U)p_table);
    CPU_CRITICAL_EXIT();
}


/*
*********************************************************************************************************
*                                            CPU_IntSrcDis()
*
* Description : Disable an interrupt source.
*
* Argument(s) : src     interrupt source to disable.
*
* Return(s)   : None.
*
* Note(s)     : None.
*********************************************************************************************************
*/

void  CPU_IntSrcDis (CPU_INT08U  src)
{
    CPU_SR_ALLOC();


    if ((src >= CPU_INT_INT0) &&
        (src <  CPU_INT_NBR)) {
        CPU_CRITICAL_ENTER();
        CPU_AR_WR(CPU_AR_IRQ_SELECT, src);
        CPU_AR_WR(CPU_AR_IRQ_ENABLE, 0);
        CPU_CRITICAL_EXIT();
    }

    return;
}


/*
*********************************************************************************************************
*                                            CPU_IntSrcEn()
*
* Description : Enable an interrupt source.
*
* Argument(s) : src     interrupt source to enable.
*
* Return(s)   : None.
*
* Note(s)     : None.
*********************************************************************************************************
*/

void  CPU_IntSrcEn (CPU_INT08U  src)
{
    CPU_SR_ALLOC();


    if ((src >= CPU_INT_INT0) &&
        (src <  CPU_INT_NBR)) {
        CPU_CRITICAL_ENTER();
        CPU_AR_WR(CPU_AR_IRQ_SELECT, src);
        CPU_AR_WR(CPU_AR_IRQ_ENABLE, 1);
        CPU_CRITICAL_EXIT();
    }

    return;
}


/*
*********************************************************************************************************
*                                          CPU_IntSrcPendClr()
*
* Description : Clear a pending pulse-triggered interrupt.
*
* Argument(s) : src     pulse-triggered interrupt source to clear.
*
* Return(s)   : None.
*
* Note(s)     : (1) Cannot be used for level-sensitive interrupt sources and software interrupts.
*********************************************************************************************************
*/

void  CPU_IntSrcPendClr (CPU_INT08U  src)
{
    CPU_SR_ALLOC();


    if ((src >= CPU_INT_INT0) &&
        (src <  CPU_INT_NBR)) {
        CPU_CRITICAL_ENTER();
        CPU_AR_WR(CPU_AR_IRQ_SELECT, src);
        CPU_AR_WR(CPU_AR_IRQ_PULSE_CANCEL, 1);
        CPU_CRITICAL_EXIT();
    }

    return;
}


/*
*********************************************************************************************************
*                                          CPU_IntSrcPrioSet()
*
* Description : Set the priority of an interrupt source.
*
* Argument(s) : src     interrupt source to set priority.
*
*               prio    the priority.
*
* Return(s)   : None.
*
* Note(s)     : None.
*********************************************************************************************************
*/

void  CPU_IntSrcPrioSet (CPU_INT08U  src,
                         CPU_INT08U  prio)
{
    CPU_SR_ALLOC();


    if ((src >= CPU_INT_INT0) &&
        (src <  CPU_INT_NBR)) {
        CPU_CRITICAL_ENTER();
        CPU_AR_WR(CPU_AR_IRQ_SELECT, src);
        CPU_AR_WR(CPU_AR_AUX_IRQ_PRIORITY, prio);
        CPU_CRITICAL_EXIT();
    }
}


/*
*********************************************************************************************************
*                                           CPU_TS_TmrInit()
*
* Description : Initialize & start CPU timestamp timer.
*
* Argument(s) : none.
*
* Return(s)   : none.
*
* Note(s)     : none.
*********************************************************************************************************
*/
#if (CPU_CFG_TS_TMR_EN == DEF_ENABLED)
void  CPU_TS_TmrInit (void)
{
    /* Initialize a performance counter with 'crun' as the countable condition. */
}
#endif


/*
*********************************************************************************************************
*                                            CPU_TS_TmrRd()
*
* Description : Get current CPU timestamp timer count value.
*
* Argument(s) : none.
*
* Return(s)   : Timestamp timer count.
*
* Note(s)     : none.
*********************************************************************************************************
*/

#if (CPU_CFG_TS_TMR_EN == DEF_ENABLED)
CPU_TS_TMR  CPU_TS_TmrRd (void)
{
    /* Return the snapshot of the performance counter with 'crun' as the countable condition. */
}
#endif


/*
*********************************************************************************************************
*                                           CPU_TSxx_to_uSec()
*
* Description : Convert a 32-/64-bit CPU timestamp from timer counts to microseconds.
*
* Argument(s) : ts_cnts   CPU timestamp (in timestamp timer counts [see Note #2aA]).
*
* Return(s)   : Converted CPU timestamp (in microseconds           [see Note #2aD]).
*
* Note(s)     : (1) CPU_TS32_to_uSec()/CPU_TS64_to_uSec() are application/BSP functions that MAY be
*                   optionally defined by the developer when either of the following CPU features is
*                   enabled :
*
*                   (a) CPU timestamps
*                   (b) CPU interrupts disabled time measurements
*
*                   See 'cpu_cfg.h  CPU TIMESTAMP CONFIGURATION  Note #1'
*                     & 'cpu_cfg.h  CPU INTERRUPTS DISABLED TIME MEASUREMENT CONFIGURATION  Note #1a'.
*
*               (2) (a) The amount of time measured by CPU timestamps is calculated by either of
*                       the following equations :
*
*                                                                        10^6 microseconds
*                       (1) Time measured  =   Number timer counts   *  -------------------  *  Timer period
*                                                                            1 second
*
*                                              Number timer counts       10^6 microseconds
*                       (2) Time measured  =  ---------------------  *  -------------------
*                                                Timer frequency             1 second
*
*                               where
*
*                                   (A) Number timer counts     Number of timer counts measured
*                                   (B) Timer frequency         Timer's frequency in some units
*                                                                   of counts per second
*                                   (C) Timer period            Timer's period in some units of
*                                                                   (fractional)  seconds
*                                   (D) Time measured           Amount of time measured,
*                                                                   in microseconds
*
*                   (b) Timer period SHOULD be less than the typical measured time but MUST be less
*                       than the maximum measured time; otherwise, timer resolution inadequate to
*                       measure desired times.
*
*                   (c) Specific implementations may convert any number of CPU_TS32 or CPU_TS64 bits
*                       -- up to 32 or 64, respectively -- into microseconds.
*********************************************************************************************************
*/

#if (CPU_CFG_TS_32_EN == DEF_ENABLED)
CPU_INT64U  CPU_TS32_to_uSec (CPU_TS32  ts_cnts)
{
    CPU_INT64U  time;


    time = ((CPU_INT64U)ts_cnts*(CPU_INT64U)CPU_USECS_PER_SEC)/((CPU_INT64U)CPU_TS_TmrFreq_Hz);

    return (time);
}
#endif


#if (CPU_CFG_TS_64_EN == DEF_ENABLED)
CPU_INT64U  CPU_TS64_to_uSec (CPU_TS64  ts_cnts)
{

    /* $$$$ Insert code to convert (up to) 64-bits of 64-bit CPU timestamp to microseconds (see Note #2) */

    return (0u);
}
#endif


#ifdef __cplusplus
}
#endif
