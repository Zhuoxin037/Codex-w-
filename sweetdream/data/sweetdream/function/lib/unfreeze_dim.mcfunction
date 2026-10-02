# 在当前维度里收所有到点的冷冻/时停(由 unfreeze_sweep 逐维度调用)

# ① 冷冻到点 -> 解冻
execute as @e[tag=zx.freeze] if score @s zx.fz_end <= #now manacore.meta run function sweetdream:lib/unfreeze_one

# ② 时停到点 -> 先标出来, 让应用层接一下, 再真正解除
#    【为什么要多"标一下"这一步】zx.stop 一摘掉就再也分不出"刚结束的"和
#      "压根没被时停的"。应用层(幻昼)要的就是"时停结束那一刻"这个瞬间事件。
#    【★ 为什么不能靠每秒轮询自己检测 ★】异彩/幻昼的时停只有 **1 秒 = 20 tick**,
#      和 unfreeze_sweep 的周期(20 tick)一样长 —— 用"上一秒有标记、这一秒没了"
#      这种边沿检测会**锁相**, 命中率全看相位(和焚舟点火那个坑完全一样)。
#      所以必须在"解除的那一刻"就地广播, 由事件标签 #sweetdream:event/timestop_end
#      把这一瞬间接出去。默认挂 sweetdream:event/noop, 没人接就是空转。
#    【标签为什么用完就清】zx.ts_done 只在本次扫描内有效; 留着的话下一次扫描
#      会把"上次结束的"再处理一遍。
tag @e[tag=zx.ts_done] remove zx.ts_done
execute as @e[tag=zx.stop] if score @s zx.ts_end <= #now manacore.meta run tag @s add zx.ts_done
#    【兜底】带了 zx.stop 却没有 zx.ts_end 的(计时被外力清掉、或在旧版本里
#      被写坏过): 上面的 `<=` 比较会因为分数不存在而失败, 它就永远解不开,
#      NoAI 也就永远挂着。"分数不存在"的判断写法是"自己不等于自己"。
execute as @e[tag=zx.stop] unless score @s zx.ts_end = @s zx.ts_end run tag @s add zx.ts_done
execute if entity @e[tag=zx.ts_done,limit=1] run function #sweetdream:event/timestop_end
execute as @e[tag=zx.ts_done] run function sweetdream:lib/timestop_one
tag @e[tag=zx.ts_done] remove zx.ts_done
