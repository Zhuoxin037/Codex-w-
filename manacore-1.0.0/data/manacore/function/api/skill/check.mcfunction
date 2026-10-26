# ============================================================
# api/skill/check —— 技能能否释放(只读)
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"mypack:fireball", mana:20.0}
#          function manacore:api/skill/check
# 【出参】out.success(1b 可释放) / out.ready(冷却) / out.remaining / out.reason
#          reason: "ok" / "cooldown" / "mana" / "invalid_uuid" / "invalid_skill"
# 【用途】按下技能键时先查, 决定是"施放/灰显/提示蓝不够"。
# 【完全不改数据】不扣蓝、不进冷却, 随便高频调用。
# ------------------------------------------------------------
# 【★ 失败默认关闭(2026-10-10, 修 F19)★】
#   原来把 success/ready 预置成 1b, 于是"缺 skill"时 —— 内部校验那行不跑 ——
#   1b 就那么原样留下, **错误调用被伪装成"可以放"**。
#   现在: 一开始全置 0b / reason="invalid", 只有**校验全过**才翻成 1b / "ok",
#   之后内部校验若发现不够蓝/在冷却, 再改回 0b。任何一条拒绝路径都是 0b。
# 【★ 为什么不能用 `if data ... a.uuid` 当必填校验 ★】
#   默认值里就写着 uuid:"" / skill:"" —— 空串**也是存在的字段**, 那个判据恒真,
#   等于没判。要判"非空"只能用复合匹配 `{uuid:""}`, 再取反。
# 【为什么要在 API 层拦】api/player/ensure 会拿 a.uuid 去 players 下建记录,
#   空串会建出 players."" 这种垃圾键(见 internal/player/ensure 的守卫)。
# ============================================================
data modify storage manacore:work a set value {uuid:"",skill:"",mana:0.0}
data modify storage manacore:work a merge from storage manacore:in arg

# ---- 失败默认关闭 ----
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.ready set value 0b
data modify storage manacore:out r.reason set value "invalid"

# ---- 必填校验(空串 = 没给) ----
execute if data storage manacore:work a{uuid:""} run data modify storage manacore:out r.reason set value "invalid_uuid"
execute if data storage manacore:work a{uuid:""} run return 0
execute if data storage manacore:work a{skill:""} run data modify storage manacore:out r.reason set value "invalid_skill"
execute if data storage manacore:work a{skill:""} run return 0

# ---- 校验通过: 先置 1b, 再由内部校验在"不够蓝 / 在冷却"时改回 0b ----
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.ready set value 1b
data modify storage manacore:out r.reason set value "ok"
execute if entity @s[type=minecraft:player,scores={zx.j_sorrow=1}] run function sweetdream:profession/mage/sorrow_check
function manacore:internal/skill/check with storage manacore:work a

execute if entity @s[type=minecraft:player,scores={zx.j_sorrow=1,zx.j_cast_a=0}] if data storage manacore:out r{success:1b} run function sweetdream:profession/mage/sorrow_checked
