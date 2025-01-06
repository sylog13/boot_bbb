# crosstool setup

## show compiler config(BBB)
~~~bash
# show toolchain
bin/ct-ng list-samples
# show info of toolchain(arm-cortex_a8-linux-gnueabi)
bin/ct-ng show-arm-cortex_a8-linux-gnueabi
~~~

## select target config(BBB)
~~~bash
# select toolchain
bin/ct-ng arm-cortex_a8-linux-gnueabi

# configure toolchain
bin/ct-ng menuconfig

# custom configure in command line
sed -i 's/CT_VCHECK="load"/CT_VCHECK=""'
sed -i 's/CT_PREFIX_DIR_RO=y/\#\ CT_PREFIX_DIR_RO\ is\ not\ set/g' .config
#echo "CT_ARCH_ARM_TUPLE_USE_EABIHF=y" >> .config
sed '/CT_ARCH_ARM_EABI=y/a CT_ARCH_ARM_TUPLE_USE_EABIHF=y' .config
sed -i 's/CT_ARCH_FPU=""/CT_ARCH_FPU="neon"/g'
sed -i 's/#\ CT_ARCH_FLOAT_HW\ is\ not\ set/CT_ARCH_FLOAT_HW=y/g' .config
sed -i 's/CT_ARCH_FLOAT_SW=y/#\ CT_ARCH_FLOAT_SW\ is\ not\ set/g' .config
sed -i 's/CT_ARCH_FLOAT="soft"/CT_ARCH_FLOAT="hard"/g' .config


# build toolchain
bin/ct-ng build
~~~

## select target config(QEMU)

~~~bash
# clean 
bin/ct-ng distclean

# select toolchain
bin/ct-ng arm-unknown-linux-gnueabi

#build toolchain
bin/ct-ng build
~~~

