# ============================================================
# sweetdream:equipment/armor/mirror_sleep/apply —— 镜寐: 兑现那一次「白昼梦」
# ------------------------------------------------------------
# 【谁调用它】mirror_sleep/hit ③（条件已判: 武装中 + 目标未带白昼梦）
# 【执行者】玩家（动手的那个人）
# 【★ 扣魔力失败时**保留武装** ★】文案是"若自身魔力足够则消耗 30 魔力并…" ——
#   不够就这一次不做; 武装留着, 下次打到未带梦的目标再试（不白吃玩家的 3 次攻击）。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 消耗 30 魔力（够才扣；不够就保留武装, 直接收工）
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ③ 给目标附加「白昼梦」（附着 -> tag/mark）
data modify storage zx:work ic set value {target:"@e[tag=zx.victim,limit=1]",mark:"dream"}
function sweetdream:tag/mark with storage zx:work ic

# ④ 解除武装（这一次的 3 次攻击已兑现）
scoreboard players set @s zx.ms_arm 0

# ⑤ 表现
execute at @e[tag=zx.victim,limit=1] run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:block.amethyst_block.place player @a ~ ~ ~ 0.5 1.5

# ⑥ ★ 浅梦套装: "为**原本未附有**白昼梦的生物成功附加白昼梦后" ★
#   走到这里就说明: 目标原本没带(③ 外面的条件判过) + 真的挂上了(③ 已执行)。
#   套装的两件判定与节流在叶子件里。
function sweetdream:equipment/armor/light_pillow/set_apply
