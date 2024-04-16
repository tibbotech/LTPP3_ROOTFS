/*Copyright 2021 Tibbo Technology Inc.*/

#ifndef TIBBO_KDBG_LOG_H_
#define TIBBO_KDBG_LOG_H_

#define NO_DBG_PRINT "\0"

#if TIBBO_LOG_ENABLED
/**
 * @defgroup Console color configurations for dbg output.
 *
 * @{
 */
/** Red color for tag output.  */
#define DBG_COLOR_RED "\x1B[1;31m"
/** Green color for tag output.  */
#define DBG_COLOR_GREEN "\x1B[1;32m"
/** Yellow color for tag output.  */
#define DBG_COLOR_YELLOW "\x1B[1;33m"
/** Blue color for tag output.  */
#define DBG_COLOR_BLUE "\x1B[1;34m"
/** Magenta color for tag output.  */
#define DBG_COLOR_MAGENTA "\x1B[1;35m"
/** CYAN color for tag output.  */
#define DBG_COLOR_CYAN "\x1B[1;36m"
/** Default color for tag output.  */
#define DBG_COLOR_RESET "\x1B[0m"
/** @} */

//  #define TPD_TAG NO_DBG_PRINT //"TPD"
#define TPD_TAG "TPD"

#else

#define DBG_COLOR_RED "\0"

#define DBG_COLOR_GREEN "\0"

#define DBG_COLOR_YELLOW "\0"

#define DBG_COLOR_BLUE "\0"

#define DBG_COLOR_MAGENTA "\0"

#define DBG_COLOR_CYAN "\0"

#define DBG_COLOR_RESET "\0"ß

#define TPD_TAG NO_DBG_PRINT

#endif

////////////////////////////////////////////////////
// DEBUG PRINT TAGS
// EXAMPLE: ENABLED TAG
// #define TAG "TAG"
// EXAMPLE: DISABLED TAG
// #define TAG ""
///////////////////////////////////////////////////

/**
 * @brief Initializes the underlying RTT logging system.
 *
 */

#if TIBBO_LOG_ENABLED
//  #include "SEGGER_RTT.h"

#define TIBBO_LOG_INIT() printk(KERN_ALERT "TIBBO_LOG_INIT()\r\n");

/**
 * @brief Writes formatted output to the log.ß
 * @param TAG Name. This is the tag that is preapended before the message.
 * @param Tag Color
 * @param Format Specifier
 * @param Parameters for the format specifier.
 */
#define TIBBO_LOGF(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT, ...)             \
  if (DBG_TAG[0] != '\0')                                                 \
    printk(PRIORITY DBG_COLOR DBG_TAG ": " FORMAT DBG_COLOR_RESET "\r\n", \
           ##__VA_ARGS__);

/**
 * @brief Writes output to the log without tag formatting.
 * @param TAG Name. This is the tag used to determine if output will be printed.
 * @param Tag Color
 * @param String
 */
#define TIBBO_PRINT(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT) \
  if (DBG_TAG[0] != '\0') printk(PRIORITY FORMAT DBG_COLOR_RESET);

/**
 * @brief Writes formatted output to the log without tag formatting.
 * @param TAG Name. This is the tag used to determine if output will be printed.
 * @param Tag Color
 * @param Format Specifier
 * @param Parameters for the format specifier.
 */
#define TIBBO_PRINTF(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT, ...) \
  if (DBG_TAG[0] != '\0')                                       \
    printk(PRIORITY FORMAT DBG_COLOR_RESET, ##__VA_ARGS__);

/**
 * @brief Writes output to the log.
 * @param TAG Name. This is the tag that is preapended before the message.
 * @param Tag Color
 * @param String to write
 */
#define TIBBO_LOG(PRIORITY, BG_TAG, DBG_COLOR, FORMAT)            \
  if (DBG_TAG[0] != '\0')                                         \
    printk(PRIORITY DBG_COLOR DBG_TAG ": " FORMAT DBG_COLOR_RESET \
                                      "\r"                        \
                                      "\n");

#define TIBBO_LOGF_FATAL(PRIORITY, FORMAT, ...)                              \
  printk(PRIORITY DBG_COLOR_RED "DEADBEEF : " FORMAT DBG_COLOR_RESET "\r\n", \
         ##__VA_ARGS__);

#else

// Are you in release mode and still need JLINK
// You can just use printf to replace the macro.
#define TIBBO_LOG_INIT()
#define TIBBO_LOGF(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT, ...)
#define TIBBO_LOG(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT)
#define TIBBO_LOG_FATAL(PRIORITY, FORMAT, ...)
#define TIBBO_PRINTF(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT, ...)
#define TIBBO_PRINT(PRIORITY, DBG_TAG, DBG_COLOR, FORMAT)

#endif

#endif  // TIBBO_KDBG_H_
