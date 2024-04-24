/*Copyright 2021 Tibbo Technology Inc.*/

#include "tpd.h"

#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/gpio.h>
#include <linux/init.h>
#include <linux/io.h>
#include <linux/kdev_t.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/serial_core.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

#include "tibbo_kdbg.h"

static DEFINE_MUTEX(tpd_lock);
static tpd_peripheral_struct_t peripheral_dev;

struct sunplus_uart_port {
    char name[16]; /* Sunplus_UARTx */
    struct uart_port uport;
    struct sunplus_uartdma_info* uartdma_rx;
    struct sunplus_uartdma_info* uartdma_tx;
    struct clk* clk;
    struct reset_control* rstc;
    struct gpio_desc* rts_gpio;
    struct hrtimer CheckTXE;
    struct hrtimer DelayRtsBeforeSend;
    struct hrtimer DelayRtsAfterSend;
};

extern struct gpio_desc* gpiochip_get_desc(struct gpio_chip* gc,
                                           unsigned int hwnum);

extern struct sunplus_uart_port* tpd_uart_ports;
extern struct gpio_desc* gpio_name_to_desc(const char* const name);

static char tpd_virtual_device[100];

static dev_t tpd_dev = 0;
static struct cdev tpd_cdev;
static struct class* tpd_class;

/* Driver Fuctions */
static int tpd_open(struct inode* inode, struct file* file);
static int tpd_release(struct inode* inode, struct file* file);
static ssize_t tpd_read(struct file* filp, char __user* buf, size_t len,
                        loff_t* off);
static ssize_t tpd_write(struct file* filp, const char* buf, size_t len,
                         loff_t* off);

static struct file_operations tpd_fops = {
    .owner = THIS_MODULE,
    .read = tpd_read,
    .write = tpd_write,
    .open = tpd_open,
    .release = tpd_release,
};

/* Pinmux Peripheral Setup */
static void tpd_setup_serial(int ser_num, int ser_pin_func, int gpio_num);
static void tpd_setup_i2c(int i2c_num, int i2c_pin_func, int gpio_num);
static void tpd_setup_spi(int spi_num, int spi_pin_func, int gpio_num);
static void tpd_setup_gpio(int gpio_num);

/* GPIO Peripheral Functions*/
static int tpd_gpio_request(int gpio_num);  // for testing only
static int tpd_gpio_pin_mux_set(u32 func, u32 pin);
static int tpd_gpio_first_set(u32 pin, u32 val);
static int tpd_gpio_master_set(u32 pin, u32 val);
static int tpd_gpio_oe_set(u32 pin, u32 val);
static int tpd_gpio_out_set(u32 pin, u32 val);

/* Driver Initialization */
static void tpd_init_io_lttp3g2(void);

static int tpd_open(struct inode* inode, struct file* file) {
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Device File Opened...!!!\n");
    return 0;
}

static int tpd_release(struct inode* inode, struct file* file) {
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Device File Closed...!!!\n");
    return 0;
}

static ssize_t tpd_read(struct file* filp, char __user* buf, size_t len,
                        loff_t* off) {
    if (mutex_lock_interruptible(&tpd_lock)) {
        return -EINTR;
    }

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Inside Data chr_read() function...\n");

    if (len > sizeof(tpd_virtual_device)) {
        len = sizeof(tpd_virtual_device);
    }

    if (copy_to_user(buf, tpd_virtual_device, len)) {
        return -EFAULT;
    }
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Data Read : DONE...\n");

    mutex_unlock(&tpd_lock);

    return len;
}

