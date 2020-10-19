遇到要dockerfile里面要安装go依赖,一般就比较麻烦

我的方案是

安装brook

```asciidoc
brook socks5tohttp -l 0.0.0.0:8080 -s 127.0.0.1:1080

export http_proxy=172.17.0.1:8080 
export https_proxy=172.17.0.1:8080 
```

然后就好了

