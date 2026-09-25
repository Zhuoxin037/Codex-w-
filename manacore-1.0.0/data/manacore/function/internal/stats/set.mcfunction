# ------------------------------------------------------------
# internal/stats/set —— 通用属性写入
# 【宏参数】manacore:work.a {uuid,key,value}
# 【原理】set from 而不是 set value $(value):
#         这样能保留任意类型(字符串/列表/复合), 不会因为宏渲染把类型改掉。
# 【守卫】1) work.a.value 必须存在(接口层已经塞了默认值)
#         2) players."uuid".stats 必须存在(接口层调用了 api/player/ensure)
#         两个条件都满足才写入, 避免命令失败导致函数中断。
# 【可以新建属性】data modify 会自动创建缺失的中间路径, 所以
#         set uuid key="new_stat" 会直接在 stats 里加一个字段。
# ------------------------------------------------------------
$execute if data storage manacore:work a.value if data storage manacore:players "$(uuid)".stats run data modify storage manacore:players "$(uuid)".stats."$(key)" set from storage manacore:work a.value
