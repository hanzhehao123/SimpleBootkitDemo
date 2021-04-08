# 简单的MBR bootkit
将原始MBR复制到第二个扇区

写入bootkit到MBR，填充分区表

跳到第二扇区执行原始MBR

## 关于bootkit

需要输入密码才能开机，密码可以在原始汇编代码中编辑