#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

// THESE FIRST DEFINES, WE MIGHT WANT TO MODIFY
// ESPECIALLY IF CHIP CHANGES!!!!!
// these values are for stm32 f411ce 1
// should double check that this is correct
#define configCPU_CLOCK_HZ 10000000
// should not be defined, since it should be the same as above
// #define configSYSTICK_CLOCK_HZ
// tick this many times a second... we can modify this to whatever
// gives us the best performance characteristics
// and a higher tick rate also means time can be divided more
// precisely
#define configTICK_RATE_HZ 500


// Use preemptive, not cooperative scheduler
// Co-routines are not recommended (some say deprecated)
#define configUSE_PREEMPTION                    1
// Use more performant task selection when available
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 1
// For lower power usage, should be available on arm microcontrollers
#define configUSE_TICKLESS_IDLE                 1
// this should be as low as possible to conserve RAM
#define configMAX_PRIORITIES                    1
// stack size of the idle task, 128 is used in many examples
// but could maybe be less?
#define configMINIMAL_STACK_SIZE                128
#define configMAX_TASK_NAME_LEN                 16
// we are on a 32-bit architecture, use 32 bit ticks
#define configUSE_16_BIT_TICKS                  0
// we don't use idle priority tasks, so this is irrelevant
#define configIDLE_SHOULD_YIELD                 0
// currently unused
#define configUSE_TASK_NOTIFICATIONS            0 
#define configTASK_NOTIFICATION_ARRAY_ENTRIES   0
//
#define configUSE_MUTEXES
#define configUSE_RECURSIVE_MUTEXES
#define configUSE_COUNTING_SEMAPHORES
// deprecated
#define configUSE_ALTERNATIVE_API               0
#define configQUEUE_REGISTRY_SIZE
#define configUSE_QUEUE_SETS
#define configUSE_TIME_SLICING
#define configUSE_NEWLIB_REENTRANT
#define configENABLE_BACKWARD_COMPATIBILITY
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS
#define configUSE_MINI_LIST_ITEM
#define configSTACK_DEPTH_TYPE
#define configMESSAGE_BUFFER_LENGTH_TYPE
#define configHEAP_CLEAR_MEMORY_ON_FREE

// Only support static memory allocation
#define configSUPPORT_STATIC_ALLOCATION  1
#define configSUPPORT_DYNAMIC_ALLOCATION 0
// #define configKERNEL_PROVIDED_STATIC_MEMORY 1
// #define configTOTAL_HEAP_SIZE          10240
// #define configAPPLICATION_ALLOCATED_HEAP    1
// #define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP   1

///// Hook function related definitions
// we do want to make sure we do not overflow the stack
// but for now, we disable overflow hook
#define configCHECK_FOR_STACK_OVERFLOW     0
// no need to hook into idle process
#define configUSE_IDLE_HOOK                0
// no need for doing anything in the tick interrupt
#define configUSE_TICK_HOOK                0
// we use static allocation, malloc hook is not needed
#define configUSE_MALLOC_FAILED_HOOK       0
// no need to hook into start of timer service
#define configUSE_DAEMON_TASK_STARTUP_HOOK 0
// do not need streambuffer with callbacks
#define configUSE_SB_COMPLETED_CALLBACK    0

// Run time and task stats gathering related definitions.
#define configGENERATE_RUN_TIME_STATS        0
#define configUSE_TRACE_FACILITY             0
#define configUSE_STATS_FORMATTING_FUNCTIONS 0

/* Co-routine related definitions. */
#define [configUSE_CO_ROUTINES](#configuse_co_routines)                               0
#define [configMAX_CO_ROUTINE_PRIORITIES](#configmax_co_routine_priorities)                     1

/* Software timer related definitions. */
#define [configUSE_TIMERS](#configuse_timers)                                    1
#define [configTIMER_TASK_PRIORITY](#configtimer_task_priority)                           3
#define [configTIMER_QUEUE_LENGTH](#configtimer_queue_length)                            10
#define [configTIMER_TASK_STACK_DEPTH](#configtimer_task_stack_depth)                        configMINIMAL_STACK_SIZE

