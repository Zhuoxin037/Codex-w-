$data modify storage zx:jobs p."$(owner)".body.hp set value $(hp)
$data modify storage zx:jobs p."$(owner)".pending_return set value 1b
$execute if data storage zx:jobs p."$(owner)".body.force run data modify storage zx:work jfchunk set from storage zx:jobs p."$(owner)".body.force
$execute if data storage zx:jobs p."$(owner)".body.force run function sweetdream:profession/twin/chunk_release with storage zx:work jfchunk
