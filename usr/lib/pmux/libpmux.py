from ctypes import*
from enum import IntEnum

lib = cdll.LoadLibrary("/usr/lib/arm-linux-gnueabihf/libntios_pmux.so")

class pmux(object):
    def __init__(self):
        lib.pmux_new.restype = c_void_p

        lib.pmux_set.argtypes = [c_void_p,c_uint8,c_uint8,c_uint8,c_uint8]
        lib.pmux_set.restype = c_void_p
        
        self.obj = lib.pmux_new()
    
    def set(self,periph_type,periph_num,periph_pin_func,periph_pin_num):
        lib.pmux_set(self.obj,c_uint8(periph_type),c_uint8(periph_num),c_uint8(periph_pin_func),c_uint8(periph_pin_num))

class pmux_type(IntEnum):
    I2C             =0           
    INPUT_CAPTURE   =1
    IO              =2
    PWM             =3
    SERIAL          =4
    SPI             =5
    GPIO_REQUEST    =6
    GPIO_FREE       =7
    GPIO_DIR_OUT    =8
    GPIO_SET_HIGH   =9
    GPIO_SET_LOW    =10
    GPIO_DIR_IN     =11

class pmux_pin_func(IntEnum):
    UART_RX     =0
    UART_TX     =1
    UART_CTS    =2
    UART_RTS    =3
    I2C_CLK     =4
    I2C_DAT     =5
    SPI_INT     =6,
    SPI_CLK     =7,
    SPI_EN      =8, 
    SPI_MOSI    =9,
    SPI_MISO    =10,
    UART_DIR    =11
        
class pmux_pin(IntEnum):
    IO_8         =8
    IO_9         =9
    IO_10        =10
    IO_11        =11
    IO_12        =12
    IO_13        =13
    IO_14        =14
    IO_15        =15
    IO_16        =16
    IO_17        =17
    IO_18        =18
    IO_19        =19
    IO_20        =20
    IO_21        =21
    IO_22        =22
    IO_23        =23
    IO_24        =24
    IO_25        =25
    IO_26        =26
    IO_27        =27
    IO_28        =28
    IO_29        =29
    IO_30        =30
    IO_31        =31
    IO_32        =32
    IO_33        =33
    IO_34        =34
    IO_35        =35
    IO_36        =36
    IO_37        =37
    IO_38        =38
    IO_39        =39
    IO_40        =40
    IO_41        =41
    IO_42        =42
    IO_43        =43
    IO_44        =44
    IO_45        =45
    IO_46        =46
    IO_47        =47
    IO_48        =48
    IO_49        =49
    IO_50        =50
    IO_51        =51
    IO_52        =52
    IO_53        =53
    IO_54        =54
    IO_55        =55
    IO_56        =56
    IO_57        =57
    IO_58        =58
    IO_59        =59
    IO_60        =60
    IO_61        =61
    IO_62        =62
    IO_63        =63
    IO_NULL      =65
        
class PL_IO(IntEnum):
    NUM_9         =8
    NUM_8         =9
    NUM_0         =10
    NUM_16        =11
    NUM_32        =12
    NUM_33        =13
    NUM_4         =14
    NUM_20        =15
    NUM_11        =16
    NUM_10        =17
    NUM_1         =18
    NUM_17        =19
    NUM_34        =20
    NUM_35        =21
    NUM_5         =22
    NUM_21        =23
    NUM_13        =24
    NUM_12        =25
    NUM_2         =26
    NUM_18        =27
    NUM_36        =28
    NUM_37        =29
    NUM_6         =30
    NUM_22        =31
    NUM_15        =32
    NUM_14        =33
    NUM_3         =34
    NUM_19        =35
    NUM_38        =36
    NUM_39        =37
    NUM_7         =38
    NUM_23        =39
    NUM_NULL      =65