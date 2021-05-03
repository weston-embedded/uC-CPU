#*********************************************************************************************************
#*                                              uC/CPU
#*                                   CPU CONFIGURATION & PORT LAYER
#*
#*                   Copyright 2004-2021 Silicon Laboratories Inc. www.silabs.com
#*
#*                                SPDX-License-Identifier: APACHE-2.0
#*
#*              This software is subject to an open source license and is distributed by
#*               Silicon Laboratories Inc. pursuant to the terms of the Apache License,
#*                   Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
#*
#*********************************************************************************************************

#*********************************************************************************************************
#*
#*                                            CPU PORT FILE
#*
#*                                        Freescale MPC56xx-VLE
#*
#* Filename : cpu_a.s
#* Version  : V1.32.01
#*********************************************************************************************************


#*********************************************************************************************************
#*                                             ASM HEADER
#*********************************************************************************************************

        .text_vle

#*********************************************************************************************************
#*                                          PUBLIC DECLARATIONS
#*********************************************************************************************************

        .global  CPU_SR_Save
        .global  CPU_SR_Restore
        .global  CPU_SR_Rd
        .global  CPU_IntDis
        .global  CPU_IntEn
        .global  CPU_DEC_Set
        .global  CPU_DECAR_Set
        .global  CPU_HID0_Get
        .global  CPU_HID0_Set
        .global  CPU_TBL_Get
        .global  CPU_TBU_Get
        .global  CPU_TBL_Set
        .global  CPU_TBU_Set
        .global  CPU_TCR_Get
        .global  CPU_TCR_Set

        .global  CPU_IVOR0_Set
        .global  CPU_IVOR1_Set
        .global  CPU_IVOR2_Set
        .global  CPU_IVOR3_Set
        .global  CPU_IVOR4_Set
        .global  CPU_IVOR5_Set
        .global  CPU_IVOR6_Set
        .global  CPU_IVOR7_Set
        .global  CPU_IVOR8_Set
        .global  CPU_IVOR9_Set
        .global  CPU_IVOR10_Set
        .global  CPU_IVOR11_Set
        .global  CPU_IVOR12_Set
        .global  CPU_IVOR13_Set
        .global  CPU_IVOR14_Set
        .global  CPU_IVOR15_Set
        .global  CPU_IVOR32_Set
        .global  CPU_IVOR33_Set
        .global  CPU_IVOR34_Set


#*********************************************************************************************************
#*                                      CRITICAL SECTION FUNCTIONS
#*
#* Description : These functions are used to enter and exit critical sections using Critical Method #3.
#*
#*                   CPU_SR  CPU_SR_Save (void)
#*                          Get current global interrupt mask bit value from MSR
#*                          Disable interrupts
#*                          Return global interrupt mask bit
#*
#*                   void  CPU_SR_Restore (CPU_SR  cpu_sr)
#*                          Set global interrupt mask bit on MSR according to parameter cpu_sr
#*                          Return
#*
#* Argument(s) : cpu_sr      global interrupt mask status.
#*********************************************************************************************************

CPU_SR_Save:
    mfmsr   r3
    wrteei  0
    se_blr

CPU_SR_Restore:
    mtmsr   r3
    se_blr


#*********************************************************************************************************
#*                                      READ STATUS REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the status register value.
#*
#*                   CPU_SR  CPU_SR_Rd (void)
#*                          Get current MSR value
#*                          Return
#*********************************************************************************************************

CPU_SR_Rd:
    mfmsr   r3
    se_blr


#*********************************************************************************************************
#*                                      DISABLE/ENABLE INTERRUPTS
#*
#* Description : Disable/Enable interrupts by setting or clearing the global interrupt mask in the cpu
#*               status register.
#*
#*                    void  CPU_IntDis (void)
#*                           Set global interrupt mask bit on MSR
#*                           Return
#*
#*                    void  CPU_IntEn (void)
#*                           Clear global interrupt mask bit on MSR
#*                           Return
#*********************************************************************************************************

CPU_IntDis:
    wrteei  0
    se_blr


CPU_IntEn:
    wrteei  1
    se_blr


#*********************************************************************************************************
#*                                      WRITE DECREMENTER REGISTER FUNCTION
#*
#* Description : This function is used to set the decrementer register with a given value.
#*
#*                   void  CPU_DEC_Set (CPU_INT32U value)
#*                          Write value into DEC
#*                          Return
#*********************************************************************************************************

CPU_DEC_Set:
    mtDEC   r3
    se_blr


#*********************************************************************************************************
#*                                      WRITE DECREMENTER AUTORELOAD REGISTER FUNCTION
#*
#* Description : This function is used to set the decrementer auto-reload register with a given value.
#*
#*                   void  CPU_DECAR_Set (CPU_INT32U value)
#*                          Write value into DECAR
#*                          Return
#*********************************************************************************************************

CPU_DECAR_Set:
    mtDECAR r3
    se_blr


