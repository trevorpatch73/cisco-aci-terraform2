locals {
    ###################################
    #####  MULTI-WORKFLOW INPUTS ######
    ###################################

    aci_filter_entry_iterations = csvdecode(file("./data/aci_filter_entry.csv"))

    aci_filter_entry_rows = {
        for i in local.aci_filter_entry_iterations : 
        "${i.ENVIRONMENT}:${i.TENANT}:${i.ZONE}:${i.APPLICATION}:${i.DIRECTION}:${i.ETHER_TYPE}:${i.PROTOCOL}:${i.PORT}"  => {
             ENVIRONMENT    = i.ENVIRONMENT
             TENANT         = i.TENANT
             ZONE           = i.ZONE
             APPLICATION    = i.APPLICATION
             DIRECTION      = i.DIRECTION
             ETHER_TYPE     = i.ETHER_TYPE
             PROTOCOL       = i.PROTOCOL
             PORT           = i.PORT
        }
    }

    aci_vlan_pool_iterations = csvdecode(file("./data/aci_vlan_pool.csv"))

    aci_vlan_pool_rows = {
        for i in local.aci_vlan_pool_iterations : 
        "${i.TENANT_NAME}:${i.POOL_DOMAIN}" => {
             TENANT_NAME     = i.TENANT_NAME
             POOL_DOMAIN     = i.POOL_DOMAIN
             ALLOCATION_MODE = i.ALLOCATION_MODE
        }
    }    

    aci_ranges_iterations = csvdecode(file("./data/aci_ranges.csv"))

    aci_ranges_rows = {
        for i in local.aci_ranges_iterations : 
        i.VLAN_ID => {
             TENANT_NAME     = i.TENANT_NAME
             POOL_DOMAIN     = i.POOL_DOMAIN          
             VLAN_ID         = i.VLAN_ID
             ALLOCATION_MODE = i.ALLOCATION_MODE
             ROLE            = i.ROLE
        }
    }  

    #######################################
    #####  FABRIC INVENTORY WORKFLOW ######
    #######################################

    aci_fabric_node_member_iterations = csvdecode(file("./data/aci_fabric_node_member.csv"))
    
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
        for i in local.aci_leaf_interface_profile_iterations : 
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
            SERIAL_NUMBER   = i.SERIAL_NUMBER
            NETWORK_IP      = i.NETWORK_IP
            NETWORK_CIDR    = i.NETWORK_CIDR
            NETWORK_GATEWAY = i.NETWORK_GATEWAY   
        }
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltArpIterations ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.APPLICATION) == "oob" && lower(value.ETHER_TYPE) == "arp"      
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolTcpIteration ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.APPLICATION) == "oob" && lower(value.ETHER_TYPE) == "tcp"      
    }

    FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolUdpIteration ={
        for key, value in local.aci_filter_entry_rows : key => value
        if lower(value.TENANT) == "infra" && lower(value.ZONE) == "aci-mgmt" && lower(value.APPLICATION) == "oob" && lower(value.ETHER_TYPE) == "udp"      
    }

    aci_fabric_node_software_staging_iterations = csvdecode(file("./data/aci_fabric_node_software_staging.csv"))

    aci_fabric_node_software_staging_rows = {
        for i in local.aci_fabric_node_software_staging_iterations : 
        i.NODE_ID  => {
            POD_ID          = i.POD_ID 
            NODE_ID         = i.NODE_ID
            TARGET_VERSION  = i.TARGET_VERSION  
        }
    }

    aci_maintenance_group_schedule_policy_iterations = csvdecode(file("./data/aci_maintenance_group_schedule_policy.csv"))

    aci_maintenance_group_schedule_policy_rows = {
        for i in local.aci_maintenance_group_schedule_policy_iterations : 
        i.MAINTENANCE_GROUP_NAME => {
            MAINTENANCE_GROUP_NAME       = i.MAINTENANCE_GROUP_NAME
            TRIGGER_INDEX                = i.TRIGGER_INDEX
        }
    }

    aci_maintenance_group_policy_iterations = csvdecode(file("./data/aci_maintenance_group_policy.csv"))

    aci_maintenance_group_policy_rows = {
        for i in local.aci_maintenance_group_policy_iterations : 
        i.MAINTENANCE_GROUP_NAME => {
            MAINTENANCE_GROUP_NAME  = i.MAINTENANCE_GROUP_NAME
            OS_VERSION              = i.OS_VERSION
            ADMIN_STATE             = i.ADMIN_STATE 
            GRACEFUL                = i.GRACEFUL 
            IGNORE_COMPATABILITY    = i.IGNORE_COMPATABILITY
            NOTIFICATIONS           = i.NOTIFICATIONS
            RUN_MODE                = i.RUN_MODE
            OVERRIDE_STATE          = i.OVERRIDE_STATE
        }
    }

    aci_maintenance_group_iterations = csvdecode(file("./data/aci_maintenance_group.csv"))

    aci_maintenance_group_rows = {
        for i in local.aci_maintenance_group_iterations : 
        i.MAINTENANCE_GROUP_NAME => {
            MAINTENANCE_GROUP_NAME       = i.MAINTENANCE_GROUP_NAME
        }
    }

    aci_maintenance_group_node_iterations = csvdecode(file("./data/aci_maintenance_group_node.csv"))

    aci_maintenance_group_node_rows = {
        for i in local.aci_maintenance_group_node_iterations: 
        i.NODE_ID => {
            NODE_ID                      = i.NODE_ID
            MAINTENANCE_GROUP_NAME       = i.MAINTENANCE_GROUP_NAME
        }
    }

    ###########################################
    #####  TENANT CONFIGURATION WORKFLOW ######
    ###########################################

    aci_tenant_iterations = csvdecode(file("./data/aci_tenant.csv"))

    aci_tenant_rows = {
        for i in local.aci_tenant_iterations: 
        i.TENANT_NAME => {
            TENANT_NAME                  = i.TENANT_NAME
        }
    }

    aci_application_profile_iterations = csvdecode(file("./data/aci_application_profile.csv"))

    aci_application_profile_rows = {
        for i in local.aci_application_profile_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}" => {
            TENANT_NAME                  = i.TENANT_NAME
            ZONE_NAME                    = i.ZONE_NAME
        }
    }

    aci_vrf_iterations = csvdecode(file("./data/aci_vrf.csv"))

    aci_vrf_rows = {
        for i in local.aci_vrf_iterations: 
        "${i.TENANT_NAME}:${i.VRF_NAME}" => {
            TENANT_NAME                    = i.TENANT_NAME
            ZONE_NAME                      = i.ZONE_NAME
            VRF_NAME                       = i.VRF_NAME
            BD_ENF                         = i.BD_ENF
            IP_DATA_PLANE_LRN              = i.IP_DATA_PLANE_LRN
            KNWN_MCAST_FWD                 = i.KNWN_MCAST_FWD 
            POL_ENF_DIR                    = i.POL_ENF_DIR
            POL_ENF_PREF                   = i.POL_ENF_PREF
        }
    }

    aci_bridge_domain_iterations = csvdecode(file("./data/aci_bridge_domain.csv"))

    aci_bridge_domain_rows = {
        for i in local.aci_bridge_domain_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.APPLICATION_NAME}" => {
            TENANT_NAME             = i.TENANT_NAME  
            ZONE_NAME               = i.ZONE_NAME  
            VRF_NAME                = i.VRF_NAME 
            APPLICATION_NAME        = i.APPLICATION_NAME
            VLAN_ID                 = i.VLAN_ID  
            BD_TYPE                 = i.BD_TYPE 
            UNICAST_ROUTE           = i.UNICAST_ROUTE   
            UNK_MAC_UCAST_ACT       = i.UNK_MAC_UCAST_ACT
            BD_MAC                  = i.BD_MAC 
            OPTMZE_WAN_BW           = i.OPTMZE_WAN_BW
            ARP_FLOOD               = i.ARP_FLOOD  
            EP_CLEAR                = i.EP_CLEAR 
            EP_MV_DETECT_MODE       = i.EP_MV_DETECT_MODE 
            IP_LRN                  = i.IP_LRN  
            LIMIT_IP_LRN_SNET       = i.LIMIT_IP_LRN_SNET
            IPV4_MCAST_ALLOW        = i.IPV4_MCAST_ALLOW
            MCAST_PKT_ACT           = i.MCAST_PKT_ACT  
            IPV6_MCAST_ALLOW        = i.IPV6_MCAST_ALLOW 
            IPV6_LL_ADDR            = i.IPV6_LL_ADDR
            V6_UNK_MCAST_ACT        = i.V6_UNK_MCAST_ACT
        }
    }

    aci_subnet_iterations = csvdecode(file("./data/aci_subnet.csv"))

    aci_subnet_rows = {
        for i in local.aci_subnet_iterations: 
        i.NETWORK_PREFIX => {
            TENANT_NAME         = i.TENANT_NAME 
            ZONE_NAME           = i.ZONE_NAME    
            APPLICATION_NAME    = i.APPLICATION_NAME  
            NETWORK_PREFIX      = i.NETWORK_PREFIX
            NETWORK_CIDR        = i.NETWORK_CIDR 
            NETWORK_GW          = i.NETWORK_GW 
            ANYCAST_MAC         = i.ANYCAST_MAC 
            PREFERRED           = i.PREFERRED
            SCOPE               = i.SCOPE 
            CONTROL_STATE       = i.CONTROL_STATE
            IP_DATA_PLANE_LRN   = i.IP_DATA_PLANE_LRN
        }
    }

    aci_application_epg_iterations = csvdecode(file("./data/aci_application_epg.csv"))

    aci_application_epg_rows = {
        for i in local.aci_application_epg_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.APPLICATION_NAME}" => {
            TENANT_NAME             = i.TENANT_NAME  
            ZONE_NAME               = i.ZONE_NAME  
            APPLICATION_NAME        = i.APPLICATION_NAME
            VLAN_ID                 = i.VLAN_ID  
            SHUTDOWN                = i.SHUTDOWN
            FLOOD_ON_ENCAP          = i.FLOOD_ON_ENCAP 
            FWD_CTRL                = i.FWD_CTRL
            HAS_MCAST_SRC           = i.HAS_MCAST_SRC
            IS_ATTR_BASED           = i.IS_ATTR_BASED
            MATCH_T                 = i.MATCH_T
            PC_ENF_PREF             = i.PC_ENF_PREF 
            PREF_GR_MEMB            = i.PREF_GR_MEMB
            PRIO                    = i.PRIO 
        }
    }

    aci_contract_iterations = csvdecode(file("./data/aci_contract.csv"))

    aci_contract_rows = {
        for i in local.aci_contract_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.APPLICATION_NAME}" => {
            TENANT_NAME             = i.TENANT_NAME  
            ZONE_NAME               = i.ZONE_NAME  
            APPLICATION_NAME        = i.APPLICATION_NAME
            VLAN_ID                 = i.VLAN_ID  
            PRIO                    = i.PRIO
            SCOPE                   = i.SCOPE 
            TARGET_DSCP             = i.TARGET_DSCP 
        }
    }

    aci_contract_subject_iterations = csvdecode(file("./data/aci_contract_subject.csv"))

    aci_contract_subject_rows = {
        for i in local.aci_contract_subject_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.APPLICATION_NAME}" => {
            TENANT_NAME             = i.TENANT_NAME  
            ZONE_NAME               = i.ZONE_NAME  
            APPLICATION_NAME        = i.APPLICATION_NAME
            VLAN_ID                 = i.VLAN_ID  
            PRIO                    = i.PRIO
            TARGET_DSCP             = i.TARGET_DSCP
            REV_FLT_PORTS           = i.REV_FLT_PORTS 
            PROV_MATCH_T            = i.PROV_MATCH_T
            CONS_MATCH_T            = i.CONS_MATCH_T
        }
    }

    aci_contract_subject_filter_iterations = csvdecode(file("./data/aci_contract_subject_filter.csv"))

    aci_contract_subject_filter_rows = {
        for i in local.aci_contract_subject_filter_iterations: 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.APPLICATION_NAME}:${i.DIRECTION}:${i.FILTERS}" => {
            TENANT_NAME             = i.TENANT_NAME  
            ZONE_NAME               = i.ZONE_NAME  
            APPLICATION_NAME        = i.APPLICATION_NAME
            ACTION                  = i.ACTION
            DIRECTIVES              = i.DIRECTIVES
            PRIORITY_OVERRIDE       = i.PRIORITY_OVERRIDE
            DIRECTION               = i.DIRECTION
            FILTERS                 = i.FILTERS
        }
    }

    FilterlocalAciContractSubjectFilterIterationEpgInbound ={
        for key, value in local.aci_contract_subject_filter_rows : key => value
        if lower(value.DIRECTION) == "inbound" || lower(value.DIRECTION) == "both"     
    }

    FilterlocalAciContractSubjectFilterIterationEpgOutbound ={
        for key, value in local.aci_contract_subject_filter_rows : key => value
        if lower(value.DIRECTION) == "outbound" || lower(value.DIRECTION) == "both"     
    }

    ### resource "aci_filter" "localAciFiltersIteration" for application tenants ###
    # Create a concatenated string for each row with only the required fields
    aci_filter_combinations = [
        for entry in local.aci_filter_entry_iterations : 
        "${entry.TENANT}:${entry.ETHER_TYPE}:${entry.PROTOCOL}:${entry.PORT}"
    ]

    # Use the distinct function to ensure the list only contains unique combinations
    unique_aci_filter_combinations = distinct(local.aci_filter_combinations) 

    # Place the unique combinationsinto a map for resource "aci_filter" "localAciFiltersIteration"
    aci_filter_map = { 
        for item in local.unique_aci_filter_combinations : item => {
            TENANT_NAME      = split(":", item)[0]
            ETHER_TYPE       = split(":", item)[1]
            PROTOCOL         = split(":", item)[2]
            PORT             = split(":", item)[3]
        }
    }       

    FilterlocalAciFiltersIteration ={
        for key, value in local.aci_filter_map : key => value
        if lower(value.TENANT_NAME) != "infra"     
    }

    FilterlocalAciPhysicalDomainVlanPoolIteration ={
        for key, value in local.aci_vlan_pool_rows : key => value
        if lower(value.POOL_DOMAIN) == "physical"     
    }

    FilterlocalAciPhysicalDomainVlanPoolRangesIteration ={
        for key, value in local.aci_ranges_rows : key => value
        if lower(value.POOL_DOMAIN) == "physical"     
    }

    aci_physical_domain_iterations = csvdecode(file("./data/aci_physical_domain.csv"))

    aci_physical_domain_rows = {
        for i in local.aci_physical_domain_iterations : 
        i.TENANT_NAME => {
             TENANT_NAME     = i.TENANT_NAME
             POOL_DOMAIN     = i.POOL_DOMAIN
        }
    } 

    aci_epg_to_domain_iterations = csvdecode(file("./data/aci_epg_to_domain.csv"))

    aci_epg_to_domain_rows = {
        for i in local.aci_epg_to_domain_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME }:${i.APPLICATION_NAME}:${i.VLAN_ID}:${i.DOMAIN_TYPE}" => {
             TENANT_NAME            = i.TENANT_NAME
             ZONE_NAME              = i.ZONE_NAME  
             APPLICATION_NAME       = i.APPLICATION_NAME
             VLAN_ID                = i.VLAN_ID 
             DOMAIN_TYPE            = i.DOMAIN_TYPE
             BINDING_TYPE           = i.BINDING_TYPE 
             ALLOW_MICRO_SEG        = i.ALLOW_MICRO_SEG 
             ENCAP_MODE             = i.ENCAP_MODE 
             EPG_COS                = i.EPG_COS 
             EPG_COS_PREF           = i.EPG_COS_PREF
             INSTRUCTION_IMMEDIACY  = i.INSTRUCTION_IMMEDIACY
             NETFLOW_DIR            = i.NETFLOW_DIR
             NETFLOW_PREF           = i.NETFLOW_PREF
             NUM_PORTS              = i.NUM_PORTS
             PORT_ALLOCATION        = i.PORT_ALLOCATION
             PRIMARY_ENCAP          = i.PRIMARY_ENCAP
             PRIMARY_ENCAP_INNER    = i.PRIMARY_ENCAP_INNER
             RESOLUTION_IMMEDIACY   = i.RESOLUTION_IMMEDIACY
             SWITCHING_MODE         = i.SWITCHING_MODE 
        }
    } 

    FilterlocalAciEpgToPhysicalDomainIteration ={
        for key, value in local.aci_epg_to_domain_rows : key => value
        if lower(value.DOMAIN_TYPE) == "physical"     
    }

    aci_attachable_access_entity_profile_iterations = csvdecode(file("./data/aci_attachable_access_entity_profile.csv"))

    aci_attachable_access_entity_profile_rows = {
        for i in local.aci_attachable_access_entity_profile_iterations : 
        i.TENANT_NAME => {
             TENANT_NAME     = i.TENANT_NAME
        }
    } 

    FilterlocalAciExternalDomainVlanPoolIteration ={
        for key, value in local.aci_vlan_pool_rows : key => value
        if lower(value.POOL_DOMAIN) == "external"     
    }

    FilterlocalAciExternalDomainVlanPoolRangesIteration ={
        for key, value in local.aci_ranges_rows : key => value
        if lower(value.POOL_DOMAIN) == "external"     
    }

    aci_l3_domain_profile_iterations = csvdecode(file("./data/aci_l3_domain_profile.csv"))

    aci_l3_domain_profile_rows = {
        for i in local.aci_l3_domain_profile_iterations : 
        i.TENANT_NAME => {
             TENANT_NAME     = i.TENANT_NAME
             POOL_DOMAIN     = i.POOL_DOMAIN
        }
    } 

    aci_l3_outside_iterations = csvdecode(file("./data/aci_l3_outside.csv"))

    aci_l3_outside_rows = {
        for i in local.aci_l3_outside_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}" => {
             TENANT_NAME    = i.TENANT_NAME
             ZONE_NAME      = i.ZONE_NAME
             VRF_NAME       = i.VRF_NAME
             NEXT_HOP_TYPE  = i.NEXT_HOP_TYPE
             ENF_RT_CTRL    = i.ENF_RT_CTRL
             TARGET_DSCP    = i.TARGET_DSCP
             MPLS_ENABLED   = i.MPLS_ENABLED
             PIM            = i.PIM
        }
    } 

    aci_external_network_instance_profile_iterations = csvdecode(file("./data/aci_external_network_instance_profile.csv"))

    aci_external_network_instance_profile_rows = {
        for i in local.aci_external_network_instance_profile_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}" => {
             TENANT_NAME    = i.TENANT_NAME
             ZONE_NAME      = i.ZONE_NAME
             VRF_NAME       = i.VRF_NAME
             NEXT_HOP_TYPE  = i.NEXT_HOP_TYPE
             FLOOD_ON_ENCAP = i.FLOOD_ON_ENCAP
             MATCH_T        = i.MATCH_T
             PREF_GR_MEMB   = i.PREF_GR_MEMB
             PRIO           = i.PRIO 
             TARGET_DSCP    = i.TARGET_DSCP   
        }
    }     

    aci_l3_ext_subnet_iterations = csvdecode(file("./data/aci_l3_ext_subnet.csv"))

    aci_l3_ext_subnet_rows = {
        for i in local.aci_l3_ext_subnet_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}:${i.ALLOWED_PREFIX}" => {
             TENANT_NAME    = i.TENANT_NAME
             ZONE_NAME      = i.ZONE_NAME
             VRF_NAME       = i.VRF_NAME
             NEXT_HOP_TYPE  = i.NEXT_HOP_TYPE
             ALLOWED_PREFIX = i.ALLOWED_PREFIX
             ALLOWED_CIDR   = i.ALLOWED_CIDR 
             SCOPE          = i.SCOPE  
        }
    }   

    ###############################################
    #####  SWITCHPORT CONFIGURATION WORKFLOW ######
    ###############################################

    aci_lacp_policy_iterations = csvdecode(file("./data/aci_lacp_policy.csv"))

    aci_lacp_policy_rows = {
        for i in local.aci_lacp_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME    = i.POLICY_NAME
             MODE           = i.MODE
             CONTROL        = split(";", i.CONTROL)
             MIN_LINKS      = i.MIN_LINKS
             MAX_LINKS      = i.MAX_LINKS
        }
    }  

    aci_cdp_interface_policy_iterations = csvdecode(file("./data/aci_cdp_interface_policy.csv"))

    aci_cdp_interface_policy_rows = {
        for i in local.aci_cdp_interface_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME    = i.POLICY_NAME
             ADMIN_STATE    = i.ADMIN_STATE
        }
    }  

    aci_lldp_interface_policy_iterations = csvdecode(file("./data/aci_lldp_interface_policy.csv"))

    aci_lldp_interface_policy_rows = {
        for i in local.aci_lldp_interface_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME            = i.POLICY_NAME
             ADMIN_RECIEVE_STATE    = i.ADMIN_RECIEVE_STATE
             ADMIN_TRANSMIT_STATE   = i.ADMIN_TRANSMIT_STATE
        }
    }  

    aci_miscabling_protocol_interface_policy_iterations = csvdecode(file("./data/aci_miscabling_protocol_interface_policy.csv"))

    aci_miscabling_protocol_interface_policy_rows = {
        for i in local.aci_miscabling_protocol_interface_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME            = i.POLICY_NAME
             ADMIN_STATE            = i.ADMIN_STATE
        }
    }  

    aci_spanning_tree_interface_policy_iterations = csvdecode(file("./data/aci_spanning_tree_interface_policy.csv"))

    aci_spanning_tree_interface_policy_rows = {
        for i in local.aci_spanning_tree_interface_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME             = i.POLICY_NAME
             CONTROL                 = split(";", i.CONTROL)
        }
    }  

    aci_l2_interface_policy_iterations = csvdecode(file("./data/aci_l2_interface_policy.csv"))

    aci_l2_interface_policy_rows = {
        for i in local.aci_l2_interface_policy_iterations : 
        i.POLICY_NAME => {
             POLICY_NAME             = i.POLICY_NAME
             Q_In_Q                  = i.Q_In_Q
             vETHPORT_AGG            = i.vETHPORT_AGG 
             VLAN_SCOPE              = i.VLAN_SCOPE
        }
    }  

    aci_access_port_selector_iterations = csvdecode(file("./data/aci_access_port_selector.csv"))

    aci_access_port_selector_rows = {
        for i in local.aci_access_port_selector_iterations : 
        "${i.NODE_ID}:${i.NODE_SLOT}:${i.NODE_PORT}" => {
             NODE_ID                    = i.NODE_ID
             NODE_SLOT                  = i.NODE_SLOT 
             NODE_PORT                  = i.NODE_PORT
             TENANT_NAME                = i.TENANT_NAME
             ENDPOINT_NAME              = i.ENDPOINT_NAME
             ENDPOINT_SLOT              = i.ENDPOINT_SLOT
             ENDPOINT_PORT              = i.ENDPOINT_PORT
             ENDPOINT_MAKE              = i.ENDPOINT_MAKE 
             ENDPOINT_MODEL             = i.ENDPOINT_MODEL
             ENDPOINT_OS                = i.ENDPOINT_OS  
             ENDPOINT_INTERFACE_TYPE    = i.ENDPOINT_INTERFACE_TYPE
             DOMAIN_TYPE                = i.DOMAIN_TYPE 
             BOND_ENABLED               = i.BOND_ENABLED
             BOND_TYPE                  = i.BOND_TYPE
        }
    } 

    FilterlocalAciAccessPortSelectorIterationPhysical ={
        for key, value in local.aci_access_port_selector_rows : key => value
        if lower(value.DOMAIN_TYPE) == "physical"     
    }

    FilterlocalAciAccessPortSelectorIterationExternal ={
        for key, value in local.aci_access_port_selector_rows : key => value
        if lower(value.DOMAIN_TYPE) == "external"     
    }

    aci_leaf_access_port_policy_group_iterations = csvdecode(file("./data/aci_leaf_access_port_policy_group.csv"))

    aci_leaf_access_port_policy_group_rows = {
        for i in local.aci_leaf_access_port_policy_group_iterations : 
        "${i.TENANT_NAME}:${i.ENDPOINT_MAKE}:${i.ENDPOINT_MODEL}:${i.ENDPOINT_OS}:${i.ENDPOINT_INTERFACE_TYPE}" => {
             TENANT_NAME                = i.TENANT_NAME
             ENDPOINT_MAKE              = i.ENDPOINT_MAKE 
             ENDPOINT_MODEL             = i.ENDPOINT_MODEL
             ENDPOINT_OS                = i.ENDPOINT_OS
             ENDPOINT_INTERFACE_TYPE    = i.ENDPOINT_INTERFACE_TYPE
             DOMAIN_TYPE                = i.DOMAIN_TYPE
             CDP_POLICY_NAME            = i.CDP_POLICY_NAME 
             LLDP_POLICY_NAME           = i.LLDP_POLICY_NAME
             L2_POLICY_NAME             = i.L2_POLICY_NAME
             STP_POLICY_NAME            = i.STP_POLICY_NAME
             MCP_POLICY_NAME            = i.MCP_POLICY_NAME 
        }
    } 

    FilterlocalAciLeafAccessPortPolicyGroupPhysical ={
        for key, value in local.aci_leaf_access_port_policy_group_rows : key => value
        if lower(value.DOMAIN_TYPE) == "physical"     
    }

    FilterlocalAciLeafAccessPortPolicyGroupExternal ={
        for key, value in local.aci_leaf_access_port_policy_group_rows : key => value
        if lower(value.DOMAIN_TYPE) == "external"     
    }

    aci_leaf_access_bundle_policy_group_iterations = csvdecode(file("./data/aci_leaf_access_bundle_policy_group.csv"))

    aci_leaf_access_bundle_policy_group_rows = {
        for i in local.aci_leaf_access_bundle_policy_group_iterations : 
        "${i.TENANT_NAME}:${i.ENDPOINT_NAME}:${i.ENDPOINT_INTERFACE_TYPE}" => {
             TENANT_NAME                = i.TENANT_NAME
             ENDPOINT_NAME              = i.ENDPOINT_NAME
             ENDPOINT_MAKE              = i.ENDPOINT_MAKE 
             ENDPOINT_MODEL             = i.ENDPOINT_MODEL
             ENDPOINT_OS                = i.ENDPOINT_OS
             ENDPOINT_INTERFACE_TYPE    = i.ENDPOINT_INTERFACE_TYPE
             DOMAIN_TYPE                = i.DOMAIN_TYPE
             BOND_TYPE                  = i.BOND_TYPE
             LACP_POLICY_NAME           = i.LACP_POLICY_NAME
             CDP_POLICY_NAME            = i.CDP_POLICY_NAME 
             LLDP_POLICY_NAME           = i.LLDP_POLICY_NAME 
             L2_POLICY_NAME             = i.L2_POLICY_NAME
             STP_POLICY_NAME            = i.STP_POLICY_NAME
             MCP_POLICY_NAME            = i.MCP_POLICY_NAME
        }
    }

    FilterlocalAciLeafAccessBundlePolicyGroupIterationPhysical ={
        for key, value in local.aci_leaf_access_bundle_policy_group_rows : key => value
        if lower(value.DOMAIN_TYPE) == "physical"     
    }

    FilterlocalAciLeafAccessBundlePolicyGroupIterationExternal ={
        for key, value in local.aci_leaf_access_bundle_policy_group_rows : key => value
        if lower(value.DOMAIN_TYPE) == "external"     
    }

    aci_epg_to_static_path_nonbond_iterations = csvdecode(file("./data/aci_epg_to_static_path_nonbond.csv"))

    aci_epg_to_static_path_nonbond_rows = {
        for i in local.aci_epg_to_static_path_nonbond_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME }:${i.APPLICATION_NAME}:${i.DOT1Q_ENABLED}:${i.VLAN_ID}:${i.POD_ID}:${i.NODE_ID}:${i.NODE_SLOT}:${i.NODE_PORT}" => {
             TENANT_NAME        = i.TENANT_NAME
             ZONE_NAME          = i.ZONE_NAME
             APPLICATION_NAME   = i.APPLICATION_NAME 
             DOT1Q_ENABLED      = i.DOT1Q_ENABLED 
             VLAN_ID            = i.VLAN_ID 
             POD_ID             = i.POD_ID
             NODE_ID            = i.NODE_ID 
             NODE_SLOT          = i.NODE_SLOT  
             NODE_PORT          = i.NODE_PORT 
        }
    }

    aci_epg_to_static_path_portchannel_iterations = csvdecode(file("./data/aci_epg_to_static_path_portchannel.csv"))

    aci_epg_to_static_path_portchannel_rows = {
        for i in local.aci_epg_to_static_path_portchannel_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME }:${i.APPLICATION_NAME}:${i.DOT1Q_ENABLED}:${i.VLAN_ID}:${i.POD_ID}:${i.NODE_ID}:${i.ENDPOINT_NAME}:${i.ENDPOINT_INTERFACE_TYPE }" => {
             TENANT_NAME                = i.TENANT_NAME
             ZONE_NAME                  = i.ZONE_NAME
             APPLICATION_NAME           = i.APPLICATION_NAME
             DOT1Q_ENABLED              = i.DOT1Q_ENABLED
             VLAN_ID                    = i.VLAN_ID
             POD_ID                     = i.POD_ID
             NODE_ID                    = i.NODE_ID
             ENDPOINT_NAME              = i.ENDPOINT_NAME
             ENDPOINT_INTERFACE_TYPE    = i.ENDPOINT_INTERFACE_TYPE
             MULTI_TENANT               = i.MULTI_TENANT
        }
    }

    aci_epg_to_static_path_virtualportchannel_iterations = csvdecode(file("./data/aci_epg_to_static_path_virtualportchannel.csv"))

    aci_epg_to_static_path_virtualportchannel_rows = {
        for i in local.aci_epg_to_static_path_virtualportchannel_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME }:${i.APPLICATION_NAME}:${i.DOT1Q_ENABLED}:${i.VLAN_ID}:${i.POD_ID}:${i.ODD_NODE_ID}:${i.EVEN_NODE_ID}:${i.ENDPOINT_NAME}:${i.ENDPOINT_INTERFACE_TYPE }" => {
             TENANT_NAME                = i.TENANT_NAME
             ZONE_NAME                  = i.ZONE_NAME
             APPLICATION_NAME           = i.APPLICATION_NAME
             DOT1Q_ENABLED              = i.DOT1Q_ENABLED
             VLAN_ID                    = i.VLAN_ID
             POD_ID                     = i.POD_ID
             ODD_NODE_ID                = i.ODD_NODE_ID
             EVEN_NODE_ID               = i.EVEN_NODE_ID
             ENDPOINT_NAME              = i.ENDPOINT_NAME
             ENDPOINT_INTERFACE_TYPE    = i.ENDPOINT_INTERFACE_TYPE
             MULTI_TENANT               = i.MULTI_TENANT
        }
    }

    aci_logical_node_profile_iterations = csvdecode(file("./data/aci_logical_node_profile.csv"))

    aci_logical_node_profile_rows = {
        for i in local.aci_logical_node_profile_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}:${i.NODE_ID}" => {
             TENANT_NAME    = i.TENANT_NAME
             ZONE_NAME      = i.ZONE_NAME
             VRF_NAME       = i.VRF_NAME
             NEXT_HOP_TYPE  = i.NEXT_HOP_TYPE
             NODE_ID        = i.NODE_ID 
             TARGET_DSCP    = i.TARGET_DSCP
        }
    }

    aci_logical_node_to_fabric_node_iterations = csvdecode(file("./data/aci_logical_node_to_fabric_node.csv"))

    aci_logical_node_to_fabric_node_rows = {
        for i in local.aci_logical_node_to_fabric_node_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}:${i.POD_ID}:${i.NODE_ID}:${i.NODE_RTR_ID}" => {
             TENANT_NAME        = i.TENANT_NAME
             ZONE_NAME          = i.ZONE_NAME
             VRF_NAME           = i.VRF_NAME  
             NEXT_HOP_TYPE      = i.NEXT_HOP_TYPE
             POD_ID             = i.POD_ID 
             NODE_ID            = i.NODE_ID
             NODE_RTR_ID        = i.NODE_RTR_ID  
             RTR_ID_LOOP_BACK   = i.RTR_ID_LOOP_BACK
             CONFIG_ISSUES      = i.CONFIG_ISSUES
        }
    }

    aci_l3out_static_route_iterations = csvdecode(file("./data/aci_l3out_static_route.csv"))

    aci_l3out_static_route_rows = {
        for i in local.aci_l3out_static_route_iterations : 
        "${i.TENANT_NAME}:${i.ZONE_NAME}:${i.VRF_NAME}:${i.NEXT_HOP_TYPE}:${i.POD_ID}:${i.NODE_ID}:${i.NODE_RTR_ID}:${i.RT_NTWK_PFX}:${i.RT_NTWK_CIDR}:${i.NEXT_HOP_IP}" => {
             TENANT_NAME    = i.TENANT_NAME         
             ZONE_NAME      = i.ZONE_NAME
             VRF_NAME       = i.VRF_NAME
             NEXT_HOP_TYPE  = i.NEXT_HOP_TYPE
             POD_ID         = i.POD_ID
             NODE_ID        = i.NODE_ID  
             NODE_RTR_ID    = i.NODE_RTR_ID
             RT_NTWK_PFX    = i.RT_NTWK_PFX
             RT_NTWK_PFX    = i.RT_NTWK_CIDR
             NEXT_HOP_IP    = i.NEXT_HOP_IP
             ADMIN_DIST     = i.ADMIN_DIST 
             AGGREGATE      = i.AGGREGATE
             RT_CTRL        = i.RT_CTRL
        }
    }           

}


