# linux

- 这篇主要讲的是，趣谈linux操作系统，
- 我觉得有必要重新开出一篇，故此文面世

---

> linux操作系统中的概念非常多，数据结构也很多，流程也复杂。所谓“一图胜千言”，通过图的方式将这些复杂的概念、数据结构、流程表现出来，争取用一张图串起一片文章的知识点。如果能把这些图掌握了，你的知识就会行程体系和连接。在此基础深入学习就会如鱼得水

<img src="./images/linux_os_daoyan.jpg" alt="linux导图" style="zoom:67%;" />

- 六个爬坡

1. 抛弃旧的思维习惯，熟练使用linux命令行
2. 通过系统调用或者glibc，学会自己进行程序设计
   1. 如果说使用命令行的人是吃馒头的，那写代码操作命令行的人就是做馒头的
   2. 《linux环境高级编程》

3. 了解linux内核机制，反复演习重点突破
   1. 你的角色要再次面临变化，就像你蒸馒头，时间长了，发现要蒸出更好吃的馒头，就必须要对面粉有所研究
   2. 《深入理解linux内核》
4. 阅读linux内核代码，聚焦核心逻辑和场景
   1. 一开始阅读代码不要纠结一城一池的得失，不要每一行都一定搞清楚它是干嘛的，而是聚焦于核心逻辑和使用场景
   2. 《linux内核源代码情景分析》，不过内核版本比较老
5. 实验定制化linux组件，已经没人能阻挡你成为内核开发工程师了
   1. 这相当于，蒸馒头的人为了定制口味，要开始修改面粉生产流程了
6. 面向真实场景的开发，实践没有终点

<img src="./images/linux_os_kernel.jpg" alt="linux导图" style="zoom:67%;" />

<img src="./images/linux_os_luxiantu.jpg" alt="linux导图" style="zoom: 50%;" />

# linuxOS综述

- 可以将linux内核当成一家软件外包公司，以下就是一个整的启动流程，
- 可对应着下图的操作系统内核体系结构，回顾一下它们是如何组成一家公司的

<img src="./images/linux_os_zs_waibao.jpg" alt="linux导图" style="zoom: 50%;" />

<img src="./images/linux_os_zs_zongjie.jpg" alt="linux导图" style="zoom: 50%;" />

## linux命令行

- 运行程序的方法，

1. 前台运行。如若有x 执行权限，直接启动程序文件
2. 后台运行。 `nohup command >out.file 2>&1 &`  nohup表示 no hang up 不挂起
   1. 1 表示文件描述符1，标准输出；2表示文件描述符2，标准错误输出。2>&1 表示标准输出和错误输出合并了，到out.file 里
3. 以服务的方式运行

<img src="./images/linux_os_zs_commond_jichu.jpg" alt="linux导图" style="zoom: 50%;" />

## 学会系统调用

- Glibc 为程序员提供丰富的API，除了例如字符串处理、数学运算等用户态服务之外，最重要的是封装了操作系统提供的系统服务，即系统调用的封装。
- 用一个图来总结一下

<img src="./images/linux_os_zs_xtdy.jpg" alt="linux导图" style="zoom: 50%;" />





































# 系统初始化



# 进程管理

# 内存管理

# 文件系统

# 输入与输出系统

# 进程间通信

# 网络系统

# 虚拟化

# 容器化

