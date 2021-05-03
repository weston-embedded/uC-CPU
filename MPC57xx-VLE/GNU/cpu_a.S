#********************************************************************************************************
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
#********************************************************************************************************

#********************************************************************************************************
#*
#*                                            CPU PORT FILE
#*
#*                                           NXP MPC57xx-VLE
#*
#* Filename : cpu_a.s
#* Version  : V1.32.01
#********************************************************************************************************


#********************************************************************************************************
#*                                             ASM HEADER
#********************************************************************************************************

    .text

#********************************************************************************************************
#                                          PUBLIC DECLARATIONS
#********************************************************************************************************

    .global  CPU_SR_Save
    .global  CPU_SR_Restore
    .global  CPU_SR_Rd
    .global  CPU_IntDis
    .global  CPU_IntEn


#********************************************************************************************************
#*                                     CRITICAL SECTION FUNCTIONS
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
#********************************************************************************************************

CPU_SR_Save:
    mfmsr   r3
    wrteei  0
    se_blr

CPU_SR_Restore:
    wrtee   r3
    se_blr


#********************************************************************************************************
#*                                    READ STATUS REGISTER FUNCTION
#*
#* Description : This function is used to retrieve the status register value.
#*
#*                   CPU_SR  CPU_SR_Rd (void)
#*                          Get current MSR value
#*                          Return
#********************************************************************************************************

CPU_SR_Rd:
    mfmsr   r3
    se_blr


#********************************************************************************************************
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
#********************************************************************************************************

CPU_IntDis:
    wrteei  0
    se_blr


CPU_IntEn:
    wrteei  1
    se_blr


#********************************************************************************************************
#*                                     CPU ASSEMBLY PORT FILE END
#********************************************************************************************************
    .end
