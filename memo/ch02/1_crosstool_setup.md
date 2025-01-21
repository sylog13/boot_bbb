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

# build toolchain
bin/ct-ng build
~~~

## check toolchain info

특이하게도 다른 리눅스 명령들과는 다르게 -v와 --version이 같은 의미가 아니다.
--version은 버전을 출력하고, -v 는 컴파일러의 정보를 출력한다.
버전을 확인하려면:
~~~bash
# Check version
arm-cortex_a8-linux-gnueabi --version
~~~

컴파일러의 정보를 보려면:
~~~bash
# Check Configuration information
arm-cortex_a8-linux-gnueabi -v
~~~
Some printed configurations after run above command:
 - --with-sysroot=~/...<생략>/sysroot: sysroot directory
 - --enable-languages=c,c++: enable C, C++
 - --with-cpu=cortex-a8, --with-tune=cortex-a8:
 - --with-floag=hard: create code for floating point device. use VFP register
 - --enable-threads=posix: POSIX 스레드를 사용한다.

컴파일러의 타겟 아키텍쳐를 변경하려면:
~~~bash
arm-cortex_a8-linux-gnueabi-gcc -mcpu=cortex-a5 helloworld.c -o helloworld
~~~

이렇게 일반적인 컴파일러를 구성해놓고 CPU에 맞게 수정하는 것이 yocto 방식이라고 한다.  
반면에, 나중에 잘못될 위험이 줄도록 모든 것을 처음부터 설정하는 방식은 Buildroot 방식이라고 한다.    

readelf명령을 사용하면 컴파일된 실행파일(바이너리)의 정보들(라이브러리, 아키텍쳐)을 확인할 수 있다.  
저자 분께서는 readelf를 사용해서 링크된 라이브러리 목록을 출력하는 스크립트(list-libs)를 따로 만들어놓으셨다.  
깃허브 url은 아래와 같고, 나는 내가 사용하기 편하게 이 디렉토리에 올려두었다.
github url: https://github.com/PacktPublishing/Mastering-Embedded-Linux-Programming-Third-Edition.git
~~~bash
arm-cortex_a8-linux-gnueabihf-gcc myprog.c -o myprog -lm
arm-cortex_a8-linux-gnueabihf-readelf -a myprog
boot_bbb@sy-desktop:~/kernel/memo/ch02$ export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-
boot_bbb@sy-desktop:~/kernel/memo/ch02$ ./list-libs myprog

# shell script(list-libs)
#!/bin/sh
# List shared libraries that a program is linked to
#  Chris Simmonds, chris@2net.co.uk

if [ $# != 1 ]; then
    echo "Usage: $0 [progam file]"
    exit 1
fi
${CROSS_COMPILE}readelf -a $1 | grep "program interpreter"
${CROSS_COMPILE}readelf -a $1 | grep "Shared library"
exit 0
~~~

## 라이브러리
### 정적 라이브러리 생성, 링킹
~~~bash
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc -c test1.c 
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc -c test2.c 
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-ar rc libtest.a test1.o test2.o
## libtest.a is created.
boot_bbb@sy-desktop:~/kernel/memo/ch02$ ll
total 60
drwxr-xr-x 2 boot_bbb boot_bbb  4096 Jan 20 16:04 ./
drwxr-xr-x 3 boot_bbb boot_bbb  4096 Jan 20 15:29 ../
-rw-r--r-- 1 boot_bbb boot_bbb  3547 Jan 20 16:02 1_crosstool_setup.md
-rw-r--r-- 1 boot_bbb boot_bbb   190 Jan 20 15:55 helloworld.c
-rw-r--r-- 1 boot_bbb boot_bbb  2324 Jan 20 16:04 libtest.a
-rw-r--r-- 1 boot_bbb boot_bbb    67 Jan 20 16:02 test1.c
-rw-r--r-- 1 boot_bbb boot_bbb  1056 Jan 20 16:04 test1.o
-rw-r--r-- 1 boot_bbb boot_bbb    67 Jan 20 16:03 test2.c
-rw-r--r-- 1 boot_bbb boot_bbb  1056 Jan 20 16:04 test2.o
~~~

helloworld.c에 test1.c, test2.c 함수들을 부르는 부분을 추가한다.  
header file도 추가한다.  
helloworld를 컴파일할 때 라이브러리위치와 헤더파일 경로를 넣어서 링킹되도록 한다.  
~~~bash
boot_bbb@sy-desktop:~/kernel/memo/ch02$ vim helloworld.c 
boot_bbb@sy-desktop:~/kernel/memo/ch02$ mkdir inc
boot_bbb@sy-desktop:~/kernel/memo/ch02$ mkdir libs
boot_bbb@sy-desktop:~/kernel/memo/ch02$ cp libtest.a libs/
boot_bbb@sy-desktop:~/kernel/memo/ch02$ vim inc/test1.h
boot_bbb@sy-desktop:~/kernel/memo/ch02$ vim inc/test2.h
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc helloworld.c -ltest -L./libs -I./inc -o helloworld
~~~

### 공유 라이브러리 생성, 링킹
이번에는 공유 라이브러리를 생성해보자.
~~~bash
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc -fPIC -c test1.c 
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc -fPIC -c test2.c 
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc -shared -o libtest.so test1.o test2.o
boot_bbb@sy-desktop:~/kernel/memo/ch02$ ll
total 96
-rwxr-xr-x 1 boot_bbb boot_bbb  8428 Jan 20 16:12 libtest.so*
-rw-r--r-- 1 boot_bbb boot_bbb    67 Jan 20 16:02 test1.c
-rw-r--r-- 1 boot_bbb boot_bbb  1072 Jan 20 16:11 test1.o
-rw-r--r-- 1 boot_bbb boot_bbb    67 Jan 20 16:03 test2.c
-rw-r--r-- 1 boot_bbb boot_bbb  1072 Jan 20 16:11 test2.o
boot_bbb@sy-desktop:~/kernel/memo/ch02$ 
~~~

이번에는 공유 라이브러리를 링킹해서 helloworld를 만들어 보자.
~~~bash
boot_bbb@sy-desktop:~/kernel/memo/ch02$ cp libtest.so libs/
boot_bbb@sy-desktop:~/kernel/memo/ch02$ arm-cortex_a8-linux-gnueabihf-gcc helloworld.c -ltest -L./libs -I./inc -o helloworld
# 링커는 기본 검색 경로(/lib, /usr/lib)에서 먼저 찾는다. 그 이외의 경로에 추가하고 싶다면.. 
# 타겟 보드 루트파일시스템 중 /usr/local/bin경로에 shared library를 추가한다면 
# 다음 라인을 실행해주어야 한다.
export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH
~~~


