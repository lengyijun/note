# Client Router & Server Router

client router: react-dom-router

server-router: express router, beego router

当我们先用react开发单页面应用的时候,一般会使用react-router这种简单的router来控制.接下去我们会npm run build,把react编译成原生的html,css和javascript.这种文件可以用\`python -m SimpleHTTPServer\` 来启动,也可以

\`serve -s build\` 其中serve是一个nodejs的包,可以用yarn安装一下.

---

不过后端还是终有一天要和前端合并在一起的.这个时候会出现路由从哪里找这个问题:比如localhost:300/success

这个路由可以由前端控制,也有可能从后端控制.

我们显然希望还是从前端控制,因为如果从后端控制,岂不是所有的前端的代码都得用html重新写一遍.现在还有谁会写原生的html代码和css代码.

好在express和beego都能支持server router和client router同时存在.

我们在express的router最后加上通配符,那么express本身不解析success路由,还是交给前端处理路由.index.html就是react编译出来的html

```js
// All expressjs routes
// then
app.get('*', (req, res) => {                       
  res.sendFile(path.resolve(__dirname, 'the path to your react project', 'index.html'));                               
});
```



