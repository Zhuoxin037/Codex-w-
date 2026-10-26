$execute if data storage zx:jobs p."$(uuid)".guard."$(key)" run data modify entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand set from storage zx:jobs p."$(uuid)".guard."$(key)"