/* Interrupt nesting behaviour configuration. */
#define [configKERNEL_INTERRUPT_PRIORITY](#configkernel_interrupt_priority-configmax_syscall_interrupt_priority-and-configmax_api_call_interrupt_priority)         [dependent of processor]
#define [configMAX_SYSCALL_INTERRUPT_PRIORITY](#configkernel_interrupt_priority-configmax_syscall_interrupt_priority-and-configmax_api_call_interrupt_priority)    [dependent on processor and application]
#define [configMAX_API_CALL_INTERRUPT_PRIORITY](#configkernel_interrupt_priority-configmax_syscall_interrupt_priority-and-configmax_api_call_interrupt_priority)   [dependent on processor and application]

/* Define to trap errors during development. */
#define [configASSERT](#configassert)( ( x ) ) if( ( x ) == 0 ) vAssertCalled( __FILE__, __LINE__ )

/* FreeRTOS MPU specific definitions. */
#define [configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS](#configinclude_application_defined_privileged_functions) 0
#define [configTOTAL_MPU_REGIONS](#configtotal_mpu_regions)                                8 /* Default value */
#define [configTEX_S_C_B_FLASH](#configtex_s_c_b_flash)                                  0x07UL /* Default value */
#define [configTEX_S_C_B_SRAM](#configtex_s_c_b_sram)                                   0x07UL /* Default value */
#define [configENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY](#configenforce_system_calls_from_kernel_only)            1
#define [configALLOW_UNPRIVILEGED_CRITICAL_SECTIONS](#configallow_unprivileged_critical_sections)             1
#define [configENABLE_ERRATA_837070_WORKAROUND](#configenable_errata_837070_workaround)                  1

/* ARMv8-M port specific configuration definitions. */
#define [configENABLE_TRUSTZONE](#configenable_trustzone)                            1
#define [configRUN_FREERTOS_SECURE_ONLY](#configrun_freertos_secure_only)            1
#define [configENABLE_MPU](#configenable_mpu)                                        1
#define [configENABLE_FPU](#configenable_fpu)                                        1
#define [configENABLE_MVE](#configenable_mve)                                        1

/* ARMv8-M secure side port related definitions. */
#define [secureconfigMAX_SECURE_CONTEXTS](#secureconfigmax_secure_contexts)         5

/* Optional functions - most linkers will remove unused functions anyway. */
#define [INCLUDE_vTaskPrioritySet](#include-parameters)                1
#define [INCLUDE_uxTaskPriorityGet](#include-parameters)               1
#define [INCLUDE_vTaskDelete](#include-parameters)                     1
#define [INCLUDE_vTaskSuspend](#include-parameters)                    1
#define [INCLUDE_vTaskDelayUntil](#include-parameters)                 1
#define [INCLUDE_vTaskDelay](#include-parameters)                      1
#define [INCLUDE_xTaskGetSchedulerState](#include-parameters)          1
#define [INCLUDE_xTaskGetCurrentTaskHandle](#include-parameters)       1
#define [INCLUDE_uxTaskGetStackHighWaterMark](#include-parameters)     0
#define [INCLUDE_uxTaskGetStackHighWaterMark2](#include-parameters)    0
#define [INCLUDE_xTaskGetIdleTaskHandle](#include-parameters)          0
#define [INCLUDE_eTaskGetState](#include-parameters)                   0
#define [INCLUDE_xTimerPendFunctionCall](#include-parameters)          0
#define [INCLUDE_xTaskAbortDelay](#include-parameters)                 0
#define [INCLUDE_xTaskGetHandle](#include-parameters)                  0
#define [INCLUDE_xTaskResumeFromISR](#include-parameters)              1

/* A header file that defines trace macro can be included here. */

#endif // FREERTOS_CONFIG_H
