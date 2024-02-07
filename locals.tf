locals {
    # Decode CSV data for ACI fabric node members from a file
    aci_fabric_node_member_iterations = csvdecode(file("./data/aci_fabric_node_member.csv"))
    
    # Transform the list of ACI fabric node member data into a map for easier access
    # Each device serial number maps to its respective details
    aci_fabric_node_member_rows = {
        for i in local.aci_fabric_node_member_iterations : 
        i.SERIAL_NUMBER => {
        NODE_ROLE       = i.NODE_ROLE
        POD_ID          = i.POD_ID
        NODE_ID         = i.NODE_ID  
        SERIAL_NUMBER   = i.SERIAL_NUMBER
        NODE_NAME       = i.NODE_NAME
        }
    }
  
    aci_leaf_interface_profile_iterations = csvdecode(file("./data/aci_leaf_interface_profile.csv"))

    aci_leaf_interface_profile_rows = {
        for i in local.aci_fabric_node_member_iterations : 
        i.NODE_ID  => {
            NODE_ID         = i.NODE_ID  
        }
    }

    aci_leaf_profile_iterations = csvdecode(file("./data/aci_leaf_profile.csv"))

    aci_leaf_profile_rows = {
        for i in local.aci_leaf_profile_iterations : 
        i.NODE_ID  => {
            NODE_ID         = i.NODE_ID  
        }
    }

    aci_access_switch_policy_group_iterations = csvdecode(file("./data/aci_access_switch_policy_group.csv"))

    aci_access_switch_policy_group_rows = {
        for i in local.aci_access_switch_policy_group_iterations : 
        i.NODE_ID => {
            NODE_ID                                 = i.NODE_ID
            BFD_IPV4_INST_POL                       = i.BFD_IPV4_INST_POL
            BFD_IPV6_INST_POL                       = i.BFD_IPV6_INST_POL
            BFD_MH_IPV4_INST_POL                    = i.BFD_MH_IPV4_INST_POL
            BFD_MH_IPV6_INST_POL                    = i.BFD_MH_IPV6_INST_POL
            EQUIPMENT_FLASH_CONFIG_POL              = i.EQUIPMENT_FLASH_CONFIG_POL
            FC_FABRIC_POL                           = i.FC_FABRIC_POL
            FC_INST_POL                             = i.FC_INST_POL
            IACL_LEAF_PROFILE                       = i.IACL_LEAF_PROFILE
            L2_NODE_AUTH_POL                        = i.L2_NODE_AUTH_POL
            LEAF_COPP_PROFILE                       = i.LEAF_COPP_PROFILE
            LEAF_P_GRP_TO_CDP_IF_POL                = i.LEAF_P_GRP_TO_CDP_IF_POL
            LEAF_P_GRP_TO_LLDP_IF_POL               = i.LEAF_P_GRP_TO_LLDP_IF_POL
            MON_NODE_INFRA_POL                      = i.MON_NODE_INFRA_POL
            MST_INST_POL                            = i.MST_INST_POL
            POE_INST_POL                            = i.POE_INST_POL
            TOPOCTRL_FAST_LINK_FAILOVER_INST_POL    = i.TOPOCTRL_FAST_LINK_FAILOVER_INST_POL
            TOPOCTRL_FWD_SCALE_PROF_POL             = i.TOPOCTRL_FWD_SCALE_PROF_POL
        }
    }

    aci_rest_leaf_profile_policy_attachment_iterations = csvdecode(file("./data/aci_rest_leaf_profile_policy_attachment.csv"))

    aci_rest_leaf_profile_policy_attachment_rows = {
        for i in local.aci_rest_leaf_profile_policy_attachment_iterations : 
        "${i.NODE_ID}:${i.ACI_LEAF_PROFILE_KEY}:${i.ACI_ACCESS_SWITCH_POLICY_GROUP_KEY}"  => {
            NODE_ID                             = i.NODE_ID
            ACI_LEAF_PROFILE_KEY                = i.ACI_LEAF_PROFILE_KEY  
            ACI_ACCESS_SWITCH_POLICY_GROUP_KEY  = i.ACI_ACCESS_SWITCH_POLICY_GROUP_KEY
        }
    }

    aci_vpc_domain_policy_iterations = csvdecode(file("./data/aci_vpc_domain_policy.csv"))

    aci_vpc_domain_policy_rows = {
        for i in local.aci_vpc_domain_policy_iterations : 
        "${i.ODD_NODE_ID}:${i.EVEN_NODE_ID}"  => {
            ODD_NODE_ID             = i.ODD_NODE_ID
            EVEN_NODE_ID            = i.EVEN_NODE_ID 
            DEAD_INTERVAL_SECONDS   = i.DEAD_INTERVAL_SECONDS
        }
    }

    aci_vpc_explicit_protection_group_iterations = csvdecode(file("./data/aci_vpc_explicit_protection_group.csv"))

    aci_vpc_explicit_protection_group_rows = {
        for i in local.aci_vpc_explicit_protection_group_iterations : 
        "${i.ODD_NODE_ID}:${i.EVEN_NODE_ID}"  => {
            ODD_NODE_ID                 = i.ODD_NODE_ID
            EVEN_NODE_ID                = i.EVEN_NODE_ID 
            GROUP_ID                    = i.GROUP_ID
            ACI_VPC_DOMAIN_POLICY_KEY   = i.ACI_VPC_DOMAIN_POLICY_KEY
        }
    }

    aci_static_node_mgmt_address_iterations = csvdecode(file("./data/aci_static_node_mgmt_address.csv"))

    aci_static_node_mgmt_address_rows = {
        for i in local.aci_static_node_mgmt_address_iterations : 
        i.NODE_ID  => {
            POD_ID          = i.POD_ID
            NODE_ID         = i.NODE_ID
            SERIAL_NUMBER   = 1.SERIAL_NUMBER
            NETWORK_IP      = i.NETWORK_IP
            NETWORK_CIDR    = i.NETWORK_CIDR
            NETWORK_GATEWAY = i.NETWORK_GATEWAY   
        }
    }

    aci_filter_entry_iterations = csvdecode(file("./data/aci_filter_entry.csv"))

    aci_filter_entry_rows = {
        for i in local.aci_static_node_mgmt_address_iterations : 
        "${i.ENVIRONMENT}:${i.TENANT}:${i.ZONE}:${i.ETHER_TYPE}:${i.PROTOCOL}:${i.PORT}"  => {
             ENVIRONMENT    = i.ENVRIONMENT
             TENANT         = i.TENANT
             ZONE           = i.ZONE
             ETHER_TYPE     = i.ETHER_TYPE
             PROTOCOL       = i.PROTOCOL
             PORT           = i.PORT
             APPLICATION    = i.APPLICATION  
        }
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltArpIterations ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.ETHER_TYPE) == "arp"      
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolTcpIteration ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.ETHER_TYPE) == "tcp"      
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolUdpIteration ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.ETHER_TYPE) == "udp"      
    }

}
