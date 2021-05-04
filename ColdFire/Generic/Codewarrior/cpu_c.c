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
*                                            CPU PORT FILE
*
*                                              ColdFire
*                                             Codewarrior
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

#define    MICRIUM_SOURCE
#include  <cpu.h>
#include  <cpu_core.h>

#ifdef __cplusplus
extern  "C" {
#endif


/*
*********************************************************************************************************
*                                           LOCAL VARIABLES
*********************************************************************************************************
*/

CPU_INT32U  CPU_VBR_Ptr;


/*
*********************************************************************************************************
*                                            CPU_VectGet()
*                                           GET ISR VECTOR
*
* Description : This function is called to get the address of the exception handler specified by 'vect'.
*
* Argument(s) : vect        Vector number to retrieve handler.
*
* Return(s)   : none.
*
* Note(s)     : (1) Interrupts are disabled during this call.
*********************************************************************************************************
*/

void  *CPU_VectGet (CPU_INT16U vect)
{
    CPU_ADDR  addr;
    CPU_SR_ALLOC();


    CPU_CRITICAL_ENTER();
    addr = *(CPU_ADDR *)(CPU_VBR_Ptr + (CPU_INT16U)vect * 4);
    CPU_CRITICAL_EXIT();

    return ((void *)addr);
}


/*
*********************************************************************************************************
*                                            CPU_VectSet()
*                                           SET ISR VECTOR
*
* Description : This function is called to set the contents of an exception vector.  The function assumes
*               that the VBR (Vector Base Register) is set to 0x00000000.
*
* Argument(s) : vect        is the vector number.
*
*               addr        is the address of the ISR handler.
*
* Return(s)   : none.
*
* Note(s)     : (1) Interrupts are disabled during this call.
*********************************************************************************************************
*/

void  CPU_VectSet (CPU_INT16U vect, void (*vect_addr)(void))
{
    CPU_ADDR  *pvect;
    CPU_SR_ALLOC();


    CPU_CRITICAL_ENTER();
    pvect = (CPU_ADDR *)(CPU_VBR_Ptr + (CPU_INT16U)vect * 4);
   *pvect = (CPU_ADDR  ) vect_addr;
    CPU_CRITICAL_EXIT();
}

#ifdef __cplusplus
}
#endif
