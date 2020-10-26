# Tantivy迁移Sgx总结




## 为什么Rust程序移植到SGX中是可行的？

主要由于Rust标准库（std）的可插拔性。由于可插拔，所以Rust对嵌入式程序有天然的友好。开发SGX程序和开发嵌入式程序也其实差不多。首先解释一下Rust中的core和std

## 为什么用Rust写SGX中的程序？

SGX程序一般用C和C++写。

但是SGX中内存受限，现在只能开到100M的内存，如果发生内存泄漏的问题，内存一会就没了。Rust也不能消除内存泄漏，但是会好一点。

另一个原因是SGX中的程序调试不方便。像Rust这样能在编译阶段就能检查出尽量多的问题，就显得很有必要。

c/c++的std在sgx中也是残疾的

### core，std和#![no_std]

core是Rust标准库中不依赖于平台的部分，可以直接用在bare metal，嵌入式，bootloader中.i32,u32,f32这些都在core里面.

std是需要操作系统支持的部分，比如内存管理(alloc)。遇到String，Box，那就一定需要std。

std中包含core。core里的东西都被std重新导出，所以一般程序只用std就行了，其实在使用core的内容。

如果一个crate或者binary，只使用core，而不是用std里的东西，那可以显式的用#![no_std]标注，表示编译的时候不要导入std

一些crate在Cargo.toml中会有no-std的feature,表示可选

