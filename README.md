sha256的硬件实现
内核包括：4级流水线优化，多核并行处理。
接口为串口接口，每次输入填充后的10个块即可进行运算。

文件列表：

    source code:
    sha256_const.v      存储的常量
    sha256_core.v       计算的单个内核
    sha256_top.v        计算的4核顶层

    testbench:
    Monitor.v           用于监测输出的正确性
    Fake_CPU.v          用于激励任务的编写
    testcase.v          产生激励的文件
    top_tb.v            tb的顶层文件

    gloden_result_generate:
    源.c                c代码，用于生成黄金结果
    data1.txt           用于生成黄金结果的字符串

    test_data:
    data.txt            生成的测试向量
    out.txt             利用golden_result_generate产生的黄金测试结果