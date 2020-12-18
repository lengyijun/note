# 如何统计SGX中EPC的信息

我们一般用htop来看系统负载。但是在SGX中，却缺少原生的工具。

后来我找到这个

https://fortanix.com/blog/2020/02/monitoring-intel-sgx-enclaves/

要运行这个，首先需要重新编译linux-sgx-driver。

源代码在 [www.github.com/fortanix/linux-sgx-driver](https://github.com/fortanix/linux-sgx-driver) 

不过年旧失修，你是跑不起来的。需要这样做

```bash
cd
git clone https://github.com/fortanix/linux-sgx-driver fortanix-linux-sgx-driver 
cd  fortanix-linux-sgx-driver 
git diff HEAD~ > /tmp/a.diff

cd 
git clone https://github.com/intel/linux-sgx-driver
cd linux-sgx-driver
git apply --3way /tmp/a.diff

# 然后按照 linux-sgx-driver 的正常步骤安装driver
```

可能有些merge错误，需要自己处理一下，就不赘述了。

新的driver会创建两个文件 `/proc/sgx_enclaves` 和 `/proc/sgx_stats` 

如果没有这两个文件，说明安装的有点问题。

可以用以下命令监控文件的变化

```bash
watch cat /proc/sgx_enclaves
watch cat /proc/sgx_stats
```

不过每个字段的含义你并看不懂，所以他还做了一层封装，达到类似与top的输出。 代码在 [www.github.com/fortanix/sgxtop](https://github.com/fortanix/sgxtop) 

按照Readme编译就行了

