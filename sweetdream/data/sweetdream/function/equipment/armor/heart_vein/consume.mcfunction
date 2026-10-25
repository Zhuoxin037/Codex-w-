# ============================================================
# sweetdream:equipment/armor/heart_vein/consume —— 心脉: 自身消耗「噬心」⇒ 上「泵动」
# ------------------------------------------------------------
# 【谁调用它】lib/on_consume 第 ⑥ 条（`execute as $(by)` ⇒ @s = **消耗者**）
# 【宏参数】zx:work mc {target, mark, by, src}
#   · target = 被消耗掉「噬心」的那一只（这是"泵动"要挂的目标）
#   · by     = 消耗者（穿心脉的人）
# 【文案(逐字)】"若自身消耗了「噬心」效果则使其附加持续 5 秒的「泵动」（最多 12 秒）。"
#   "在此期间若其再次被消耗「噬心」则使「泵动」持续时间叠加且使其立即受到一次
#    相当于其最大生命值 ×0.08 的伤害并使自身恢复相当于自身最大魔力值 1% 的魔力值。"
# 【★ 不按 src 过滤 ★】文案写的是"自身消耗了「噬心」", 没有限定"技能消耗" ——
#   装备被动顺手消耗（归息/殓丝那类 src:"equip"）也算（与杂纹同口径）。
# 【★ 为什么先整份拷进 zx:work hv ★】mc 是消耗链的共用节点, 下面 pump_new /
#   pump_add 还要调 tag / attribute / damage 那些函数, 谁都可能动 storage。
#   hv 是本件专用节点, 与 zx:work ob / a / mc 都不冲突。
# 【★ 「泵动」是私有资源 ★】不进标签词表（通用状态只有五个, _chk_tags 守着）。
# ============================================================

# ① 冻结入参到本件专用节点
data modify storage zx:work hv set from storage zx:work mc

# ② 已带「泵动」⇒ 叠加时长 + 立即 ×0.08 + 自身回 1% 最大魔力
$execute as $(target) if entity @s[tag=zx.hv_pump] run function sweetdream:equipment/armor/heart_vein/pump_add with storage zx:work hv

# ③ 没带 ⇒ 新附 5 秒「泵动」
$execute as $(target) unless entity @s[tag=zx.hv_pump] run function sweetdream:equipment/armor/heart_vein/pump_new with storage zx:work hv
