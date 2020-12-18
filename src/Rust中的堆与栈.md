# Rust中的堆与栈

只有Size的变量能放在栈上。长度不固定的变量不能放在栈上？

Box<>是分配在堆上的变量

Vector<>是分配在堆上的变量

有一个crate叫smallvec，他在数量少的时候分配在stack上，数量大了分配到heap上