static ssize_t tpd_write(struct file* filp, const char __user* buf, size_t len,
                         loff_t* off) {
    int tpd_chip_rev_reg = 0x9C000000;
    void __iomem* tpd_chip_rev_reg_p;
    if (mutex_lock_interruptible(&tpd_lock)) {
        return -EINTR;
    }

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Inside tpd_write() function...\n");

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "peripheral_dev size=\n0x%08x\n",
               sizeof(tpd_peripheral_struct_t));
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "len=\n0x%08x\n", len);

    if (copy_from_user(&peripheral_dev, (tpd_peripheral_struct_t*)buf,
                       sizeof(tpd_peripheral_struct_t))) {
        return -EFAULT;
    }

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "peripheral_dev.peripheral_type=\n0x%08x\n",
               peripheral_dev.peripheral_type);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "peripheral_dev.peripheral_num=\n0x%08x\n",
               peripheral_dev.peripheral_num);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "peripheral_dev.peripheral_pin_func=\n0x%08x\n",
               peripheral_dev.peripheral_pin_func);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "peripheral_dev.peripheral_pin_num=\n0x%08x\n",
               peripheral_dev.peripheral_pin_num);

    // Get virtual addresses
    tpd_chip_rev_reg_p = ioremap(tpd_chip_rev_reg, sizeof(u32));
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "SP_CHIP_REV_REG=\n0x%08x\n", ioread32(tpd_chip_rev_reg_p));

    switch (peripheral_dev.peripheral_type) {
        case TPD_I2C:  // for gpio testing TPD_I2C is used for gpio_request

            tpd_setup_i2c(peripheral_dev.peripheral_num,
                          peripheral_dev.peripheral_pin_func,
                          peripheral_dev.peripheral_pin_num);
            break;

        case TPD_INPUT_CAPTURE:  // for gpio testing TPD_INPUT_CAPTURE is used
                                 // for gpio_free
            break;

        case TPD_IO:
            tpd_setup_gpio(peripheral_dev.peripheral_pin_num);
            break;

        case TPD_SERIAL:
            if (peripheral_dev.peripheral_num != 0) {
                tpd_setup_serial(peripheral_dev.peripheral_num,
                                 peripheral_dev.peripheral_pin_func,
                                 peripheral_dev.peripheral_pin_num);
            }
            break;
        case TPD_PWM:
            break;

        case TPD_SPI:
            tpd_setup_spi(peripheral_dev.peripheral_num,
                          peripheral_dev.peripheral_pin_func,
                          peripheral_dev.peripheral_pin_num);
            break;

        case TPD_GPIO_REQUEST:  // for gpio testing only
            tpd_gpio_request(peripheral_dev.peripheral_pin_num);
            break;

        case TPD_GPIO_FREE:  // for gpio testing only
            gpio_free(peripheral_dev.peripheral_pin_num);
            break;

        case TPD_GPIO_DIR_OUT:  // for gpio testing only
            tpd_gpio_oe_set(peripheral_dev.peripheral_pin_num, 1);
            break;

        case TPD_GPIO_SET_HIGH:  // for gpio testing only
            tpd_gpio_out_set(peripheral_dev.peripheral_pin_num, 1);
            break;

        case TPD_GPIO_SET_LOW:  // for gpio testing only
            tpd_gpio_out_set(peripheral_dev.peripheral_pin_num, 0);
            break;

        case TPD_GPIO_DIR_IN:  // for gpio testing only
            tpd_gpio_oe_set(peripheral_dev.peripheral_pin_num, 0);
            break;

        default:
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "Unsupported periheral type !! \n");
            break;
    }

    mutex_unlock(&tpd_lock);
    return len;
}

static int tpd_gpio_pin_mux_set(u32 func, u32 pin) {
    int tpd_moon2_regs;
    void __iomem* tpd_moon2_regs_p;
    u32 idx, bit_pos;
    u32 reg_val;

    if ((func > TPD_MUXF_GPIO_INT7) || (func < TPD_MUXF_L2SW_CLK_OUT)) {
        return -EINVAL;
    }
    if (pin == 0) {
        // zero_func
        // pin = 7;
    } else if ((pin < 8) || (pin > 71)) {
        return -EINVAL;
    }

    func -= TPD_MUXF_L2SW_CLK_OUT;
    idx = func >> 1;
    bit_pos = (func & 0x01) ? 8 : 0;
    reg_val = (0x7f << (16 + bit_pos)) | ((pin - 7) << bit_pos);

    tpd_moon2_regs = TPD_MOON2_REGS_BASE + (idx * 4);
    tpd_moon2_regs_p = ioremap(tpd_moon2_regs, sizeof(u32));

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_PIN_MUX: REG ADDRESS=\n0x%08x\n", tpd_moon2_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_PIN_MUX: REG VAL =\n0x%08x\n", ioread32(tpd_moon2_regs_p));

    iowrite32(reg_val, tpd_moon2_regs_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_PIN_MUX: REG ADDRESS=\n0x%08x\n", tpd_moon2_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_PIN_MUX: UPDATED REG VAL =\n0x%08x\n",
               ioread32(tpd_moon2_regs_p));

    return 0;
}

