# ============================================================
# sweetdream:equipment/axe/dream_reader/ol_hit_dmg —— 超限·释梦 被动的伤害数额
# ------------------------------------------------------------
# 【谁调用它】dream_reader/hit(③'', 仅 **超限版**)
# 【执行者】玩家(动手的那位)
# 【入参】#dr_rem = 剩余时停**秒数**(hit ③ 算好)
# 【出参】#dr_dmg = 基础攻击力×100 × 剩余秒数
#   ★ 出参**不是**最终伤害 —— 调用方统一 `store … double 0.005`
#     ⇒ 攻击力 × 秒数 × 0.5(见 hit ④)。这样基础/超限两条路只差一个 scale。
# 【原文】"…额外造成相当于自身基础攻击力（最低为10）*剩余时停时间*0.5的真实伤害"
#   · "剩余时停时间"的单位沿用**基础版**口径 = 秒(hit ③ 已 ÷20);
#   · "最低为10": 面板基础攻击力 < 10 时按 10 算 ⇒ 分数下限 1000(= 10×100)。
# 【为什么不读"面板攻击力"自己乘】manacore 的 base_attack 是**存档属性**
#   (别处加成也混在里面), 这里要的就是"自身基础攻击力"这一项 ⇒ 走
#   `manacore:api/stats/get`(与 charge/mode_on 同一套写法)。
# ============================================================

scoreboard players set #dr_dmg zx.meta 0

# ① 拿 uuid(读 manacore 存档属性要用; 拿不到 -> 出参保持 0, 即不追加伤害)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 基础攻击力 ×100(读不到时 store 不执行 -> 保持 1000 = 下限 10)
scoreboard players set #dr_atk zx.meta 1000
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #dr_atk zx.meta run data get storage manacore:out r.value 100
execute if score #dr_atk zx.meta matches ..999 run scoreboard players set #dr_atk zx.meta 1000

# ③ × 剩余时停秒数
scoreboard players operation #dr_dmg zx.meta = #dr_atk zx.meta
scoreboard players operation #dr_dmg zx.meta *= #dr_rem zx.meta
