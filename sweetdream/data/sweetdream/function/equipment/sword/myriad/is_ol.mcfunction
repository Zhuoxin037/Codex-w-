# ============================================================
# sweetdream:equipment/sword/myriad/is_ol —— 手里这把是不是**超限版**
# ------------------------------------------------------------
# 【出参】#mq_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 两把都要认 ★】超限石敲在「万念」上(ol:"myriad"), 而放一次技能就会切成
#   「千散」 —— 千散身上也带着同一个 ol 标记(换手时由 swap_post 补上),
#   否则"换了一把刀就不是超限版了"。所以这里两个 zx 都判一遍。
# 【★ 主副手都要判 ★】换手那套(put_qian / put_my)是"主手优先、副手兜底",
#   刀拿在副手时换手照常发生 —— 唯独这里判不出来的话,
#   "副手放技能永远是基础版"(没有领域/剑魂/居合)。两侧行为必须一致。
# ------------------------------------------------------------
# 【★ 判据: 一条 `if items` 复合谓词解决 ★】(2026-10-08 改成标准写法)
#   和包里那几件**已经在跑**的超限装备一字不差:
#     · equipment/armor/dusk_dawn/is_ol      : armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"],       ol:"dusk_dawn"}]
#     · equipment/armor/stellar_elegy/is_ol  : armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"],ol:"stellar_elegy"}]
#     · equipment/armor/brain_leech/passive  : armor.head diamond_helmet[custom_data~{ol:"brain_leech"}]
#   ⇒ 物品 id + 部分匹配(~) + zx 和 ol 写在**同一个**谓词里, 这是本包的标准做法。
#
#   【为什么换掉上一版】上一版是"物品谓词认武器 + `if data entity @s SelectedItem
#   ...{ol:"myriad"}` 读 NBT 认 ol"两段式。那段 `if data` 语法本身是合法的
#   (包里大量在用 `if data storage zx:out r{ok:1b}` 这种写法), 但它依赖主手那条
#   **虚拟只读路径**, 一旦换手时序有任何闪失就会静默判 0 —— 而这段判据一动,
#   领域 / 剑魂 / 居合 / 特殊技能窗口会**同时**失效且一个字不报。
#   换成和盔甲侧同源的单条 items 谓词后, 主副手共用一套成熟写法, 排查面小得多。
# ============================================================

scoreboard players set #mq_ol zx.meta 0

# ① 主手是万念 / 千散, 且带 ol:"myriad"
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["myriad"],ol:"myriad"}] run scoreboard players set #mq_ol zx.meta 1
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["qiansan"],ol:"myriad"}] run scoreboard players set #mq_ol zx.meta 1

# ② 副手那两条(拿副手施法时, 上面两条一个都不会命中)
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["myriad"],ol:"myriad"}] run scoreboard players set #mq_ol zx.meta 1
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["qiansan"],ol:"myriad"}] run scoreboard players set #mq_ol zx.meta 1
