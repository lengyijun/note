# Rust中的macro

```
#[macro_export]
macro_rules! vec {
    ( $( $x:expr ),* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}
```

注意到并没有指定是[]还是（），以下写法都是可以的
let a=vec![1,2,3];
let b=vec!(1,2,3);


如果把,改成;,那么用法也不同了。
```
#[macro_export]
macro_rules! vec {
    ( $( $x:expr );* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}

let a=mm!(1;2;3);
let b=mm![1;2;3];
```

