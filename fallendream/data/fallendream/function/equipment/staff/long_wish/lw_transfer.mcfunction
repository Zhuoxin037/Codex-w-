# 把刚被消耗的标签附着到选中的目标(同一标签本次消耗只转移一次)。
# zx.lw_dest 由 on_consume 选好; mark 从 mc 读, 不靠宏参数, 避免重复展开。
data modify storage zx:work ic set value {target:"@e[tag=zx.lw_dest,limit=1]",mark:""}
data modify storage zx:work ic.mark set from storage zx:work mc.mark
function fallendream:tag/mark with storage zx:work ic
