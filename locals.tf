
    locals{
        aci_fabric_node_member_iterations = csvdecode(file("./data/aci_fabric_node_member.csv"))
        
        aci_fabric_node_member_rows = {
            for i in local.aci_fabric_node_member_iterations : i.NODE_ID => {
                FABRIC_NAME     = i.FABRIC_NAME
                NODE_ROLE       = i.NODE_ROLE
                POD_ID          = i.POD_ID
                NODE_ID         = i.NODE_ID  
                NODE_PEER_ID    = i.NODE_PEER_ID
                SERIAL_NUMBER   = i.SERIAL_NUMBER
                NODE_NAME       = i.NODE_NAME
            }
        }
        
        filtered_node_role_leaf_rows = {
            for key, value in local.aci_fabric_node_member_rows : key => value
            if value.NODE_ROLE == "leaf"
        }
        
        aci_vpc_explicit_protection_group_iterations = csvdecode(file("./data/aci_vpc_explicit_protection_group.csv")) 
        
        aci_vpc_explicit_protection_group_rows = {
            for i in local.aci_vpc_explicit_protection_group_iterations : ${i.ODD_NODE_ID}:${i.EVEN_NODE_ID} => {
                FABRIC_NAME     = i.FABRIC_NAME
                ODD_NODE_ID     = i.ODD_NODE_ID  
                EVEN_NODE_ID    = i.EVEN_NODE_ID 
                GROUP_ID        = i.GROUP_ID
            }
        }        
    }
    