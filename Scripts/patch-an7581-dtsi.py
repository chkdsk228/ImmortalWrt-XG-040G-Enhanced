#!/usr/bin/env python3
"""给 an7581.dtsi 的 cpufreq 节点补上 chip-scu reg 定义（修复 CPUFreq 驱动 probe 失败）"""
import sys
import re

path = sys.argv[1] if len(sys.argv) > 1 else 'an7581.dtsi'

with open(path, encoding='utf-8') as f:
    content = f.read()

# 定位 cpufreq 节点（只检测节点内部，避免误判其他节点的 chip-scu）
m = re.search(r'\tcpufreq: cpufreq \{[^\n]*', content)
if not m:
    print("ERROR: cpufreq node not found in DTS")
    sys.exit(1)

node_start = m.end()  # 在 '{' 之后

# 找节点结束（下一个同级别 '};'）—— 简单方式：取到 operating-points-v2 行即可
node_snippet_end = content.find('operating-points-v2', node_start)
if node_snippet_end == -1:
    node_snippet_end = len(content)

node_snippet = content[node_start:node_snippet_end]
if 'chip-scu' in node_snippet:
    print("chip-scu already in cpufreq node, skip")
    sys.exit(0)

# 在节点开括号后插入 reg 定义
insert_at = node_start
reg_block = ('\n'
             '\t\treg = <0x0 0x1fa20000 0x0 0x2c0>, <0x0 0x1efbe000 0x0 0x800>;\n'
             '\t\treg-names = "chip-scu", "mcucfg";')

content = content[:insert_at] + reg_block + content[insert_at:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("chip-scu reg added to cpufreq node")
