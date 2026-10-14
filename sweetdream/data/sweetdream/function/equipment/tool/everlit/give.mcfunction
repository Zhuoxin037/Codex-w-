# ============================================================
# sweetdream:equipment/tool/everlit/give —— 给一件「长明」（副手 · 终端）
# ------------------------------------------------------------
# 【custom_data】"everlit" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["everlit"]}]
# 【数值要和实现对上】副手持有时在自身位置常驻一只“灯灵”(同时只有 1 只);
#   灯灵每 2 秒对自身 6 格内最近的一个生物造成一次相当于自身**当前魔力值
#   ×0.02** 的**真实伤害**; 自身魔力值低于 200 时灯灵熄灭, 不造成伤害。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【生命周期】由 lib/second 每秒管: 持有时补召唤、不持有时**主动撤**(坑 142:
#   持久表现必须主动撤, duration 只当兜底)。主人离线/换维度也自动撤。
# 【★ 灯灵是 marker ★】没有碰撞箱、不能被打、不会被自己的 AOE 打到 ——
#   `#sweetdream:no_damage` 本来就排掉 marker, 所以不需要额外的排除标签。
# 【★ 表现必须每刻铺 ★】隐形实体挂每秒 = 20 帧 1 帧 = 看不见(坑 147:
#   计时按秒、表现按刻) —— 粒子由 core/tick 每刻画(见 everlit/wisp_fx)。
# 【真伤】伤害类型 sweetdream:true_damage(本包已注册, 无需退世界重进)。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch*.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"长明",bold:true,color:yellow},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，在自身位置召唤一只“灯灵","color":"gray","italic":false},{"text":"”（同时只能存在一只）。“灯灵”每 2","color":"gray","italic":false},{"text":"秒对自身 6 格内最近的一个生物造成一次","color":"gray","italic":false},{"text":"相当于自身当前魔力值 ×0.02 的真实伤害。","color":"gray","italic":false},{"text":"自身魔力值低于 200 时“灯灵”熄灭，不","color":"gray","italic":false},{"text":"再造成伤害。","color":"gray","italic":false}],custom_data={zx:["everlit","tool"],tags:["summon","true_dmg","cur_mana"]}]
