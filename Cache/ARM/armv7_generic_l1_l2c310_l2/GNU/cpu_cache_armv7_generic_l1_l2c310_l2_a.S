@********************************************************************************************************
@                                               uC/CPU
@                                    CPU CONFIGURATION & PORT LAYER
@
@                    Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
@
@                                 SPDX-License-Identifier: APACHE-2.0
@
@               This software is subject to an open source license and is distributed by
@                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
@                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
@
@********************************************************************************************************

@********************************************************************************************************
@
@                                       CPU CACHE IMPLEMENTATION
@                    Generic ARMv7 L1 Cache and External L2C310 L2 Cache Controller
@                                            GNU C Compiler
@
@ Filename : cpu_cache_armv7_generic_l1_l2c310_l2_a.S
@ Version  : V1.32.01
@********************************************************************************************************

@********************************************************************************************************
@                                           MACROS AND DEFINIITIONS
@********************************************************************************************************


    .code 32


.equ CPU_CACHE_L2C_REG7_CACHE_SYNC,      0x730
.equ CPU_CACHE_L2C_REG7_CACHE_INV_PA,    0x770
.equ CPU_CACHE_L2C_REG7_CACHE_INV_WAY,   0x77C
.equ CPU_CACHE_L2C_REG7_CACHE_CLEAN_PA,  0x7B0


@********************************************************************************************************
@                                           CPU_DCache_LineSizeGet()
@
@ Description : Returns the cache line size.
@
@ Prototypes  : void  CPU_DCache_LineSizeGet (void)
@
@ Argument(s) : none.
@********************************************************************************************************

.global CPU_DCache_LineSizeGet

CPU_DCache_LineSizeGet:

    MRC     p15, 0, r0, c0, c0, 1
    AND     r0, r0, #0xF0000
    LSR     r0, r0, #16
    MOV     r1, #1
    LSL     r1, r1, r0
    LSL     r0, r1, #2

    BX      lr


@********************************************************************************************************
@                                      INVALIDATE DATA CACHE RANGE
@
@ Description : Invalidate a range of data cache by MVA.
@
@ Prototypes  : void  CPU_DCache_RangeInv  (void       *p_mem,
@                                           CPU_SIZE_T  range)@
@
@ Argument(s) : p_mem    Start address of the region to invalidate.
@
@               range    Size of the region to invalidate in bytes.
@
@ Note(s)     : none.
@********************************************************************************************************

.global CPU_DCache_RangeInv

CPU_DCache_RangeInv:
    CMP  r1, #0
    BEQ  CPU_DCache_RangeInv_END

    DSB
    ADD  r1, r1, r0
    MOVW R12, #:lower16:CPU_Cache_Linesize
    MOVT R12, #:upper16:CPU_Cache_Linesize
    LDR  r12, [r12]
    SUB  r2, r12, #1
    BIC  r0, r0, r2
    MOV  r3, r0

    MOVW r2, #:lower16:CPU_Cache_PL310BaseAddr
    MOVT r2, #:upper16:CPU_Cache_PL310BaseAddr
    LDR  r2, [r2]
CPU_DCache_RangeInvL2:
    STR  r3, [r2, #CPU_CACHE_L2C_REG7_CACHE_INV_PA]
    ADD  r3, r3, r12
    CMP  r3, r1
    BLT  CPU_DCache_RangeInvL2
    DSB

CPU_DCache_RangeInvL1:
    MCR  p15,0, r0, c7, c6, 1
    ADD  r0, r0, r12
    CMP  r0, r1
    BLT  CPU_DCache_RangeInvL1
    DSB

CPU_DCache_RangeInv_END:
    BX LR


@********************************************************************************************************
@                                       FLUSH DATA CACHE RANGE
@
@ Description : Flush (clean) a range of data cache by MVA.
@
@ Prototypes  : void  CPU_DCache_RangeFlush  (void       *p_mem,
@                                             CPU_SIZE_T  range)@
@
@ Argument(s) : p_mem    Start address of the region to flush.
@
@               range    Size of the region to invalidate in bytes.
@
@ Note(s)     : none.
@********************************************************************************************************

.global CPU_DCache_RangeFlush

CPU_DCache_RangeFlush:
    CMP  r1, #0
    BEQ  CPU_DCache_RangeFlush_END

    DSB
    ADD r1, r1, r0
    MOVW R12, #:lower16:CPU_Cache_Linesize
    MOVT R12, #:upper16:CPU_Cache_Linesize
    LDR r12, [r12]
    SUB r2, r12, #1
    BIC r0, r0, r2

    MOV r3, r0
CPU_DCache_RangeFlushL1:
    MCR p15, 0, r3, c7, c14, 1
    ADD r3, r3, r12
    CMP r3, r1
    BLT CPU_DCache_RangeFlushL1
    DSB

    MOVW r2, #:lower16:CPU_Cache_PL310BaseAddr
    MOVT r2, #:upper16:CPU_Cache_PL310BaseAddr
    LDR    r2, [r2]
CPU_DCache_RangeFlushL2:
    STR r0, [r2, #CPU_CACHE_L2C_REG7_CACHE_CLEAN_PA]
    ADD r0, r0, r12
    CMP r0, r1
    BLT CPU_DCache_RangeFlushL2
    DSB

CPU_DCache_RangeFlush_END:
    BX LR
