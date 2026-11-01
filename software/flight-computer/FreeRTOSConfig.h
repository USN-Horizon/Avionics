#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

// Documentation on options can be found here:
// https://www.freertos.org/Documentation/02-Kernel/03-Supported-devices/02-Customization
 
// THESE FIRST DEFINES, WE MIGHT WANT TO MODIFY
// ESPECIALLY IF CHIP CHANGES!!!!!
// these values are for stm32 f411ce 1
// should double check that this is correct
#define configCPU_CLOCK_HZ                           10000000
// should not be defined, since it should be the same as above
// #define configSYSTICK_CLOCK_HZ
// tick this many times a second... we can modify this to whatever
// gives us the best performance characteristics
// and a higher tick rate also means time can be divided more
// precisely
#define configTICK_RATE_HZ                           500


// Use preemptive, not cooperative scheduler
// Co-routines are not recommended (some say deprecated)
#define configUSE_PREEMPTION                         1
// Use more performant task selection when available
#define configUSE_PORT_OPTIMISED_TASK_SELECTION      1
// For lower power usage, should be available on arm microcontrollers
#define configUSE_TICKLESS_IDLE                      1
// this should be as low as possible to conserve RAM
#define configMAX_PRIORITIES                         1
// stack size of the idle task, 128 is used in many examples
// but could maybe be less?
#define configMINIMAL_STACK_SIZE                     128
#define configMAX_TASK_NAME_LEN                      16
// we are on a 32-bit architecture, use 32 bit ticks
#define configUSE_16_BIT_TICKS                       0
// we don't use idle priority tasks, so this is irrelevant
#define configIDLE_SHOULD_YIELD                      0
// must be enabled to build stream buffer
// but if we end up not using that, we can delete the source file and disable this
#define configUSE_TASK_NOTIFICATIONS                 1 
#define configTASK_NOTIFICATION_ARRAY_ENTRIES        4

// unsure if these are needed
// look at difference between mutexes and binary semaphores
#define configUSE_MUTEXES                            1
#define configUSE_RECURSIVE_MUTEXES                  0
#define configUSE_COUNTING_SEMAPHORES                0
// deprecated
#define configUSE_ALTERNATIVE_API                    0

// only useful for freertos-aware debuggers
#define configQUEUE_REGISTRY_SIZE                    0
// waiting on multiple queues are not needed for now
#define configUSE_QUEUE_SETS                         0
// switch between equal priority tasks on every tick
#define configUSE_TIME_SLICING                       1

// no newlib
#define configUSE_NEWLIB_REENTRANT                   0
#define configENABLE_BACKWARD_COMPATIBILITY          0
// no thead local storage
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS      0
// probably don't need mini list
#define configUSE_MINI_LIST_ITEM                     0

// seems big enough?
#define configSTACK_DEPTH_TYPE                       uint16_t
#define configMESSAGE_BUFFER_LENGTH_TYPE             uint16_t

// Only support static memory allocation
#define configSUPPORT_STATIC_ALLOCATION              1
#define configSUPPORT_DYNAMIC_ALLOCATION             0
// use kernel provided static memory so vApplicationGetIdleTaskMemory
// and vApplicationGetTimerTaskMemory does not need to be implemented
// (does not work if using MPU)
#define configKERNEL_PROVIDED_STATIC_MEMORY          1
// unused because we only use static allocation
// #define configTOTAL_HEAP_SIZE                     10240
// #define configAPPLICATION_ALLOCATED_HEAP          1
// #define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP 1
// unused
#define configHEAP_CLEAR_MEMORY_ON_FREE              1

///// Hook function related definitions
// we do want to make sure we do not overflow the stack
// but for now, we disable overflow hook
#define configCHECK_FOR_STACK_OVERFLOW               0
// no need to hook into idle process
#define configUSE_IDLE_HOOK                          0
// no need for doing anything in the tick interrupt
#define configUSE_TICK_HOOK                          0
// we use static allocation, malloc hook is not needed
#define configUSE_MALLOC_FAILED_HOOK                 0
// no need to hook into start of timer service
#define configUSE_DAEMON_TASK_STARTUP_HOOK           0
// do not need streambuffer with callbacks
#define configUSE_SB_COMPLETED_CALLBACK              0

// Run time and task stats gathering related definitions
#define configGENERATE_RUN_TIME_STATS                0
#define configUSE_TRACE_FACILITY                     0
#define configUSE_STATS_FORMATTING_FUNCTIONS         0

// Co-routine related definitions
#define configUSE_CO_ROUTINES                        0
// unused
#define configMAX_CO_ROUTINE_PRIORITIES              1

// Software timer related definitions
// unused until we might need timers
#define configUSE_TIMERS                             1
#define configTIMER_TASK_PRIORITY                    3
#define configTIMER_QUEUE_LENGTH                     10
#define configTIMER_TASK_STACK_DEPTH                 configMINIMAL_STACK_SIZE

// Interrupt nesting behaviour configuration, not sure if correct
// probably unused?
#define configKERNEL_INTERRUPT_PRIORITY              15
#define configMAX_SYSCALL_INTERRUPT_PRIORITY         8
#define configMAX_API_CALL_INTERRUPT_PRIORITY        8

// Define to trap errors during development
#define configASSERT( x ) if( ( x ) == 0 ) { taskDISABLE_INTERRUPTS(); for(;;) {} }

// FreeRTOS MPU specific definitions
// Which we won't use
#define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS  0
#define configTOTAL_MPU_REGIONS                      16
#define configTEX_S_C_B_FLASH                        0x07UL /* Default value */
#define configTEX_S_C_B_SRAM                         0x07UL /* Default value */
// if this is enabled __syscalls_flash_start__ and __syscalls_flash_end__ must be
// exported from the linker script
#define configENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY  1
#define configALLOW_UNPRIVILEGED_CRITICAL_SECTIONS   0
// enable this if using m4 mpu ports on cortex-m7 r0p0/r0p1
#define configENABLE_ERRATA_837070_WORKAROUND        0

// ARMv8-M port specific configuration definitions
#define configENABLE_TRUSTZONE                       0
// can set this if disabling trustzone is unsupported
#define configRUN_FREERTOS_SECURE_ONLY               0
#define configENABLE_MPU                             0
#define configENABLE_FPU                             1
// only applicable to cortex m55 and m85
#define configENABLE_MVE                             0

// not needed/used, since we do not run in a secure environment
#define secureconfigMAX_SECURE_CONTEXTS              8

// Optional functions - most linkers will remove unused functions anyway
// For now, do not change priority during runtime
#define INCLUDE_vTaskPrioritySet                     0
#define INCLUDE_uxTaskPriorityGet                    0
#define INCLUDE_vTaskDelete                          0
#define INCLUDE_vTaskSuspend                         1
#define INCLUDE_vTaskDelayUntil                      1
#define INCLUDE_vTaskDelay                           1
#define INCLUDE_xTaskGetSchedulerState               1
#define INCLUDE_xTaskGetCurrentTaskHandle            1
#define INCLUDE_uxTaskGetStackHighWaterMark          0
#define INCLUDE_uxTaskGetStackHighWaterMark2         0
#define INCLUDE_xTaskGetIdleTaskHandle               0
#define INCLUDE_eTaskGetState                        0
#define INCLUDE_xTimerPendFunctionCall               0
#define INCLUDE_xTaskAbortDelay                      0
#define INCLUDE_xTaskGetHandle                       0
#define INCLUDE_xTaskResumeFromISR                   1

// A header file that defines trace macro can be included here

#endif // FREERTOS_CONFIG_H
