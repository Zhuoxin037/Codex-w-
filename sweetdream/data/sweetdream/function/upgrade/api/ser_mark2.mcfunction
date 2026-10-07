# ============================================================
# sweetdream:upgrade/api/ser_mark2 —— 取一条升级的系列名, 交给 ser_keep 决定去留
# ------------------------------------------------------------
# 【宏参数】zx:work fs {id} = 旧 up 列表里的一条石头 id
# 【与 ser_mark 的区别】ser_mark 是"记进 seen 键集"(fit 判槽位用);
#   这里是"按 seen 决定这条要不要保留"(up_rebuild 重建列表用) —— 动作不同,
#   查系列名那一步一模一样, 但宏不能套娃, 只好各拆一层。
# 【调用方】upgrade/api/up_rebuild(同系替换时重建 up 列表)
# ============================================================

$data modify storage zx:work fs.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/ser_keep with storage zx:work fs
