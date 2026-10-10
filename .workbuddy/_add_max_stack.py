# -*- coding: utf-8 -*-
"""
给"底板本身能堆叠"的自制物品补 max_stack_size=1(不可堆叠)。

【为什么只补这 9 件, 不是全部 28 件】
  剑 / 盔甲 / 斧 / 弩 这些底板的原版最大堆叠本来就是 1, 不用加。
  而且 1.21.5 的 max_stack_size **不能和 max_damage 同时存在**
  (能堆叠的东西不能同时有耐久), 给带耐久的物品硬加会有风险。
  真正需要加的是底板能堆的那些:
    recovery_compass(16)  -> 风行于大地之上 / 观测镜
    amethyst_shard / echo_shard / nether_star / prismarine_* / heart_of_the_sea(64)
    netherite_upgrade_smithing_template(64)

【改了 give 之后】已经在世界里的旧物品不受影响(还是能堆), 要重新 give。
【可重跑】已经带 max_stack_size 的会跳过。
"""
import io, os, re

BASE = "D:/数据包/sweetdream/data/sweetdream/function"

TARGETS = [
    "equipment/staff/wind_ontheground/give.mcfunction",
    "equipment/tool/look/give.mcfunction",
    "upgrade/item/mana_up_a.mcfunction",
    "upgrade/item/mana_up_b.mcfunction",
    "upgrade/item/mana_up_o.mcfunction",
    "upgrade/item/mana_gain_a.mcfunction",
    "upgrade/item/mana_gain_b.mcfunction",
    "upgrade/item/mana_gain_o.mcfunction",
    "overlimit/item/liuguang.mcfunction",
]

n_patch = 0
for rel in TARGETS:
    p = os.path.join(BASE, rel).replace("\\", "/")
    s = io.open(p, encoding="utf-8").read()
    if "max_stack_size" in s:
        print("skip(已有):", rel)
        continue
    # 在 "give @s <底板>[" 的方括号开头插一个组件, 插在开头最省事也最安全
    # (不用去匹配那一长串组件末尾的 ] —— 里面有 lore=[...] 之类的嵌套)
    m = re.search(r"(give @s [a-z_]+\[)", s)
    if not m:
        print("!! 没找到 give 行:", rel)
        continue
    s2 = s[:m.end()] + "max_stack_size=1," + s[m.end():]
    io.open(p, "w", encoding="utf-8").write(s2)
    n_patch += 1
    print("patched:", rel)

print("--- 共改:", n_patch, "---")

# 复核
print("=== 复核 ===")
for rel in TARGETS:
    p = os.path.join(BASE, rel).replace("\\", "/")
    s = io.open(p, encoding="utf-8").read()
    m = re.search(r"give @s ([a-z_]+)\[", s)
    print("%-52s %-34s %s" % (rel, m.group(1) if m else "?",
                              "OK" if "max_stack_size=1" in s else "缺失!"))