#*********************************************************************************************************
#*                                      READ HARDWARE IMPLEMENTATION DEPENDENT REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the hardware implementation dependent register value.
#*
#*                   CPU_INT32U  CPU_HID0_Get (void)
#*                          Get current HID0 value
#*                          Return
#*********************************************************************************************************

CPU_HID0_Get:
    mfspr   r3, 1008
    se_blr


#*********************************************************************************************************
#*                                      WRITE HARDWARE IMPLEMENTATION DEPENDENT REGISTER FUNCTION
#*
#* Description : This function is used to set the hardware implementation dependent register value.
#*
#*                   void  CPU_HID0_Set (CPU_INT32U value)
#*                          Write value into HID0
#*                          Return
#*********************************************************************************************************

CPU_HID0_Set:
    mtspr   1008, r3
    se_blr


#*********************************************************************************************************
#*                                      READ TIME BASE LOW REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the time base low register value.
#*
#*                   CPU_INT32U  CPU_TBL_Get (void)
#*                          Get current TBL value
#*                          Return
#*********************************************************************************************************

CPU_TBL_Get:
    mfspr   r3, 268
    se_blr


#*********************************************************************************************************
#*                                      READ TIME BASE HIGH REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the time base high register value.
#*
#*                   CPU_INT32U  CPU_TBU_Get (void)
#*                          Get current TBU value
#*                          Return
#*********************************************************************************************************

CPU_TBU_Get:
    mfspr   r3, 269
    se_blr


#*********************************************************************************************************
#*                                      WRITE TIME BASE LOW REGISTER FUNCTION
#*
#* Description : This function is used to set the time base low register value.
#*
#*                   void  CPU_TBL_Set (CPU_INT32U value)
#*                          Write value into TBL
#*                          Return
#*********************************************************************************************************

CPU_TBL_Set:
    mtspr   284, r3
    se_blr


#*********************************************************************************************************
#*                                      WRITE TIME BASE HIGH REGISTER FUNCTION
#*
#* Description : This function is used to set the time base high register value.
#*
#*                   void  CPU_TBU_Set (CPU_INT32U value)
#*                          Write value into TBU
#*                          Return
#*********************************************************************************************************

CPU_TBU_Set:
    mtspr   285, r3
    se_blr


#*********************************************************************************************************
#*                                      READ TIMER CONTROL REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the timer control register value.
#*
#*                   CPU_INT32U  CPU_TCR_Get (void)
#*                          Get current TCR value
#*                          Return
#*********************************************************************************************************

CPU_TCR_Get:
    mfTCR   r3
    se_blr


#*********************************************************************************************************
#*                                      WRITE TIMER CONTROL REGISTER FUNCTION
#*
#* Description : This function is used to set the timer control register value.
#*
#*                   void  CPU_TCR_Set (CPU_INT32U value)
#*                          Write value into TCR
#*                          Return
#*********************************************************************************************************

CPU_TCR_Set:
    mtTCR   r3
    se_blr


#*********************************************************************************************************
#*                                      WRITE IVOR REGISTER FUNCTION
#*
#* Description : These functions are used to set the exception handler functions.
#*
#*                   void  CPU_IVORx_Set (CPU_FNCT_VOID fnct)
#*                          Write fnct address into IVORx
#*                          Return
#*********************************************************************************************************

CPU_IVOR0_Set:
    mtIVOR0 r3
    se_blr

CPU_IVOR1_Set:
    mtIVOR1 r3
    se_blr

CPU_IVOR2_Set:
    mtIVOR2 r3
    se_blr

CPU_IVOR3_Set:
    mtIVOR3 r3
    se_blr

CPU_IVOR4_Set:
    mtIVOR4 r3
    se_blr

CPU_IVOR5_Set:
    mtIVOR5 r3
    se_blr

CPU_IVOR6_Set:
    mtIVOR6 r3
    se_blr

CPU_IVOR7_Set:
    mtIVOR7 r3
    se_blr

CPU_IVOR8_Set:
    mtIVOR8 r3
    se_blr

CPU_IVOR9_Set:
    mtIVOR9 r3
    se_blr

CPU_IVOR10_Set:
    mtIVOR10 r3
    se_blr

CPU_IVOR11_Set:
    mtIVOR11 r3
    se_blr

CPU_IVOR12_Set:
    mtIVOR12 r3
    se_blr

CPU_IVOR13_Set:
    mtIVOR13 r3
    se_blr

CPU_IVOR14_Set:
    mtIVOR14 r3
    se_blr

CPU_IVOR15_Set:
    mtIVOR15 r3
    se_blr

CPU_IVOR32_Set:
    mtIVOR32 r3
    se_blr

CPU_IVOR33_Set:
    mtIVOR33 r3
    se_blr

CPU_IVOR34_Set:
    mtIVOR34 r3
    se_blr


#*********************************************************************************************************
#*                                     CPU ASSEMBLY PORT FILE END
#*********************************************************************************************************
    .end
