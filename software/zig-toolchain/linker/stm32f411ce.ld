FLASH_SIZE = 0x80000; /* 512kb */
SRAM_SIZE  = 0x20000; /* 128kb */
STACK_SIZE = 0x800;   /* 2kb   */

MEMORY {
  flash (rx) : ORIGIN = 0x08000000, LENGTH = FLASH_SIZE
  sram (rwx) : ORIGIN = 0x20000000, LENGTH = SRAM_SIZE
}

ENTRY(resetHandler)

SECTIONS {
  .stack (NOLOAD) : {
    . = ALIGN(8);
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __initial_stack_pointer = .;
  } > sram

  .text : {
    . = ALIGN(4);
    LONG(__initial_stack_pointer)
    KEEP(*(.vectors))
    *(.text*)
    *(.rodata*)
    . = ALIGN(4);
  } > flash

  .data : {
    _sdata = .;
    . = ALIGN(4);
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > sram AT> flash

  _ldata = LOADADDR(.data);

  .bss (NOLOAD) : {
    _szero = .;
    . = ALIGN(4);
    *(.bss*)
    . = ALIGN(4);
    _ezero = .;
  } > sram

}
