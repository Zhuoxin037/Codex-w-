function sweetdream:lib/uuid
data modify storage zx:work jp_enqueue.uuid set from storage zx:data self.uuid
$data modify storage zx:work jp_enqueue.no_self set value $(no_self)
function sweetdream:profession/mage/pain_enqueue_go with storage zx:work jp_enqueue