static int tpd_gpio_first_set(u32 pin, u32 val) {
    int tpd_first_regs;
    void __iomem* tpd_first_regs_p;
    u32 idx, value, reg_val;

    idx = pin >> 5;
    if (idx > 3) {
        return -EINVAL;
    }

    value = 1 << (pin & 0x1f);

    tpd_first_regs = TPD_FIRST_REGS_BASE + (idx * 4);
    tpd_first_regs_p = ioremap(tpd_first_regs, sizeof(u32));
    reg_val = ioread32(tpd_first_regs_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_FIRST: REG ADDRESS=\n0x%08x\n", tpd_first_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_FIRST: REG VAL =\n0x%08x\n", reg_val);

    if (val != 0) {
        reg_val = reg_val | value;
    } else {
        reg_val = reg_val & (~value);
    }

    iowrite32(reg_val, tpd_first_regs_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_FIRST: UPDATED REG VAL =\n0x%08x\n",
               ioread32(tpd_first_regs_p));

    return 0;
}

static int tpd_gpio_master_set(u32 pin, u32 val) {
    int tpd_master_regs;
    void __iomem* tpd_master_regs_p;
    u32 idx, bit;
    u32 reg_val;

    idx = pin >> 4;
    if (idx > 7) {
        return -EINVAL;
    }

    bit = pin & 0x0f;
    if (val != 0) {
        val = 0xffff;
    }

    tpd_master_regs = TPD_MASTER_REGS_BASE + (idx * 4);
    tpd_master_regs_p = ioremap(tpd_master_regs, sizeof(u32));
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_MASTER: REG ADDRESS=\n0x%08x\n", tpd_master_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_MASTER: REG VAL =\n0x%08x\n", ioread32(tpd_master_regs_p));
    reg_val = (1 << (bit + 16)) | val;
    iowrite32(reg_val, tpd_master_regs_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_MASTER: REG ADDRESS=\n0x%08x\n", tpd_master_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_MASTER: UPDATED REG VAL =\n0x%08x\n",
               ioread32(tpd_master_regs_p));

    return 0;
}

static int tpd_gpio_oe_set(u32 pin, u32 val) {
    int tpd_oe_regs;
    void __iomem* tpd_oe_regs_p;
    u32 idx, bit;
    u32 reg_val;

    idx = pin >> 4;
    if (idx > 7) {
        return -EINVAL;
    }

    bit = pin & 0x0f;
    if (val != 0) {
        val = 0xffff;
    }

    tpd_oe_regs = TPD_OE_REGS_BASE + (idx * 4);
    tpd_oe_regs_p = ioremap(tpd_oe_regs, sizeof(u32));
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: REG ADDRESS=\n0x%08x\n", tpd_oe_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: REG VAL =\n0x%08x\n", ioread32(tpd_oe_regs_p));
    reg_val = (1 << (bit + 16)) | val;
    iowrite32(reg_val, tpd_oe_regs_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: REG ADDRESS=\n0x%08x\n", tpd_oe_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: UPDATED REG VAL =\n0x%08x\n", ioread32(tpd_oe_regs_p));

    return 0;
}

static int tpd_gpio_out_set(u32 pin, u32 val) {
    int tpd_out_regs;
    void __iomem* tpd_out_reg_p;
    u32 idx, bit;
    u32 reg_val;

    idx = pin >> 4;
    if (idx > 7) {
        return -EINVAL;
    }

    bit = pin & 0x0f;
    if (val != 0) {
        val = 0xffff;
    }

    tpd_out_regs = TPD_OUT_REGS_BASE + (idx * 4);
    tpd_out_reg_p = ioremap(tpd_out_regs, sizeof(u32));
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OUT: REG ADDRESS=\n0x%08x\n", tpd_out_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OUT: REG VAL =\n0x%08x\n", ioread32(tpd_out_reg_p));
    reg_val = (1 << (bit + 16)) | val;
    iowrite32(reg_val, tpd_out_reg_p);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: REG ADDRESS=\n0x%08x\n", tpd_out_regs);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "GPIO_OE: UPDATED REG VAL =\n0x%08x\n", ioread32(tpd_out_reg_p));

    return 0;
}

static int gpio_chip_match(struct gpio_chip* gc, void* data) {
    // SP7021 only has 1 gpiochip and so it will be a match.
    return 1;
}

