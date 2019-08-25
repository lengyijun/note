# Cors

cors是前端的常见问题。比如在localhost:9000开放了http server，你可以在命令行中用curl/httpie来访问。在这种非浏览器环境中，不存在跨域请求这个问题。

但是在浏览器中，出于安全考虑，对于跨域有着不一样的处理。首先明确一下哪些场合是跨域的：在127.0.0.1:3000的web前端中访问127.0.0.1:9000就是跨域的。

浏览器在遇到跨域请求时，会先发一个option包。如果server不能处理好这个option包，那么前端就会报cors错误，后端（server）就回报options处理错误。

解决这个问题多半要从后端入手。如果用的是express，可以装一个cors的包。如果是django，好像是加一个中间层（存疑）。如果是rpc，那么至少要能处理option请求。

如果有一个前端，无论如何要调用一个rpc协议，但是rpc server没有处理好cors的option请求。这个时候有一个绕过的方法：多写个能处理cors的后端（express）。前端访问后端，走cors。后端访问rpc，因为不在浏览器环境里，所以没有option请求包。

---

把后端和前端写在同一个端口可能需要对项目结构做出巨大的改变。如果想省事，后端开在9000，前端开在3000，而且后端和前端之间使用同源策略，可以在前端的package.json中加上这句

```
 "proxy": "http://127.0.0.1:9000/"
```

然后我们前端的 url 我们可以更加简短

```
        var url = "/api/create"
        fetch(url,{
                method:'POST',
                body:...
        }).then()
```

---

最后一种方法是，将前端封装到electron中。在electron中你可以禁用option（存疑，道听途说的）



如果后端一时半会儿无法支持,也可以通过修改浏览器的配置来绕过cors

```
google-chrome --disable-web-security --user-data-dir
```