在sgx中,当然只有core,没有std. 因为SGX中内存模型，线程模型都不太一样。百度的[incubator-teaclave-sgx-sdk](https://github.com/apache/incubator-teaclave-sgx-sdk) 就是重做了能在SGX中用的std。

不过有些系统调用还是没有了，比如flock，那只能砍掉了。和操作系统贴合的比较紧的库都不太容易移植。


光就标准库而言，百度的incubator-teaclave-sgx-sdk有标准std的所有功能，有些地方的名字不一样，比如thread改成了sgxThread,需要自己定位一下。

同时也解释了为什么Rust的std功能比较少。太多了移植起来就会格外麻烦。写SGX可以按需移植需要的功能。



## 如何移植Rust程序需要的crate到SGX中？

对于每个依赖,要解决的问题是std和libc
有些库,虽然没有说是no_std,但是所有的std::xxx都可以替换成core::xxx,所以也是no_std的
遇到std::io,std::sync,就不能靠core解决问题了
如果用了libc,那得看能不能用sgx的libc代替.
总之,std和libc这两个问题是并列的.只有都解决了才能顺利的跑起来.

```
def 移植(self):
    if self支持 no_std or 可以改成 no_std then
        不用修改，直接在依赖处配置好 no_std 的 features
        return
    if sgx-world 里有别人移植过的 then
    	return
    # 移植依赖项 
    # (忽略dev-dependencies）
    # (忽视window macos下的依赖)
    for each dep of self.dependencies
        移植 dep
        
    # 移植自身
    (1) 下载crate源代码 (github或者cargo clone)
    (2) 编辑 Cargo.toml 修改每个依赖项为移植后的依赖项
    (3) 编辑 src/lib.rs 添加特定header（见后文）
    (4) 编辑每个源文件 添加 use std::prelude::v1::*;
    (5) 仔细review每个使用 fs/path/net/time/env 等不可信输入的地方，修正那里的逻辑
    (6) 检查每个 platform dependent 的 feature，将其固定为只适用于 linux-x86_64 的逻辑（因为 linux-SGX 就只有这个环境）
    (7) 测试 `cargo build` 是否通过
    return
```


## 相关资料

百度的论文，在他的git仓库中

百度的开发者写的[教程](https://github.com/dingelish/SGXfail) ，最好从头到尾看一下

[sgx-world](https://github.com/dingelish/sgx-world) 是别人已经移植的一些库，可以直接用。移植的也比较好


## Tantivy简介

tantivy是一个文本搜索引擎，功能和lucene一样。

lucene是文本搜索引擎的第一选择。不过由于他是java写的，不太方便移植到SGX中，所以我们选择用Rust写的Tantivy。

Tantivy的性能比lucene[略差一点](https://tantivy-search.github.io/bench/)。这是比较奇怪的，因为Rust程序一般比Java快一点。但是各种搜索模式基本都是支持的。性能测试的源码在 https://github.com/tantivy-search/search-benchmark-game

## 移植Tantivy

总的来说还是比较轻松的,

就是flock,inotify这些系统调用没有

连 futures的std feature也被我改成sgx模式了

大部分的库,只要编译通过,最后也能运行

为了方便给源文件添加 `use std::prelude::v1::*;` ,我写了一个bash命令

```bash
prelude () {
	for file in $1/**/*
	do
		sed -i '1s/^/use std::prelude::v1::*;\n/' $file
	done
}
```



使用方法是,走到src目录,然后 `prelude .` 

之所以一定需要一个参数是因为如果误敲了`prelude` 命令,后果还是挺严重的.

改完Tantivy之后,也明白了为什么rust的标准库很小,而依赖于crate. 甚至标准异步库 `futures` 也要从crate引用.

原因是遇到类似与sgx的嵌入式设备,库的可插拔就变得非常重要了.标准库里的东西太多,删起来就麻烦了

迁移后的Tantivy依然利用了sgx内的多线程和异步特性,所以总的性能损失不大.默认至少8个TCS,所以在`Enclave.config.xml` 中

```xml
<TCSNum>8</TCSNum>
```

Tantivy需要至少30M内存,内存不足会发生segment fault问题.所以按需求改一下:

```xml
<HeapMaxSize>0x1000000</HeapMaxSize>
```



## 遇到这样的报错

```
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::getenv':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall6getenv17h116a2a586f33112bE+0x11): undefined reference to `u_getenv_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::getcwd':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall6getcwd17hba50fd9ef377ef91E+0x28): undefined reference to `u_getcwd_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::epoll_create1':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall13epoll_create117hb84795a1668aaa2bE+0x23): undefined reference to `u_epoll_create1_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::epoll_ctl':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall9epoll_ctl17h68a1a0451509f015E+0x2b): undefined reference to `u_epoll_ctl_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::epoll_wait':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall10epoll_wait17h97e976b76c9edb55E+0x2c): undefined reference to `u_epoll_wait_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::sysconf':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall7sysconf17h1b7d494878ba80f7E+0x24): undefined reference to `u_sysconf_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::prctl':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall5prctl17hf87a63094223de3fE+0x33): undefined reference to `u_prctl_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::pipe':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall4pipe17h28c669669e62c9e0E+0x24): undefined reference to `u_pipe_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::sched_yield':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall11sched_yield17h4acef8a951cb448aE+0x21): undefined reference to `u_sched_yield_ocall'
/usr/bin/ld: ./lib/libenclave.a(sgx_libc-d53b1957651f62ed.sgx_libc.50v6zrcg-cgu.5.rcgu.o): in function `sgx_libc::linux::x86_64::ocall::nanosleep':
sgx_libc.50v6zrcg-cgu.5:(.text._ZN8sgx_libc5linux6x86_645ocall9nanosleep17hdafd22d0a820d60eE+0x27): undefined reference to `u_nanosleep_ocall'
```

说明edl加的少了,可以把edl全部加上去

# ChangeLog
## tempfile
去掉了 `O_TMPFILE` 这个属性

## fs2
fs2的封装了flock
但是sgx中没有flock
在leveldb的sgx实现中,也把flock调用去掉了
我暂时也只能去掉了

## crossbeam
去掉了stack_size 函数,因为thread.Builder没有stack_size函数
std::process::abort() 改成了 libc::abort()

## num_cpus
这个库就去掉了,当作只有一个CPU.参考了rust_thread_pool中的实现

