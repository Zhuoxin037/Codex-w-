$execute unless data storage zx:jobs p."$(uuid)" run data modify storage zx:jobs p."$(uuid)" set value {body:{},twin:{hp:5.0,mana:130.0}}
$data modify storage zx:jobs p."$(uuid)".u0 set value $(u0)
$data modify storage zx:jobs p."$(uuid)".u1 set value $(u1)
$data modify storage zx:jobs p."$(uuid)".u2 set value $(u2)
$data modify storage zx:jobs p."$(uuid)".u3 set value $(u3)
$data modify storage zx:work jt_record set from storage zx:jobs p."$(uuid)"
