
    # https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/fabric_node_member
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_fabric_node_member" "localAciFabricNodeMemberIteration" {
      for_each = local.aci_fabric_node_member_rows
    
      name        = each.value.NODE_NAME          
      serial      = each.value.SERIAL_NUMBER 
      annotation  = "orchestrator:terraform"
      description = "${each.value.NODE_NAME}-${each.value.SERIAL_NUMBER} registered to node-id-${each.value.SWITCH_NODE_ID}"          
      ext_pool_id = "0"
      fabric_id   = "1"
      node_id     = each.value.NODE_ID       
      node_type   = "unspecified"
      pod_id      = each.value.POD_ID 
      role        = each.value.NODE_ROLE   
    }
    
    #
    #
    