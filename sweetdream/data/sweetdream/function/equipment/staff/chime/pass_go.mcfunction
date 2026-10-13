# ============================================================
# sweetdream:equipment/staff/chime/pass_go —— "法术穿过"的伤害结算(宏)
# ------------------------------------------------------------
# 【谁调用它】pass_set(反查到的释放者; `with storage zx:work chp`)
# 【宏参数】mm2 = 倍率(原版 0.05 / 超限 0.1; 由 pass_check 按水晶的 ol 写好)
# 【执行者】释放者玩家   【位置】水晶处(由调用链保留; 但本文件不依赖坐标)
# 【伤害】释放者最大魔力值 ×mm2 -> max_mana_mul 通道。
# 【目标范围】pass_set 圈好的 zx.ch_p(= 水晶 3/5 格内 + 超限另加释放者 3 格内的全部生物)。
# 【★ 本文件不许出现 ~ / distance= ★】它是在 "as 释放者" 的链上被调的,
#   check 规则 asnoat 认定"as 不换坐标"; 目标一律走**标签**(与坐标无关)最稳。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid

# ② 算伤害(最大魔力 ×mm2)
$data modify storage manacore:in arg set value {uuid:"",max_mana_mul:$(mm2)}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去(3 格内全部)
data modify storage zx:in arg set value {target:"@e[tag=zx.ch_p]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
