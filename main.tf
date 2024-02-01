
    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/fabric_node_member
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_fabric_node_member" "localAciFabricNodeMemberIteration" {
      for_each      = local.aci_fabric_node_member_rows
    
      name          = each.value.NODE_NAME          
      serial        = each.value.SERIAL_NUMBER 
      annotation    = "orchestrator:terraform"
      description   = "${each.value.NODE_NAME}-${each.value.SERIAL_NUMBER} registered to node-id-${each.value.NODE_ID}"          
      ext_pool_id   = "0"
      fabric_id     = "1"
      node_id       = each.value.NODE_ID       
      node_type     = "unspecified"
      pod_id        = each.value.POD_ID 
      role          = each.value.NODE_ROLE   
    }
    
    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_interface_profile
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_leaf_interface_profile" "localAciLeafInterfaceProfileIteration" {
      for_each      = local.filtered_node_role_leaf_rows
    
      name          = join("_", [each.value.NODE_ID, "INT_PROF"]) 
      description   = "Container for Interface Selectors MOs mapped to node-id-${each.value.NODE_ID}"                           
      annotation    = "orchestrator:terraform"
    }
    
    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_switch_policy_group
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_access_switch_policy_group" "localAciAccessSwitchPolicyGroupIteration" {
      for_each                                                  = local.filtered_node_role_leaf_rows
    
      name                                                      = join("_", [each.value.NODE_ID, "SW_POL_GRP"]) 
      description                                               = "Container for all nested config applied to node-id-${NODE_ID}"                            
      annotation                                                = "orchestrator:terraform"
      
      # SETS ALL POLICIES TO DEFAULT.
      # YOU CAN CHANGE THESE IN GUI WITHOUT DRIFT DUE TO LIFECYCLE STATEMENT.
      # FUTURE FEATURE ENHANCEMENT TO SET THESE ON SWITCH PROVISION.
      
      relation_infra_rs_bfd_ipv4_inst_pol                       = "uni/infra/bfdIpv4Inst-default"
      relation_infra_rs_bfd_ipv6_inst_pol                       = "uni/infra/bfdIpv6Inst-default"
      relation_infra_rs_bfd_mh_ipv4_inst_pol                    = "uni/infra/bfdMhIpv4Inst-default"
      relation_infra_rs_bfd_mh_ipv6_inst_pol                    = "uni/infra/bfdMhIpv6Inst-default"
      relation_infra_rs_equipment_flash_config_pol              = "uni/infra/flashconfigpol-default"
      relation_infra_rs_fc_fabric_pol                           = "uni/infra/fcfabricpol-default"
      relation_infra_rs_fc_inst_pol                             = "uni/infra/fcinstpol-default"
      relation_infra_rs_iacl_leaf_profile                       = "uni/infra/iaclleafp-default"
      relation_infra_rs_l2_node_auth_pol                        = "uni/infra/nodeauthpol-default"
      relation_infra_rs_leaf_copp_profile                       = "uni/infra/coppleafp-default"
      relation_infra_rs_leaf_p_grp_to_cdp_if_pol                = "uni/infra/cdpIfP-default"
      relation_infra_rs_leaf_p_grp_to_lldp_if_pol               = "uni/infra/lldpIfP-default"
      relation_infra_rs_mon_node_infra_pol                      = "uni/infra/moninfra-default"
      relation_infra_rs_mst_inst_pol                            = "uni/infra/mstpInstPol-default"
      relation_infra_rs_poe_inst_pol                            = "uni/infra/poeInstP-default"
      relation_infra_rs_topoctrl_fast_link_failover_inst_pol    = "uni/infra/fastlinkfailoverinstpol-default"
      relation_infra_rs_topoctrl_fwd_scale_prof_pol             = "uni/infra/fwdscalepol-default"
      
      lifecycle {
        ignore_changes = [
          relation_infra_rs_bfd_ipv4_inst_pol,
          relation_infra_rs_bfd_ipv6_inst_pol,
          relation_infra_rs_bfd_mh_ipv4_inst_pol,
          relation_infra_rs_bfd_mh_ipv6_inst_pol,
          relation_infra_rs_equipment_flash_config_pol,
          relation_infra_rs_fc_fabric_pol,
          relation_infra_rs_fc_inst_pol,
          relation_infra_rs_iacl_leaf_profile,
          relation_infra_rs_l2_node_auth_pol,
          relation_infra_rs_leaf_copp_profile,
          relation_infra_rs_leaf_p_grp_to_cdp_if_pol,
          relation_infra_rs_leaf_p_grp_to_lldp_if_pol,
          relation_infra_rs_mon_node_infra_pol,
          relation_infra_rs_mst_inst_pol,
          relation_infra_rs_poe_inst_pol,
          relation_infra_rs_topoctrl_fast_link_failover_inst_pol,
          relation_infra_rs_topoctrl_fwd_scale_prof_pol
        ]
      }        
    }
    
    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_profile
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_leaf_profile" "localAciLeafProfileIteration" {
      for_each = local.filtered_node_role_leaf_rows
    
      name                          = join("_", [each.value.NODE_ID, "SW_PROF"])
      description                   = "Attachment point for policies configuring node-id-${each.value.NODE-ID}"
      annotation                    = "orchestrator:terraform"
    
      leaf_selector {
        name                        = join("_", [each.value.NODE_ID, "LFSEL"])
        switch_association_type     = "range"
        node_block {
          name                      = join("_", ["blk", each.value.NODE_ID])
          from_                     = each.value.NODE_ID
          to_                       = each.value.NODE_ID
        }
      }
    
      relation_infra_rs_acc_port_p  = [aci_leaf_interface_profile.localAciLeafInterfaceProfileIteration["${each.value.NODE_ID}"].id]
    }
    
    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/rest
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_rest" "localAciRestLeafSWPROFAssocSWPOLGRP" {
      for_each = local.filtered_node_role_leaf_rows
    
      path    = "/api/node/mo/uni/infra/nprof-${aci_leaf_profile.localAciLeafProfileIteration["${each.value.NODE_ID}"].name}/leaves-${each.value.NODE_ID}_LFSEL-typ-range.json"
      payload = <<EOF
    {
      "infraLeafS": {
        "attributes": {
          "dn": "uni/infra/nprof-${aci_leaf_profile.localAciLeafProfileIteration["${each.value.NODE_ID}"].name}/leaves-${each.value.NODE_ID}_LFSEL-typ-range"
        },
        "children": [
          {
            "infraRsAccNodePGrp": {
              "attributes": {
                "tDn": "uni/infra/funcprof/accnodepgrp-${aci_access_switch_policy_group.localAciAccessSwitchPolicyGroupIteration["${each.value.NODE_ID}"].name}",
                "status": "created"
              },
              "children": []
            }
          }
        ]
      }
    }
    EOF
    
      depends_on = [
        aci_leaf_profile.localAciLeafProfileIteration,
        aci_access_switch_policy_group.localAciAccessSwitchPolicyGroupIteration
      ]
    }

    # https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vpc_domain_policy
    # resource index key is "${each.value.NODE_ID}"
    resource "aci_vpc_domain_policy" "localAciVpcDomainPolicyIteration" {
      for_each = local.filtered_node_role_leaf_rows
    
      name       = join("_", [each.value.NODE_ID, each.value.NODE_PEER_ID, "VDP"])
      annotation = "orchestrator:terraform"
      dead_intvl = "200"
    }
    
    