
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
    }
    