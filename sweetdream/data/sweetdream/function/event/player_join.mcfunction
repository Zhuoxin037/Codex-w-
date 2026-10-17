# ============================================================
# sweetdream:event/player_join —— 玩家上线 / 重注册时的应用层收尾
# ------------------------------------------------------------
# 【谁抛它】manacore:internal/join/register 的**最后一行**
#   (`function #manacore:event/player_join`); 应用侧的挂载点 =
#   sweetdream/data/manacore/tags/function/event/player_join.json。
#   注意 register **每次上线/重注册都会跑**(不是只在首次), 所以这里的东西必须**幂等**。
# 【执行者】玩家本人(@s)。
# 【与 player_first_join 的分工】
#   · player_join      : 每次注册都抛 —— 适合"每次上线都对一遍"的**迁移/补齐**;
#   · player_first_join: 只在 join/new 那条路抛(新玩家 / reset 后首次上线) —— 适合清账。
#     两者顺序: register(player_join) 先, 后抛 player_first_join ⇒ **迁移早于清账**。
#     (这点很要紧: 清账清单会 reset zx.ret_pend, 那是迁移的唯一判据 —— 见 migrate_legacy)
# ------------------------------------------------------------
# 【★ 本文件必须是不含宏行的普通函数 ★】
#   它被 tags/function 直接引用; 被标签直接引用的函数一旦含 `$(...)`, 整段在**解析期**
#   就失效且零日志(禁例见 RULES 的 tagmacro 桶 / N09 海棠事故)。
#   需要宏参数的动作一律转发给宏叶子 —— 这里就是 migrate_legacy。
# ============================================================

# ---- Q01(2026-10-11 四审): 旧版待归还快照 -> 新队列(幂等; 详见 migrate_legacy 头部) ----
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
# migrate_legacy 的第二个宏参数 $(slot): **主手那笔**要还回哪一格。
#   与 return_go / recover_go 同款钳法 —— $(slot) 是**文本替换**, 副手(-1)/非法值时
#   若不钳会拼出非法的 `hotbar.-1`(那几行会被 execute 条件拦住, 但让文本永远合法更省心)。
data modify storage zx:work a.slot set value 0
execute if score @s zx.ret_slot matches 0..8 store result storage zx:work a.slot int 1 run scoreboard players get @s zx.ret_slot

function sweetdream:internal/itembackup/migrate_legacy with storage zx:work a

# 取消上一会话的短时武器动作。
execute if entity @s[tag=zx.fb_cast] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/end
function sweetdream:equipment/axe/anchor/cancel

# 清理上一会话的五世恶咒视觉，原技能状态不变。
execute if entity @s[tag=zx.fcvv_on] at @s run function sweetdream:equipment/staff/five_curses/visual/end
