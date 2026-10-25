# ============================================================
# sweetdream:internal/damage/deal —— 真正把这一下打出去(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只   【从哪来】internal/damage/one 调它
# 【为什么单独拆出来】"天穹·升痕"要在打之前把伤害值乘上去, 而宏参数在**调用那一刻**
#   就固定了 —— 所以必须"先把 zx:work a.num_str 改好, 再调这个宏"。拆出来之后,
#   one 就能在中间插一段"改数值"的逻辑(stg_mul)。
# 【有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来】
# ============================================================

# ①.4 ★★ 2026-10-20 第四次卡顿修复: 归属反查改用**计分项** ★★
#   原来这一整段有 7 处 `@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}]`。
#   spark 实测一次玩家 NBT 序列化 ≈ 10 ms(原因见 internal/damage/who 头注释),
#   7 处 ⇒ **每次命中 70 ms 顿帧** —— 就是玩家报的"打到生物卡一下"。
#   现在: 先把 4 个 int 拷进 zx:work who, 由 who 用 manacore.u0..u3 比计算出
#   zx.d_by 标签, 后面全部只认这个标签（零 NBT）。
#   ★ 为什么单独拷一份到 who: 不改 zx:work a（它在中途会被 stg_mul/vuln_tag
#     就地改写, 而 deal 的宏参数 $(u0).. 在调用那一刻就已经固化了, 两者互不影响）。
#   ★ 拷的是整份 a（含 num_str/type）, who 只读 u0..u3, 多余的键它不管。
#   ★ 先 data remove: 万一 a 不存在（理论上不会, one 一定先复原过）, 留着上一
#     次伤害的 who 会把归属错记到上一个人头上 —— 摘干净宁可变"无归属"。
data remove storage zx:work who
data modify storage zx:work who set from storage zx:work a
function sweetdream:internal/damage/who

# ①.5 空枕(头盔, 2026-10-17 批 14 补技能): 「造成伤害的时刻」与「静息兑现」都挂这里
#     ★ 为什么不等进度: 「造成伤害」要覆盖近战/弩/法球/技能真伤**全部来源**,
#       而进度只覆盖原版事件那几种。deal 是所有本包伤害的必经之路, 一处全覆盖。
#     ★ 受害者标签 zx.ep_vic 用完即摘(下一行), 不会留到下一次伤害。
#     ★ 选不到攻击者(zx.d_by 没打上) = 无归属伤害, 三行都不成立, 自然跳过。
execute if entity @a[tag=zx.d_by] run scoreboard players set @s zx.ep_vic 1
execute as @a[tag=zx.d_by,limit=1] run function sweetdream:equipment/armor/empty_pillow/on_deal
execute if entity @a[tag=zx.d_by] run scoreboard players reset @s zx.ep_vic

# ①.6 超限·剜霜的「披霜」**不在**这里 —— 它挂的是 entity_hurt_player 进度
#   (equipment/axe/frost_carve_hurt -> on_hurt), 因为文案是"每受到一次伤害",
#   而 deal 只覆盖本包投递的伤害(怪物平A / 摔落 / 岩浆都走原版)。
#   这里留一条注释是防止以后有人"顺手"再补一遍 —— 两份会一次受击扣两层。

# ② 打伤害(有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来)
#   ★★ 这两行**顺序与形状都不能动** ★★
#     · 无归属那条必须带 `return run`: 打完直接结束函数, 后面那条再也走不到
#       —— 否则"带 by 的 damage 内部可能嵌套出新的 deal, 把 zx.d_by 摘掉",
#       于是下一条又判定"没有归属" ⇒ 同一个目标被**打两次**。
#     · 带归属那条放最后: 它执行完函数就结束了, 之后没有任何命令再读 zx.d_by,
#       嵌套伤害怎么改标签都无所谓。
#   ★ 重新算一次 who: 上面 on_deal 走 tag/mark 宏, 万一将来它内部接出伤害,
#     这里重算一遍更稳（成本 = 4 次 storage 读 + 每人 4 次整数比较, 可忽略）。
function sweetdream:internal/damage/who
$execute unless entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) $(type)
$execute if entity @a[tag=zx.d_by] store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) $(type) by @a[tag=zx.d_by,limit=1]