static void tpd_setup_serial(int ser_num, int ser_pin_func, int gpio_num) {
    int func = 0;
    struct gpio_chip* gc;
    
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "setup_serial : GPIO  =\n0x%08x\n", gpio_num);

    if ((ser_num < 1) || (ser_num > TPD_NUM_SERIAL)) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "serial port number  %d out of range\n", ser_num);
        return;
    }

    func = (ser_num-1) * 4;  // Calculate the offset of the function
    switch (ser_pin_func) {
        case TPD_UART_PINS_TX:
            func += TPD_MUXF_UA1_TX;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set UA%d_TX FUNCTION \n", ser_num);
            break;

        case TPD_UART_PINS_RX:
            func += TPD_MUXF_UA1_RX;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set UA%d_RX FUNCTION \n", ser_num);
            break;

        case TPD_UART_PINS_RTS:
            func += TPD_MUXF_UA1_RTS;
            // Release the RS485 direction pin in any port.
            if (tpd_uart_ports[ser_num].rts_gpio != NULL) {
                TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                           "Freeing UA%d_DIR FUNCTION \n", ser_num);
                gpiod_put(tpd_uart_ports[ser_num].rts_gpio);
                tpd_uart_ports[ser_num].rts_gpio = NULL;
            }
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set UA%d_RTS FUNCTION \n", ser_num);
            break;

        case TPD_UART_PINS_CTS:
            func += TPD_MUXF_UA1_CTS;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set UA%d_CTS FUNCTION \n", ser_num);
            break;
        case TPD_UART_PINS_DIR:
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set UA%d_DIR FUNCTION \n", ser_num);

            if (tpd_uart_ports[ser_num].rts_gpio != NULL) {
                TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                           "Freeing UA%d_DIR FUNCTION \n", ser_num);
                gpiod_put(tpd_uart_ports[ser_num].rts_gpio);
                tpd_uart_ports[ser_num].rts_gpio = NULL;
            }
            gc = gpiochip_find(NULL, gpio_chip_match);
            if (gc) {
                tpd_uart_ports[ser_num].rts_gpio =
                    gpiochip_get_desc(gc, gpio_num);
                if (IS_ERR(tpd_uart_ports[ser_num].rts_gpio)) {
                    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                               "BAD GPIO POINTER UA%d_DIR FUNCTION \n",
                               ser_num);
                }
            } else {
                TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                           "Cant find gpiochip 0\n");
            }
            gpiod_direction_output(tpd_uart_ports[ser_num].rts_gpio, 0);
            return;
            break;
        default:
            return;
    }
    tpd_gpio_pin_mux_set(func, gpio_num);
    tpd_gpio_first_set(gpio_num, 0);
    tpd_gpio_master_set(gpio_num, 1);
}

static void tpd_setup_i2c(int i2c_num, int i2c_pin_func, int gpio_num) {
    int func;
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "setup_i2c : GPIO  =\n0x%08x\n", gpio_num);

    if ((i2c_num < 0) || (i2c_num > (TPD_NUM_I2C - 1))) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "i2c number  %d out of range\n", i2c_num);
        return;
    }
    func = i2c_num * 2;

    switch (i2c_pin_func) {
        case TPD_I2C_PINS_CLK:
            func += TPD_MUXF_I2CM0_CLK;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set I2CM%d_CLK FUNCTION \n", i2c_num);
            break;
        case TPD_I2C_PINS_DAT:
            func += TPD_MUXF_I2CM0_DAT;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set I2CM%d_DAT FUNCTION \n", i2c_num);
            break;

        default:

            return;
    }
    tpd_gpio_pin_mux_set(func, gpio_num);
    tpd_gpio_first_set(gpio_num, 0);
    tpd_gpio_master_set(gpio_num, 1);
}

