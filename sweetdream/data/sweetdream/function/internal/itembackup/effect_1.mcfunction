# ============================================================
# sweetdream:internal/itembackup/effect_1 —— 消耗触发: 快照 -> 入队 -> 预约回手
# ------------------------------------------------------------
# 【触发】进度 sweetdream:itembackup/consume(consume_item) 的 rewards
# 【流程】撤进度 -> 取自己的 UUID -> 判定哪只手/哪一格 -> 快照到暂存区 -> 入队
#   -> 打标签 -> 延迟 1 tick 回手
#   (O03 后快照进 zx:ret 存储暂存区, 见 backup.mcfunction; 老的每刻 tick 备份线已删,
#    每秒安全网挂 lib/second)
# ------------------------------------------------------------
# 【为什么必须延迟】consume_item 的奖励是在"消耗还没走完"的时候触发的。
#   等奖励函数跑完, 游戏还会把那个槽位设成消耗后的结果(空), 会把我们刚放回去的
#   剑覆盖掉 —— 现象就是"剑直接消失"。
#   所以这里只负责"记账 + 预约", 真正回手交给下一 tick。
# 【为什么不能在这里直接调宏函数回手】就是上面那条: 太早了, 会被覆盖掉。
# ------------------------------------------------------------
# 【★ 为什么要记录"用的哪只手" ★】
#   item replace 是覆盖式的: 写哪个槽位, 那个槽位原来的东西就**直接没了**。
#   老版本无条件写回 weapon.mainhand, 于是"武器放副手右键"会连着出两件事:
#       副手那把没备份过     -> 消耗后没人还它        -> 武器消失
#       架子里的旧备份被塞进主手 -> 主手的装备被顶掉 -> 又消失一件
#   现在趁"消耗还没走完、物品还在手上"这一刻判定槽位, 记进队列条目的 slot,
#   下一 tick 由 effect_2 按它决定写回哪只手 / 哪一格。
# 【怎么判】原版的使用顺序是"主手物品可用就先用主手", 所以先看主手:
#       主手是 itemreplace                 -> 主手触发(不打标签)
#       主手不是、副手是 itemreplace       -> 副手触发(打 zx.ret_off)
#   ★ tag zx.ret_off 只是**本 tick 内**的快判(包里 9 处拿它做门控, 语义不动);
#     跨 tick 的判断一律读**队列**(tag 会随实体消失, 队列不会)。
# ------------------------------------------------------------
# 【★★ A02(2026-10-11 三审): 待归还从"玩家级单标量"改成"队列" ★★】
#   旧版把待归还记成 zx.ret_slot / zx.ret_pend 两个**玩家级单标量** + 一份快照
#   (p.<uuid>.mainhand/.offhand)。两个后果:
#     ① 第一件还没还回去, 30 tick 内又消耗第二件 => 同一份待办被**顶掉**(第一件回不来);
#     ② 20 秒倒计时归零就**放弃**(主背包还有空格也不找了)。
#   现在: 每次消耗都把"那件武器 + 首选槽位"追加进 **队列** zx:ret p."<uuid>".q;
#   回手只动**队首**, 落地(或队首没东西可还)才出队 —— 队列不空就一直重试,
#   **永不放弃**。见 enqueue / effect_2 / recover。
# ============================================================

advancement revoke @s only sweetdream:itembackup/consume

# ★★ 创造模式: 直接跳过整套"备份 + 入队 + 回手"(2026-10-11 用户实测: 会凭空多一把)
#   同一个 consumable, 两种模式的结果**不一样**:
#     · 生存 / 冒险 —— 使用走完后原版会把那一格设成消耗结果(空), 武器真的没了,
#       所以必须靠本流程在下一 tick 补回来(这就是为什么这套系统存在)。
#     · 创造模式   —— 原版**根本不消耗**物品, 手上那把好好的还在(槽位非空)。
#   而 effect_2 的回手是"首选槽位 -> 放不下就依次找任意一个空格塞进去"(
#   weapon.offhand / hotbar.N / hotbar.0..8 / inventory.0..26 共 39 个候选)。
#   创造的模式下首选槽位本来就被占着 => 守卫 `unless items ... *` 恒不通过
#   => 一路兜底下去, 把另一把同样的武器塞进背包某个空格 —— 就是那个"多出来的物品"。
#   ⇒ 创造模式下物品压根没丢, 什么都不用做, 直接返回。
#   ⚠️ revoke 必须写在 return **之前**: 否则进度一直停在"已完成",
#      之后切回生存模式就再也不触发了。
execute if entity @s[gamemode=creative] run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 判定哪只手: 默认当主手, 只有"主手不是、副手是 itemreplace"时才记为副手
tag @s remove zx.ret_off
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tag @s add zx.ret_off

# ② 立刻快照一次 —— 此刻消耗还没走完、东西还在手上, 是【最准】的备份时机。
#    快照落暂存区 zx:ret p."<uuid>".stage.mainhand/.offhand(见 backup/snap_main);
#    lib/second 的每秒快照是兜底, 这里的这一份保证"刚换到副手就右键"也拍得到。
data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/backup with storage zx:work a

# ③ 组 enqueue 的宏参数: src = 取哪份暂存快照 / slot = 消耗时那一格(副手记 -1)
#    ★ 字段名是 Selected**Item**Slot, 不是 SelectedSlot ★★
#      2026-10-10 事故: 第一版写成 `data get entity @s SelectedSlot` —— 该字段不存在,
#      data get 抛错 ⇒ **本函数从这一行起中断** ⇒ 备份没做、schedule 没排
#      ⇒ 武器被消耗后再也没人还(玩家反馈"消耗型武器右键没有正常回手")。
#      先例: equipment/sword/sickle_dreams/sweep/start 第 14 行。
#      这类"字段名写错"在**非宏行**里是运行时错误、不进 latest.log, 只能靠先例/守门。
#      守门: check.py 的 `selfield` 规则(拦裸 `SelectedSlot`)。
data modify storage zx:work a.uuid set from storage zx:data self.uuid
data modify storage zx:work a.src set value "mainhand"
execute if entity @s[tag=zx.ret_off] run data modify storage zx:work a.src set value "offhand"
data modify storage zx:work a.slot set value -1
execute unless entity @s[tag=zx.ret_off] store result storage zx:work a.slot int 1 run data get entity @s SelectedItemSlot

# ④ 入队 —— 队首槽位镜像(zx.ret_slot) / 置"有待归还"(zx.ret_pend=1) /
#    清零超时计时(zx.ret_wait=0) 全在 enqueue 里做(它还负责"队空才建队列")。
function sweetdream:internal/itembackup/enqueue with storage zx:work a

# ⑤ 打标签(下一 tick 靠它把玩家找回来) + 预约回手
tag @s add test_pending_return
schedule function sweetdream:internal/itembackup/return 1t

# 【技能不在这里放】本函数只管"把刀弄回来", 一个技能都不放。
#   技能由每把武器自己的进度触发: advancement/equipment/<武器>.json,
#   条件是物品 custom_data.zx 里带上武器自己的标记, 奖励指向它自己的 cast。
#   —— 这样加新武器不用改这里。
# 【为什么把回手和技能分成两件事】回手是"消耗型物品的通用机制", 技能是"武器
#   自己的行为"。分开之后: 冷却中右键 = 刀回来了、技能没放、聊天栏提示还剩多久;
#   某个武器的 cast 写坏了也不会连带把回手机制弄坏。
