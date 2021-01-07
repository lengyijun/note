# 内存

## Q1：当一个EPC页从DRAM交换回EPC的时候，他还会到原先的物理页位置吗？

不会

driver会找到一个空闲的EPC页分配给他。找到哪个就是哪个了



## Q2: sdk与psw有什么区别？

sdk是给enclave（安全区）用的

psw是给app（非安全区）用的



## Q3： 为什么要用修改过的as ld ld.gold？ 源码在哪里？

不知道。找不到源码