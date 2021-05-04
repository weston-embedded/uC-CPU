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
*                                      CPU CACHE IMPLEMENTATION
*                    Generic ARMv7 L1 Cache and External L2C310 L2 Cache Controller
*
* Filename : cpu_cache_armv7_generic_l1_l2c310_l2.c
* Version  : V1.32.01
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/
#include <cpu.h>
#include "../../../cpu_cache.h"
#include <lib_def.h>

#ifndef CPU_CACHE_CFG_L2C310_BASE_ADDR
#error  "CPU_CFG.H, Missing CPU_CACHE_CFG_L2C310_BASE_ADDR: Base address of L2C310 Level 2 cache controller"
#endif


#ifdef __cplusplus
extern  "C" {
#endif

/*
*********************************************************************************************************
*                                        EXTERNAL DECLARATIONS
*********************************************************************************************************
*/

CPU_INT32U  CPU_DCache_LineSizeGet (void);


/*
*********************************************************************************************************
*                                       LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/

CPU_INT32U  CPU_Cache_Linesize;                                 /* Cache line size.                                     */
CPU_INT32U  CPU_Cache_PL310BaseAddr;                            /* PL310 L2 cache controller base addr.                 */


/*
*********************************************************************************************************
*                                         CPU_CacheMGMTInit()
*
* Description : Initialize cpu cache module.
*
* Argument(s) : none.
*
* Return(s)   : none.
*
* Note(s)     : none.
*********************************************************************************************************
*/

void  CPU_Cache_Init(void)
{
    CPU_Cache_Linesize      = CPU_DCache_LineSizeGet();
    CPU_Cache_PL310BaseAddr = CPU_CACHE_CFG_L2C310_BASE_ADDR;
}

#ifdef __cplusplus
}
#endif
