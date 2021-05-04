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
*                                              Microblaze
*                                                 GNU
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
#include  <mb_interface.h>

#ifdef __cplusplus
extern  "C" {
#endif


/*
*********************************************************************************************************
*                                           LOCAL VARIABLES
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                       CPU_FlushDCache()
*
* Description : Flush a specific range in the cache memory
*
* Argument(s) :     addr    the start address of the memory area to flush
*                   len     the size of the memory area to flush
*
* Return(s)   : none.
*
* Note(s)     : The function uses microblaze_flush_dcache_range() which is part of Xilinx libraries
*********************************************************************************************************
*/

void  CPU_CacheDataFlush (void       *addr,
                          CPU_INT32U  len)
{
     microblaze_flush_dcache_range((CPU_INT32S)addr, len);
}

/*
*********************************************************************************************************
*                                       CPU_InvalidateDCache()
*
* Description : Invalide a specific range in the cache memory
*
* Argument(s) :     addr    the start address of the memory area to invalidate
*                   len     the size of the memory area to invalidate
*
* Return(s)   : none.
*
* Note(s)     : The function uses microblaze_invalidate_dcache_range() which is part of Xilinx libraries
*********************************************************************************************************
*/

void  CPU_CacheDataInvalidate (void        *addr,
                               CPU_INT32U   len)
{
     microblaze_invalidate_dcache_range((CPU_INT32S)addr, len);
}

#ifdef __cplusplus
}
#endif