static void tpd_setup_spi(int spi_num, int spi_pin_func, int gpio_num) {
    int func;
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "setup_spi : GPIO  =\n0x%08x\n", gpio_num);

    if ((spi_num < 0) || (spi_num > (TPD_NUM_SPI - 1))) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "spi number  %d out of range\n", spi_num);
        return;
    }

    func = spi_num * 5;
    switch (spi_pin_func) {
        case TPD_SPI_PINS_INT:
            func += TPD_MUXF_SPIM0_INT;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set SPIM%d_INT Function \n", spi_num);
            break;
        case TPD_SPI_PINS_CLK:
            func += TPD_MUXF_SPIM0_CLK;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set SPIM%d_CLK Function \n", spi_num);
            break;
        case TPD_SPI_PINS_EN:
            func += TPD_MUXF_SPIM0_EN;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set SPIM%d_EN Function \n", spi_num);
            break;
        case TPD_SPI_PINS_MOSI:
            func += TPD_MUXF_SPIM0_DO;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set SPIM%d_DO Function \n", spi_num);
            break;
        case TPD_SPI_PINS_MISO:
            func += TPD_MUXF_SPIM0_DI;
            TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                       "set SPIM%d_DI Function \n", spi_num);
            break;

        default:
            return;
    }

    tpd_gpio_pin_mux_set(func, gpio_num);
    tpd_gpio_first_set(gpio_num, 0);
    tpd_gpio_master_set(gpio_num, 1);
}

static void tpd_setup_gpio(int gpio_num) {
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "setup_gpio : GPIO  =\n0x%08x\n", gpio_num);
    tpd_gpio_first_set(gpio_num, 1);
    tpd_gpio_master_set(gpio_num, 1);
}

int tpd_gpio_request(int gpio_num) {
    int result;
    result = gpio_request(gpio_num, "LTPP3G2_GPIO");
    if (result != 0) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "cannot request GPIO \n");
        return result;
    }

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "successfully request GPIO \n");
    gpio_direction_output(gpio_num, 0);
    return 0;
}

void tpd_init_io_lttp3g2(void) {
    int i, gpio_num;
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Inside the %s function\n",
               __FUNCTION__);
    for (i = 0; i < TPD_NUM_IO_LINES; i++) {
        gpio_num = i + 8;
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "gpio = %d \n",
                   gpio_num);
        tpd_gpio_first_set(gpio_num, 1);
        tpd_gpio_master_set(gpio_num, 1);
        tpd_gpio_oe_set(gpio_num, 0);
        tpd_gpio_out_set(gpio_num, 1);
    }

    for (i = 1; i < 5; i++) {
        tpd_uart_ports[i].rts_gpio = NULL;
    }
}

int __init tpd_init(void) {
    void (*tpd_init_io)(void);

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Inside the %s function\n",
               __FUNCTION__);

    /* Allocate device number */
    if ((alloc_chrdev_region(&tpd_dev, 0, 1, "tpd_device")) < 0) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "Cannot allocate device number\n");
        goto fail;
    }
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Major = %d Minor = %d \n",
               MAJOR(tpd_dev), MINOR(tpd_dev));

    /* Initialize the cdev structure */
    cdev_init(&tpd_cdev, &tpd_fops);

    /* Add device to the system */
    tpd_cdev.owner = THIS_MODULE;
    if ((cdev_add(&tpd_cdev, tpd_dev, 1)) < 0) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "Cannot add the device to the system\n");
        goto unreg_chrdev;
    }

    /* Create device class */
    if ((tpd_class = class_create(THIS_MODULE, "tpd_class")) == NULL) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "Cannot create the device class\n");
        goto cdev_del;
    }

    /* Create the device */
    if ((device_create(tpd_class, NULL, tpd_dev, NULL, "tpd")) == NULL) {
        TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
                   "Cannot create the Device \n");
        goto class_del;
    }

    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Set all gpio to input mode \n");

#if TPD_PLATFORM_ID == LTPP3G2
    tpd_init_io = &tpd_init_io_lttp3g2;
#endif
    tpd_init_io();
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW,
               "Driver Insertion successful \n");

    return 0;

class_del:
    class_destroy(tpd_class);
cdev_del:
    cdev_del(&tpd_cdev);
unreg_chrdev:
    unregister_chrdev_region(tpd_dev, 1);
fail:
    pr_info("Driver Insertion failed \n");
    return -1;
}

void __exit tpd_exit(void) {
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Inside the %s function\n",
               __FUNCTION__);
    device_destroy(tpd_class, tpd_dev);
    class_destroy(tpd_class);
    cdev_del(&tpd_cdev);
    unregister_chrdev_region(tpd_dev, 1);
    TIBBO_LOGF(KERN_INFO, TPD_TAG, DBG_COLOR_YELLOW, "Driver unloaded  \n");
}

module_init(tpd_init);
module_exit(tpd_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Tibbo Technology Inc.");
MODULE_DESCRIPTION("Tibbo pinmux driver");
