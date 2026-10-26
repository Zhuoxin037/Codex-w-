$execute if data storage zx:jobs p."$(uuid)".body.force run data modify storage zx:work jfchunk set from storage zx:jobs p."$(uuid)".body.force
$execute if data storage zx:jobs p."$(uuid)".body.force run function sweetdream:profession/twin/chunk_release with storage zx:work jfchunk
