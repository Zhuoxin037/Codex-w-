# ============================================================
# sweetdream:equipment/tool/thunder/bolt_dmg —— 雷鸣: 第二道闪电的额外伤害
# ------------------------------------------------------------
# 【执行者】持「雷鸣」的玩家(= 反查出来的释放者)   【执行位置】闪电原地
# 【文案】"闪电额外造成相当于自身最大魔力值 ×0.03 的伤害。"
#   ⇒ 走 max_mana_mul 通道(calc 的基数自动取 arg.uuid 那个玩家的最大魔力),
#     照 armor/styx_walk/sea_hurt_go 的定式。
# 【目标】闪电 3 格内的活体 —— distance 同时锁维度(RULES 坑 55);
#   type=!#sweetdream:no_damage 排掉玩家/marker/箭/各类 display。
# 【★ 不要在 set value 的字符串里写花括号 ★】原来这里还带了 `nbt=!{Health:0.0f}`
#   想排掉尸体 —— 结果整行解析失败("应为字面量"), 整个函数不加载(2026-10-06)。
#   原因: `data modify ... set value <NBT>` 是用 NBT 读取器读的, 引号里的 `{`/`}`
#   会让它配平错位、接着在后面的 `read:"..."` 上炸。⇒ 想给选择器加 nbt 过滤,
#   只能改成"先打标签再按 tag 选"(本包到处都这么干), 别塞进 set value 的字符串。
#   排尸体的活其实多余: /damage 打在 0 血实体上本来就无害。
# 【★ 一定要先取 uuid】api/damage 的归属与"最大魔力"都按 arg.uuid 算;
#   取不到(非玩家)就收工, 让它变成一次纯原版雷击。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
