# ============================================================
# sweetdream:lib/dmg_ch —— 快照"本次技能走了哪条倍率通道"
# ------------------------------------------------------------
# 【谁调用它】★ 必须是 #manacore:event/damage_calc 里的**第一个**条目 ★
#   (见 sweetdream/data/manacore/tags/function/event/damage_calc.json)
# 【它做什么】把 manacore:work a 整份抄进 zx:work ch。
# 【★★ 为什么非抄不可(这是一个会静默失效的坑)★★】
#   前置包 manacore/internal/damage/calc 在算完之后(line 104)抛 damage_calc 事件,
#   此时 manacore:work a 里 max_mana_mul / attack_mul / other_mul 三条通道都还在
#   —— 这是"这个技能走的是哪条通道"的**唯一凭据**。
#   但是! 同一个事件里更早/更晚跑的 hook 会把它**整份重置**:
#     · equipment/armor/resonance/hook_calc 会调 manacore:api/formation/count,
#       而那个接口第一行就是 `data modify storage manacore:work a set value {uuid:""}`
#       —— 三条通道当场清零;
#     · resonance/hook_calc 还会调 lib/uuid -> api/player/self_uuid, 它往
#       manacore:work a.i 里写东西(同样是在动这个节点)。
#   ⇒ 谁在后半段读 manacore:work a.attack_mul, 读到的**永远是 0**
#     (被补默认值/被重置), 于是"按通道区分"的装备加成**一次都不会生效**,
#     而且一个字都不报。所以必须在事件最前面拍一张快照, 后面一律读快照。
# 【为什么是整份拷贝而不是挑几个字段】三个字段都要用, 而且"整份 set from"只是一行;
#   挑字段写三行反而更容易漏。下次要判 other_mul 也不用改这里。
# 【出参】zx:work ch = {max_mana_mul, attack_mul, other_mul, uuid, ...}(整份 a)
# 【★ 顺序由 check 规则 dmgch / dmgord 锁死 ★】改 tag 顺序会把它挪走 -> check.py 报错。
#   · 必须是**第一条**(dmgch)
#   · 紧跟其后的第二条必须是 lib/dmg_add_clear(清加算池), 否则上一次施法的
#     加算贡献会留着 —— 见 lib/dmg_add_clear 头注释(dmgord)
#   · 末尾必须是 lib/dmg_add_apply(统一乘加算) -> 独立乘区 hook 排在它之后
# ============================================================

data modify storage zx:work ch set from storage manacore:work a
