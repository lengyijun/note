# 迁移tempfile到sgx中

首先下载源码：

```
git clone https://github.com/Stebalien/tempfile
```

忽略windows下的特定依赖。忽视devdependency。
tempfile只有两个依赖remove_dir_all和rand需要处理，所幸这两个依赖都不难处理。

## 处理remove_dir_all

remove_dir_all只是一个跨平台的封装.我们把这个依赖去掉,用`std::remove_dir_all`代替即可



## 处理rand

这个直接改成 https://github.com/mesalock-linux/rand-sgx



## 处理libc

首先把Cargo.toml中的libc依赖去掉

加入下面这段

```
[target.'cfg(not(target_env = "sgx"))'.dependencies]
sgx_tstd = { version = "1.0", rev = "v1.1.2", git = "https://github.com/apache/teaclave-sgx-sdk.git", features=["untrusted_fs","thread", "backtrace"] }
sgx_libc = { version = "1.0", rev = "v1.1.2", git = "https://github.com/apache/teaclave-sgx-sdk.git" }

```

在`src/lib.rs`的开头写

```
#![no_std]
use std::prelude::v1::*;
#[macro_use]
extern crate sgx_tstd as std;
extern crate sgx_libc as libc;
```

到这一步,`cargo b` 一下.会看到一堆错误

```
error[E0432]: unresolved imports `libc::link`, `libc::rename`, `libc::unlink`
  --> src/file/imp/unix.rs:11:27
   |
11 | use libc::{c_char, c_int, link, rename, unlink};
   |                           ^^^^  ^^^^^^  ^^^^^^ no `unlink` in the root
   |                           |     |
   |                           |     no `rename` in the root
   |                           no `link` in the root

```

首先是这个link找不到的问题,需要该一下路径

```
use libc::{c_char, c_int};
use libc::ocall::{link, rename, unlink};
```



然后是

```
64 |     use libc::{EISDIR, ENOENT, EOPNOTSUPP, O_EXCL, O_TMPFILE};
   |                                                    ^^^^^^^^^ no `O_TMPFILE` in the root

```

这里没办法,只能不用`O_TMPFILE`了

最后是

```
error: duplicate lang item in crate `std`: `f32_runtime`.
  |
  = note: the lang item is first defined in crate `sgx_tstd` (which `tempfile` depends on)

```

需要把每一个rs文件的开头都加上

```
use std::prelude::v1::*;
```

虽然不是每个文件都必要加,但我也分不清哪些需要,所有都加了,也没关系

现在`cargo b`应该就不会报错了



