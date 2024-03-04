#######################################
#####  FABRIC INVENTORY WORKFLOW ######
#######################################

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/fabric_node_member
# resource index key is "${each.value.SERIAL_NUMBER}"
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
    for_each      = local.aci_leaf_interface_profile_rows

    name          = join("_", [each.value.NODE_ID, "INT_PROF"]) 
    description   = "Container for Interface Selectors MOs mapped to node-id-${each.value.NODE_ID}"                           
    annotation    = "orchestrator:terraform"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_profile
# resource index key is "${each.value.NODE_ID}"
resource "aci_leaf_profile" "localAciLeafProfileIteration" {
    for_each = local.aci_leaf_profile_rows

    name                          = join("_", [each.value.NODE_ID, "SW_PROF"])
    description                   = "Attachment point for policies configuring node-id-${each.value.NODE_ID}"
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

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_switch_policy_group
# resource index key is "${each.value.NODE_ID}"
resource "aci_access_switch_policy_group" "localAciAccessSwitchPolicyGroupIteration" {
    for_each                                                  = local.aci_access_switch_policy_group_rows

    name                                                      = join("_", [each.value.NODE_ID, "SW_POL_GRP"])
    description                                               = "Container for all nested config applied to node-id-${each.value.NODE_ID}"
    annotation                                                = "orchestrator:terraform"
    
    relation_infra_rs_bfd_ipv4_inst_pol                       = "uni/infra/bfdIpv4Inst-${each.value.BFD_IPV4_INST_POL}"
    relation_infra_rs_bfd_ipv6_inst_pol                       = "uni/infra/bfdIpv6Inst-${each.value.BFD_IPV6_INST_POL}"
    relation_infra_rs_bfd_mh_ipv4_inst_pol                    = "uni/infra/bfdMhIpv4Inst-${each.value.BFD_MH_IPV4_INST_POL}"
    relation_infra_rs_bfd_mh_ipv6_inst_pol                    = "uni/infra/bfdMhIpv6Inst-${each.value.BFD_MH_IPV6_INST_POL}"
    relation_infra_rs_equipment_flash_config_pol              = "uni/infra/flashconfigpol-${each.value.EQUIPMENT_FLASH_CONFIG_POL}"
    relation_infra_rs_fc_fabric_pol                           = "uni/infra/fcfabricpol-${each.value.FC_FABRIC_POL}"
    relation_infra_rs_fc_inst_pol                             = "uni/infra/fcinstpol-${each.value.FC_INST_POL}"
    relation_infra_rs_iacl_leaf_profile                       = "uni/infra/iaclleafp-${each.value.IACL_LEAF_PROFILE}"
    relation_infra_rs_l2_node_auth_pol                        = "uni/infra/nodeauthpol-${each.value.L2_NODE_AUTH_POL}"
    relation_infra_rs_leaf_copp_profile                       = "uni/infra/coppleafp-${each.value.LEAF_COPP_PROFILE}"
    relation_infra_rs_leaf_p_grp_to_cdp_if_pol                = "uni/infra/cdpIfP-${each.value.LEAF_P_GRP_TO_CDP_IF_POL}"
    relation_infra_rs_leaf_p_grp_to_lldp_if_pol               = "uni/infra/lldpIfP-${each.value.LEAF_P_GRP_TO_LLDP_IF_POL}"
    relation_infra_rs_mon_node_infra_pol                      = "uni/infra/moninfra-${each.value.MON_NODE_INFRA_POL}"
    relation_infra_rs_mst_inst_pol                            = "uni/infra/mstpInstPol-${each.value.MST_INST_POL}"
    relation_infra_rs_poe_inst_pol                            = "uni/infra/poeInstP-${each.value.POE_INST_POL}"
    relation_infra_rs_topoctrl_fast_link_failover_inst_pol    = "uni/infra/fastlinkfailoverinstpol-${each.value.TOPOCTRL_FAST_LINK_FAILOVER_INST_POL}"
    relation_infra_rs_topoctrl_fwd_scale_prof_pol             = "uni/infra/fwdscalepol-${each.value.TOPOCTRL_FWD_SCALE_PROF_POL}"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/rest
# resource index key is "${i.NODE_ID}:${i.ACI_LEAF_PROFILE_KEY}:${i.ACI_ACCESS_SWITCH_POLICY_GROUP_KEY}"
resource "aci_rest" "localAciRestLeafProfilePolicyAttachmentIteration" {
    for_each = local.aci_rest_leaf_profile_policy_attachment_rows

    path    = "/api/node/mo/uni/infra/nprof-${aci_leaf_profile.localAciLeafProfileIteration["${each.value.ACI_LEAF_PROFILE_KEY}"].name}/leaves-${each.value.NODE_ID}_LFSEL-typ-range.json"
    payload = <<EOF
{
    "infraLeafS": {
    "attributes": {
        "dn": "uni/infra/nprof-${aci_leaf_profile.localAciLeafProfileIteration["${each.value.ACI_LEAF_PROFILE_KEY}"].name}/leaves-${each.value.NODE_ID}_LFSEL-typ-range"
    },
    "children": [
        {
        "infraRsAccNodePGrp": {
            "attributes": {
            "tDn": "uni/infra/funcprof/accnodepgrp-${aci_access_switch_policy_group.localAciAccessSwitchPolicyGroupIteration["${each.value.ACI_ACCESS_SWITCH_POLICY_GROUP_KEY}"].name}",
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
# resource index key is "${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"
resource "aci_vpc_domain_policy" "localAciVpcDomainPolicyIteration" {
    for_each = local.aci_vpc_domain_policy_rows

    name       = join("_", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID, "VDP"])
    annotation = "orchestrator:terraform"
    dead_intvl = each.value.DEAD_INTERVAL_SECONDS
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vpc_explicit_protection_group
# resource index key is "${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"
resource "aci_vpc_explicit_protection_group" "localAciVpcExplictProtectionGroupIteration" {
    for_each = local.aci_vpc_explicit_protection_group_rows

    name                             = join("_", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID, "VEPG"])
    annotation                       = "orchestrator:terraform"
    switch1                          = each.value.ODD_NODE_ID
    switch2                          = each.value.EVEN_NODE_ID
    vpc_domain_policy                = aci_vpc_domain_policy.localAciVpcDomainPolicyIteration["${each.value.ACI_VPC_DOMAIN_POLICY_KEY}"].name
    vpc_explicit_protection_group_id = each.value.GROUP_ID
} 

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/node_mgmt_epg
# resource index key is none
resource "aci_node_mgmt_epg" "localAciNodeMgmtEpg" {
  type                       = "out_of_band"
  management_profile_dn      = "uni/tn-mgmt/mgmtp-default"
  description                = "Terraform Managed Node Out-of-Band Endpoint Group."
  name                       = "TF_MGD_NODE_OOB_EPG"
  annotation                 = "orchestrator:terraform"
  relation_mgmt_rs_oo_b_prov = [aci_rest_managed.localAciNodeMgmtOobCtr.dn]
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/static_node_mgmt_address
# resource index key is "${each.value.NODE_ID}"
resource "aci_static_node_mgmt_address" "localAciStaticNodeMgmtAddressIteration" {
  for_each = local.aci_static_node_mgmt_address_rows

  management_epg_dn = aci_node_mgmt_epg.localAciNodeMgmtEpg.id
  t_dn              = "topology/pod-${aci_fabric_node_member.localAciFabricNodeMemberIteration["${each.value.SERIAL_NUMBER}"].pod_id}/node-${aci_fabric_node_member.localAciFabricNodeMemberIteration["${each.value.SERIAL_NUMBER}"].node_id}"
  type              = "out_of_band"
  description       = "Out-Of-Band IP-${each.value.NETWORK_IP} for Node-${each.value.NODE_ID}"
  addr              = "${each.value.NETWORK_IP}/${each.value.NETWORK_CIDR}"
  annotation        = "orchestrator:terraform"
  gw                = each.value.NETWORK_GATEWAY
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_rest_managed
# resource index key is none
resource "aci_rest_managed" "localAciNodeMgmtOobCtr" {
  dn         = "uni/tn-mgmt/oobbrc-TF_MGD_NODE_OOB_CTR"
  class_name = "vzOOBBrCP"
  content = {
    name  = "TF_MGD_NODE_OOB_CTR"
    descr = "Terraform Managed Node Out-of-Band Interface Contract."
    #annotation = "orchestrator:terraform" #commented this out because it created noise - Trevor Patch
    intent     = "install"
    prio       = "unspecified"
    scope      = "context"
    targetDscp = "unspecified"
  }
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_contract_subject
# resource index key is none
resource "aci_contract_subject" "localAciNodeMgmtOobCtrSubj" {
  contract_dn   = aci_rest_managed.localAciNodeMgmtOobCtr.id
  description   = "Terraform Managed Node Out-of-Band Interface Contract Subject."
  name          = "TF_MGD_NODE_OOB_CTR_SUBJ"
  annotation    = "orchestrator:terraform"
  rev_flt_ports = "yes"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_filter
# resource index key is none
resource "aci_filter" "localAciNodeMgmtOobCtrSubjFilt" {
  tenant_dn   = "uni/tn-mgmt"
  description = "Terraform Managed Node Out-of-Band Interface Contract Subject Filter."
  name        = "TF_MGD_NODE_OOB_CTR_SUBJ_FILT"
  annotation  = "orchestrator:terraform"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_filter
# resource index key is none
resource "aci_contract_subject_filter" "localAciNodeMgmtOobCtrSubjFiltAssoc" {
  contract_subject_dn = aci_contract_subject.localAciNodeMgmtOobCtrSubj.id
  filter_dn           = aci_filter.localAciNodeMgmtOobCtrSubjFilt.id
  action              = "permit"
  directives          = ["log"]
  priority_override   = "default"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_filter_entry
# resource index key is "${i.ENVIRONMENT}:${i.TENANT}:${i.ZONE}:${i.ETHER_TYPE}:${i.PROTOCOL}:${i.PORT}"
resource "aci_filter_entry" "localAciNodeMgmtOobCtrSubjFiltArpIterations" {
  for_each    = local.FilterlocalAciNodeMgmtOobCtrSubjFiltArpIterations

  name        = "allow-${each.value.ETHER_TYPE}-${each.value.PORT}"
  filter_dn   = aci_filter.localAciNodeMgmtOobCtrSubjFilt.id
  arp_opc     = each.value.PORT
  ether_t     = each.value.ETHER_TYPE
  description = "to/from the Terraform Managed Node Out-Of-Band Management Interface."
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_filter_entry
# resource index key is "${i.ENVIRONMENT}:${i.TENANT}:${i.ZONE}:${i.ETHER_TYPE}:${i.PROTOCOL}:${i.PORT}"
resource "aci_filter_entry" "localAciNodeMgmtOobCtrSubjFiltProtocolTcpIteration" {
  for_each      = local.FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolTcpIteration

  name          = "allow-${each.value.PROTOCOL}-${each.value.PORT}-${each.value.APPLICATION}"
  filter_dn     = aci_filter.localAciNodeMgmtOobCtrSubjFilt.id
  ether_t       = each.value.ETHER_TYPE
  stateful      = "yes"
  prot          = each.value.PROTOCOL
  d_from_port   = each.value.PORT
  d_to_port     = each.value.PORT
  description   = "to/from the Terraform Managed Node Out-Of-Band Management Interface."
  tcp_rules     = [
    "unspecified"
  ]  
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_filter_entry
# resource index key is "${each.value.ENVIRONMENT}:${each.value.TENANT}:${each.value.ZONE}:${each.value.ETHER_TYPE}:${each.value.PROTOCOL}:${each.value.PORT}"
resource "aci_filter_entry" "localAciNodeMgmtOobCtrSubjFiltProtocolUdpIteration" {
  for_each      = local.FilterlocalAciNodeMgmtOobCtrSubjFiltProtocolUdpIteration

  name          = "allow-${each.value.PROTOCOL}-${each.value.PORT}-${each.value.APPLICATION}"
  filter_dn     = aci_filter.localAciNodeMgmtOobCtrSubjFilt.id
  ether_t       = each.value.ETHER_TYPE
  stateful      = "yes"
  prot          = each.value.PROTOCOL
  d_from_port   = each.value.PORT
  d_to_port     = each.value.PORT
  description   = "to/from the Terraform Managed Node Out-Of-Band Management Interface."
}

/*
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# resource index key is "${each.value.NODE_ID}"
resource "null_resource" "localAciFabricNodeSoftwareStagingIterations" {
  for_each = local.aci_fabric_node_software_staging_rows

  provisioner "local-exec" {
    command = "python ./scripts/aci_fabric_node_software_staging.py"

    environment = {
      SWITCH_POD_ID  = each.value.POD_ID
      SWITCH_NODE_ID = each.value.NODE_ID
      TARGET_VERISON = var.TARGET_VERISON
    }
  }

  depends_on = [
    aci_fabric_node_member.localAciFabricNodeMemberIteration
  ]
}
*/

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_rest_managed
# resource index key is "${each.value.MAINTENANCE_GROUP_NAME}"
resource "aci_rest_managed" "localAciMaintenanceGroupSchedulePolicyIteration" {
  for_each      = local.aci_maintenance_group_schedule_policy_rows

  dn         = "uni/fabric/schedp-${each.value.MAINTENANCE_GROUP_NAME}_SCHD"
  class_name = "trigSchedP"
  content = {
    name   = "${each.value.MAINTENANCE_GROUP_NAME}_SCHD"
    status = "created,modified"
  }

  child {
    rn         = "abswinp-TRIGGER-${each.value.TRIGGER_INDEX}"
    class_name = "trigAbsWindowP"
    content = {
      name   = "TRIGGER-${each.value.TRIGGER_INDEX}"
      date   = timestamp() # UTC timestamp.
      status = "created,modified"
    }
  }

  depends_on = [
    aci_fabric_node_member.localAciFabricNodeMemberIteration
  ]

  lifecycle {
    ignore_changes = all  # This resource cannot be stored in TF State successufully
                          # and creates immense noise. To silence the noise, the
                          # everything about the resource is ignored after creation
                          # and the resource must be tainted to enact changes or
                          # correct drift
  } 

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/data-sources/maintenance_policy
# resource index key is "${each.value.MAINTENANCE_GROUP_NAME}"
resource "aci_maintenance_policy" "localAciMaintenanceGroupPolicyIteration" {
  for_each               = local.aci_maintenance_group_policy_rows

  name                   = "${each.value.MAINTENANCE_GROUP_NAME}_MNTPOL"
  admin_st               = each.value.ADMIN_STATE
  description            = "This Maintenance Policy Defines the Firmware/Software Version for ${each.value.MAINTENANCE_GROUP_NAME}"
  annotation             = "orchestrator:terraform"
  graceful               = each.value.GRACEFUL
  ignore_compat          = each.value.IGNORE_COMPATABILITY 
  notif_cond             = each.value.NOTIFICATIONS
  run_mode               = each.value.RUN_MODE
  version                = each.value.OS_VERSION
  version_check_override = each.value.OVERRIDE_STATE 

  relation_maint_rs_pol_scheduler = aci_rest_managed.localAciMaintenanceGroupSchedulePolicyIteration["${each.value.MAINTENANCE_GROUP_NAME}"].dn
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/pod_maintenance_group
# resource index key is "${each.value.MAINTENANCE_GROUP_NAME}"
resource "aci_pod_maintenance_group" "localAciPodMaintenanceGroupIteration" {
  for_each                    = local.aci_maintenance_group_rows

  name                        = "${each.value.MAINTENANCE_GROUP_NAME}_MNTGRP"
  description                 = "Container to Associate Nodes to Maintenance Policy"
  annotation                  = "orchestrator:terraform"
  fwtype                      = "switch"
  pod_maintenance_group_type  = "range"

  relation_maint_rs_mgrpp = aci_maintenance_policy.localAciMaintenanceGroupPolicyIteration["${each.value.MAINTENANCE_GROUP_NAME}"].id
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/maintenance_group_node
# resource index key is "${each.value.NODE_ID}"
resource "aci_maintenance_group_node" "localAciMaintenanceGroupNodeIteration" {
  for_each = local.aci_maintenance_group_node_rows

  name        = join("_", ["MaintGrpNodeBlk", each.value.NODE_ID])
  description = "NODE-${each.value.NODE_ID} is in Maintenance Group ${each.value.MAINTENANCE_GROUP_NAME}"
  annotation  = "orchestrator:terraform"
  from_       = each.value.NODE_ID
  to_         = each.value.NODE_ID

  pod_maintenance_group_dn = aci_pod_maintenance_group.localAciPodMaintenanceGroupIteration["${each.value.MAINTENANCE_GROUP_NAME}"].id
}

###########################################
#####  TENANT CONFIGURATION WORKFLOW ######
###########################################

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/tenant
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_tenant" "localAciTenantIteration" {
  for_each = local.aci_tenant_rows 

  name        = each.value.TENANT_NAME
  description = join(" ", [each.value.TENANT_NAME, "tenant was created via Terraform from a CI/CD Pipeline."])
  annotation  = "orchestrator:terraform"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/application_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}"
resource "aci_application_profile" "localAciApplicationProfileIteration" {
  for_each    = local.aci_application_profile_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name        = each.value.ZONE_NAME
  annotation  = "orchestrator:terraform"
  description = join(" ", [each.value.ZONE_NAME, "application profile was created as a macro-segmentation zone via Terraform from a CI/CD Pipeline."])

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vrf
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}" 
resource "aci_vrf" "localAciVrfIteration" {
  for_each                = local.aci_vrf_rows

  tenant_dn               = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name                    = each.value.VRF_NAME
  description             = join(" ", [each.value.VRF_NAME, " was created as a macro-segmentation zone via Terraform from a CI/CD Pipeline."])
  annotation              = "orchestrator:terraform"
  bd_enforced_enable      = each.value.BD_ENF
  ip_data_plane_learning  = each.value.IP_DATA_PLANE_LRN
  knw_mcast_act           = each.value.KNWN_MCAST_FWD 
  pc_enf_dir              = each.value.POL_ENF_DIR
  pc_enf_pref             = each.value.POL_ENF_PREF

  lifecycle {
    ignore_changes = [
      relation_fv_rs_ctx_to_bgp_ctx_af_pol, # set by resoure "aci_vrf_to_bgp_address_family_context"
      relation_fv_rs_ctx_to_ext_route_tag_pol,
      relation_fv_rs_ctx_mon_pol,
      relation_fv_rs_bgp_ctx_pol,
      relation_fv_rs_ctx_to_ep_ret,
      relation_fv_rs_ctx_to_ospf_ctx_pol,
      relation_fv_rs_ctx_to_eigrp_ctx_af_pol,
      relation_fv_rs_ctx_mcast_to,
      relation_fv_rs_vrf_validation_pol,
      relation_fv_rs_ospf_ctx_pol,
      name_alias
    ]
  } 

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vrf_snmp_context
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}" 
resource "aci_vrf_snmp_context" "localAciVrfSnmpContextIteration" {
  for_each = local.aci_vrf_rows

  vrf_dn     = aci_vrf.localAciVrfIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}"].id
  name       = join("_", [each.value.VRF_NAME, "SNMP"])
  annotation = "orchestrator:terraform"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vrf_snmp_context_community
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}" 
resource "aci_vrf_snmp_context_community" "localAciVrfSnmpContectCommunityIteration" {
  for_each = local.aci_vrf_rows

  vrf_snmp_context_dn = aci_vrf_snmp_context.localAciVrfSnmpContextIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}"].id
  name = join("-", [replace(each.value.VRF_NAME, "_", "-"),"VRF"])
  description = join(" ", [replace(each.value.VRF_NAME, "_", "-"),"VRF created via Terraform CI/CD"])
  annotation = "orchestrator:terraform"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bridge_domain
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}" 
resource "aci_bridge_domain" "localAciBridgeDomainIteration" {
  for_each                    = local.aci_bridge_domain_rows

  tenant_dn                   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name                        = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "BD"])
  annotation                  = "orchestrator:terraform"
  description                 = join(" ", [each.value.ZONE_NAME, each.value.APPLICATION_NAME, "bridge domain was created as a NCI Mode VLAN for a segmentation zone via Terraform from a CI/CD Pipeline."])

  optimize_wan_bandwidth      = each.value.OPTMZE_WAN_BW
  arp_flood                   = each.value.ARP_FLOOD
  ep_clear                    = each.value.EP_CLEAR 
  ep_move_detect_mode         = each.value.EP_MV_DETECT_MODE
  host_based_routing          = "no" # ISN via Nexus Dashboard MSO Not Used
  intersite_bum_traffic_allow = "no" # ISN via Nexus Dashboard MSO Not Used
  intersite_l2_stretch        = "no" # ISN via Nexus Dashboard MSO Not Used
  ip_learning                 = each.value.IP_LRN 
  ipv6_mcast_allow            = each.value.IPV6_MCAST_ALLOW 
  limit_ip_learn_to_subnets   = each.value.LIMIT_IP_LRN_SNET
  ll_addr                     = each.value.IPV6_LL_ADDR
  mac                         = each.value.BD_MAC
  mcast_allow                 = each.value.IPV4_MCAST_ALLOW
  multi_dst_pkt_act           = each.value.MCAST_PKT_ACT 
  bridge_domain_type          = each.value.BD_TYPE
  unicast_route               = each.value.UNICAST_ROUTE 
  unk_mac_ucast_act           = each.value.UNK_MAC_UCAST_ACT
  unk_mcast_act               = each.value.V6_UNK_MCAST_ACT
  v6unk_mcast_act             = each.value.V6_UNK_MCAST_ACT
  vmac                        = "not-applicable" # ISN via Nexus Dashboard MSO Not Used

  relation_fv_rs_ctx          = aci_vrf.localAciVrfIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}"].id
  relation_fv_rs_bd_to_out = each.value.NEXT_HOP_TYPE != "null" ? toset([aci_l3_outside.localAciL3OutsideIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id]) : toset([])

  lifecycle {
    ignore_changes = [
      relation_fv_rs_bd_to_ep_ret,
      relation_fv_rs_igmpsn,
      relation_fv_rs_bd_to_netflow_monitor_pol, 
      relation_fv_rs_bd_to_relay_p,
      relation_fv_rs_bd_to_fhs,
      relation_fv_rs_bd_flood_to, 
      relation_fv_rs_bd_to_nd_p,
      relation_fv_rs_abd_pol_mon_pol,
      relation_fv_rs_mldsn,
      relation_fv_rs_bd_to_profile
    ]
  }

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/subnet
# resource index key is "${each.value.NETWORK_PREFIX}"
resource "aci_subnet" "localAciSubnet" {
  for_each                = local.aci_subnet_rows

  parent_dn               = aci_bridge_domain.localAciBridgeDomainIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  description             = join(" ", [each.value.NETWORK_PREFIX, each.value.NETWORK_CIDR, "subnet was created as a NCI Mode VLAN for a segmentation zone via Terraform from a CI/CD Pipeline."])
  ip                      = "${each.value.NETWORK_GW}/${each.value.NETWORK_CIDR}"
  annotation              = "orchestrator:terraform"
  ctrl                    = ["${each.value.CONTROL_STATE}"]
  scope                   = ["${each.value.SCOPE}"]
  preferred               = each.value.PREFERRED
  virtual                 = "no"  # ISN via Nexus Dashboard MSO Not Used

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/application_epg
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}" 
resource "aci_application_epg" "localAciApplicationEndpointGroupIteration" {
  for_each                = local.aci_application_epg_rows

  application_profile_dn  = aci_application_profile.localAciApplicationProfileIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}"].id
  name                    = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "EPG"])
  description             = join(" ", [each.value.ZONE_NAME, each.value.APPLICATION_NAME, " was created as a NCI Mode VLAN for a segmentation zone via Terraform from a CI/CD Pipeline."])
  annotation              = "orchestrator:terraform"
  flood_on_encap          = each.value.FLOOD_ON_ENCAP 
  fwd_ctrl                = each.value.FWD_CTRL
  has_mcast_source        = each.value.HAS_MCAST_SRC
  is_attr_based_epg       = each.value.IS_ATTR_BASED
  match_t                 = each.value.MATCH_T
  pc_enf_pref             = each.value.PC_ENF_PREF 
  pref_gr_memb            = each.value.PREF_GR_MEMB
  prio                    = each.value.PRIO 
  shutdown                = each.value.SHUTDOWN
  relation_fv_rs_bd       = aci_bridge_domain.localAciBridgeDomainIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"
resource "aci_contract" "localAciContractIterationEpgInbound" {
  for_each    = local.aci_contract_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  description = join(" ", [each.value.APPLICATION_NAME, each.value.ZONE_NAME, "inbound contract epg was created as a NCI Mode segmentation zone via Terraform from a CICD."])
  name        = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "IN", "CTR"])
  annotation  = "orchestrator:terraform"
  prio        = each.value.PRIO
  scope       = each.value.SCOPE
  target_dscp = each.value.TARGET_DSCP

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract_subject
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"
resource "aci_contract_subject" "localAciContractSubjectIterationEpgInbound" {
  for_each      = local.aci_contract_subject_rows

  contract_dn   = aci_contract.localAciContractIterationEpgInbound["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  description   = join(" ", [each.value.APPLICATION_NAME, each.value.ZONE_NAME, "inbound contract epg was created as a NCI Mode segmentation zone via Terraform from a CICD."])
  name          = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "IN", "CTR"])
  annotation    = "orchestrator:terraform"
  cons_match_t  = each.value.CONS_MATCH_T
  prio          = each.value.PRIO 
  prov_match_t  = each.value.PROV_MATCH_T
  rev_flt_ports = each.value.REV_FLT_PORTS
  target_dscp   = each.value.TARGET_DSCP

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract_subject_filter
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}:${each.value.DIRECTION}:${each.value.FILTERS}"
resource "aci_contract_subject_filter" "localAciContractSubjectFilterIterationEpgInbound" {
  for_each            = local.FilterlocalAciContractSubjectFilterIterationEpgInbound

  contract_subject_dn = aci_contract_subject.localAciContractSubjectIterationEpgInbound["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  filter_dn           = aci_filter.localAciFiltersIteration["${each.value.FILTERS}"].id
  action              = each.value.ACTION
  directives          = ["${each.value.DIRECTIVES}"]
  priority_override   = each.value.PRIORITY_OVERRIDE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"
resource "aci_contract" "localAciContractIterationEpgOutbound" {
  for_each    = local.aci_contract_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  description = join(" ", [each.value.APPLICATION_NAME, each.value.ZONE_NAME, "Outbound contract epg was created as a NCI Mode segmentation zone via Terraform from a CICD."])
  name        = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "OUT", "CTR"])
  annotation  = "orchestrator:terraform"
  prio        = each.value.PRIO
  scope       = each.value.SCOPE
  target_dscp = each.value.TARGET_DSCP

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract_subject
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"
resource "aci_contract_subject" "localAciContractSubjectIterationEpgOutbound" {
  for_each      = local.aci_contract_subject_rows

  contract_dn   = aci_contract.localAciContractIterationEpgOutbound["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  description   = join(" ", [each.value.APPLICATION_NAME, each.value.ZONE_NAME, "outbound contract epg was created as a NCI Mode segmentation zone via Terraform from a CICD."])
  name          = join("_", ["VLAN", each.value.VLAN_ID, each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.APPLICATION_NAME, "OUT", "CTR"])
  annotation    = "orchestrator:terraform"
  cons_match_t  = each.value.CONS_MATCH_T
  prio          = each.value.PRIO 
  prov_match_t  = each.value.PROV_MATCH_T
  rev_flt_ports = each.value.REV_FLT_PORTS
  target_dscp   = each.value.TARGET_DSCP

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract_subject_filter
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}:${each.value.DIRECTION}:${each.value.FILTERS}"
resource "aci_contract_subject_filter" "localAciContractSubjectFilterIterationEpgOutbound" {
  for_each            = local.FilterlocalAciContractSubjectFilterIterationEpgOutbound

  contract_subject_dn = aci_contract_subject.localAciContractSubjectIterationEpgOutbound["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  filter_dn           = aci_filter.localAciFiltersIteration["${each.value.FILTERS}"].id
  action              = each.value.ACTION
  directives          = ["${each.value.DIRECTIVES}"]
  priority_override   = each.value.PRIORITY_OVERRIDE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/filter
# resource index key is "${each.value.TENANT}:${each.value.ETHER_TYPE}:${each.value.PROTOCOL}:${each.value.PORT}"
resource "aci_filter" "localAciFiltersIteration" {
  for_each    = local.FilterlocalAciFiltersIteration

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  description = join(" ", ["Allows", upper(each.value.ETHER_TYPE), upper(each.value.PROTOCOL), upper(each.value.PORT), "as specified by Terraform CI/CD Pipeline for EPGs"])
  name        = join("_", [upper(each.value.TENANT_NAME), upper(each.value.ETHER_TYPE), upper(each.value.PROTOCOL), upper(each.value.PORT), "FILT"])
  annotation  = "orchestrator:terraform"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vlan_pool
# resource index key is "${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"
resource "aci_vlan_pool" "localAciPhysicalDomainVlanPoolIteration" {
  for_each = local.FilterlocalAciPhysicalDomainVlanPoolIteration

  name        = join("_", [each.value.TENANT_NAME, "PHYS-DOM", "VLAN-POOL"])
  description = join(" ", [each.value.TENANT_NAME, " tenant VLAN Pool was created in a NCI Mode via Terraform from a CI/CD Pipeline."])
  annotation  = "orchestrator:terraform"
  alloc_mode  = each.value.ALLOCATION_MODE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/ranges
# resource index key is "${each.value.VLAN_ID}"
resource "aci_ranges" "localAciPhysicalDomainVlanPoolRangesIteration" {
  for_each      = local.FilterlocalAciPhysicalDomainVlanPoolRangesIteration

  annotation    = "orchestrator:terraform"
  description   = join(" ", ["VLAN-", each.value.VLAN_ID, " was created as a NCI Mode VLAN for a segmentation zone via Terraform from a CI/CD Pipeline."])
  vlan_pool_dn  = aci_vlan_pool.localAciPhysicalDomainVlanPoolIteration["${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"].id
  from          = "vlan-${each.value.VLAN_ID}"
  to            = "vlan-${each.value.VLAN_ID}"
  alloc_mode    = each.value.ALLOCATION_MODE
  role          = each.value.ROLE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/physical_domain
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_physical_domain" "localAciPhysicalDomainIteration" {
  for_each                  = local.aci_physical_domain_rows

  name                      = join("_", [each.value.TENANT_NAME, "PHYS-DOM"])
  annotation                = "orchestrator:terraform"
  relation_infra_rs_vlan_ns = aci_vlan_pool.localAciPhysicalDomainVlanPoolIteration["${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"].id
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/epg_to_domain
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME }:${each.value.APPLICATION_NAME}:${each.value.VLAN_ID}:${each.value.DOMAIN_TYPE}"
resource "aci_epg_to_domain" "localAciEpgToPhysicalDomainIteration" {
  for_each              = local.FilterlocalAciEpgToPhysicalDomainIteration

  application_epg_dn    = aci_application_epg.localAciApplicationEndpointGroupIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  tdn                   = aci_physical_domain.localAciPhysicalDomainIteration["${each.value.TENANT_NAME}"].id

  annotation            = "orchestrator:terraform"
  binding_type          = each.value.BINDING_TYPE
  allow_micro_seg       = each.value.ALLOW_MICRO_SEG 
  encap                 = "vlan-${each.value.VLAN_ID}"
  encap_mode            = each.value.ENCAP_MODE 
  epg_cos               = each.value.EPG_COS 
  epg_cos_pref          = each.value.EPG_COS_PREF
  instr_imedcy          = each.value.INSTRUCTION_IMMEDIACY
  netflow_dir           = each.value.NETFLOW_DIR
  netflow_pref          = each.value.NETFLOW_PREF
  num_ports             = each.value.NUM_PORTS
  port_allocation       = each.value.PORT_ALLOCATION
  primary_encap         = each.value.PRIMARY_ENCAP
  primary_encap_inner   = each.value.PRIMARY_ENCAP_INNER
  res_imedcy            = each.value.RESOLUTION_IMMEDIACY
  switching_mode        = each.value.SWITCHING_MODE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/attachable_access_entity_profile
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_attachable_access_entity_profile" "localAciAttachableEntityAccessProfileIterationPhysical" {
  for_each                = local.aci_attachable_access_entity_profile_rows

  name                    = join("_", [each.value.TENANT_NAME,"PHYS", "AAEP"])
  description             = join(" ", [each.value.TENANT_NAME, " AAEP allows access to the associated tenant in a NCI Mode via Terraform from a CI/CD Pipeline."])
  annotation              = "orchestrator:terraform"
  relation_infra_rs_dom_p = [aci_physical_domain.localAciPhysicalDomainIteration["${each.value.TENANT_NAME}"].id]

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/attachable_access_entity_profile
# resource index key is NULL
resource "aci_attachable_access_entity_profile" "localAciGlobalAttachableEntityAccessProfileIterationPhysical" {
  name                    = "GLOBAL_PHYS_AAEP"
  description             = "Global AAEP for all tenants"
  annotation              = "orchestrator:terraform"

  # Attached to all physical domains created by terraform
  relation_infra_rs_dom_p = values(aci_physical_domain.localAciPhysicalDomainIteration)[*].id

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/attachable_access_entity_profile
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_attachable_access_entity_profile" "localAciAttachableEntityAccessProfileIterationExternal" {
  for_each                = local.aci_attachable_access_entity_profile_rows

  name                    = join("_", [each.value.TENANT_NAME,"EXT", "AAEP"])
  description             = join(" ", [each.value.TENANT_NAME, " AAEP allows access to the associated tenant in a NCI Mode via Terraform from a CI/CD Pipeline."])
  annotation              = "orchestrator:terraform"

  relation_infra_rs_dom_p = [aci_l3_domain_profile.localAciExternalDomainIteration["${each.value.TENANT_NAME}"].id]

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/attachable_access_entity_profile
# resource index key is NULL
resource "aci_attachable_access_entity_profile" "localAciGlobalAttachableEntityAccessProfileIterationExternal" {
  name                    = "GLOBAL_EXT_AAEP"
  description             = "Global AAEP for all tenants"
  annotation              = "orchestrator:terraform"

  # Attached to all physical domains created by terraform
  relation_infra_rs_dom_p = values(aci_l3_domain_profile.localAciExternalDomainIteration)[*].id

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vlan_pool
# resource index key is "${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"
resource "aci_vlan_pool" "localAciExternalDomainVlanPoolIteration" {
  for_each    = local.FilterlocalAciExternalDomainVlanPoolIteration

  name        = join("_", [each.value.TENANT_NAME, "EXT-DOM", "VLAN-POOL"])
  description = join(" ", [each.value.TENANT_NAME, " tenant L3Out VLAN Pool was created in a NCI Mode via Terraform from a CI/CD Pipeline."])
  annotation  = "orchestrator:terraform"
  alloc_mode  = "static"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/ranges
# resource index key is "${each.value.VLAN_ID}"
resource "aci_ranges" "localAciExternalDomainVlanPoolRangesIteration" {
  for_each      = local.FilterlocalAciExternalDomainVlanPoolRangesIteration 

  annotation    = "orchestrator:terraform"
  description   = join(" ", ["VLAN-", each.value.VLAN_ID, "L3Out Transit was created via Terraform"])
  vlan_pool_dn  = aci_vlan_pool.localAciExternalDomainVlanPoolIteration["${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"].id
  from          = "vlan-${each.value.VLAN_ID}"
  to            = "vlan-${each.value.VLAN_ID}"
  alloc_mode    = each.value.ALLOCATION_MODE
  role          = each.value.ROLE

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3_domain_profile
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_l3_domain_profile" "localAciExternalDomainIteration" {
  for_each                  = local.aci_l3_domain_profile_rows

  name                      = join("_", [each.value.TENANT_NAME, "EXT-DOM"])
  annotation                = "orchestrator:terraform"
  relation_infra_rs_vlan_ns = aci_vlan_pool.localAciExternalDomainVlanPoolIteration["${each.value.TENANT_NAME}:${each.value.POOL_DOMAIN}"].id

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3_outside
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"
resource "aci_l3_outside" "localAciL3OutsideIteration" {
  for_each                      = local.aci_l3_outside_rows
  
  tenant_dn                     = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name                          = join("_", [each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.VRF_NAME, each.value.NEXT_HOP_TYPE, "L3OUT"])
  description                   = join(" ", [each.value.ZONE_NAME, "L3Out routes to the", each.value.NEXT_HOP_TYPE ,"as part of a macro-segmentation zone via Terraform."])
  annotation                    = "orchestrator:terraform"
  enforce_rtctrl                = ["${each.value.ENF_RT_CTRL}"]
  target_dscp                   = each.value.TARGET_DSCP
  mpls_enabled                  = each.value.MPLS_ENABLED
  pim                           = ["${each.value.PIM}"]
  
  relation_l3ext_rs_ectx        = aci_vrf.localAciVrfIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}" ].id
  relation_l3ext_rs_l3_dom_att  = aci_l3_domain_profile.localAciExternalDomainIteration["${each.value.TENANT_NAME}"].id

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/external_network_instance_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"
resource "aci_external_network_instance_profile" "localAciExternalNetworkInstanceProfileIteration" {
  for_each        = local.aci_external_network_instance_profile_rows
  
  l3_outside_dn   = aci_l3_outside.localAciL3OutsideIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  name            = join("_", [each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.VRF_NAME, each.value.NEXT_HOP_TYPE, "L3OUT-EPG"])
  annotation      = "orchestrator:terraform"  
  flood_on_encap  = each.value.FLOOD_ON_ENCAP
  match_t         = each.value.MATCH_T
  pref_gr_memb    = each.value.PREF_GR_MEMB
  prio            = each.value.PRIO 
  target_dscp     = each.value.TARGET_DSCP
  
  relation_fv_rs_prov  = [aci_contract.localAciContractIterationL3Out["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id]
  relation_fv_rs_cons  = [aci_contract.localAciContractIterationL3Out["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id]

}  

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3_ext_subnet
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ALLOWED_PREFIX}"
resource "aci_l3_ext_subnet" "localAciL3ExtSubnetIterationImport" {
  for_each                              = local.FilterlocalAciL3ExtSubnetIterationImport
  
  external_network_instance_profile_dn  = aci_external_network_instance_profile.localAciExternalNetworkInstanceProfileIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  description                           = "Allowed"
  ip                                    = "${each.value.ALLOWED_PREFIX}/${each.value.ALLOWED_CIDR}"
  annotation                            = "orchestrator:terraform" 
  scope                                 = "${each.value.SCOPE}"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3_ext_subnet
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ALLOWED_PREFIX}"
resource "aci_l3_ext_subnet" "localAciL3ExtSubnetIterationExport" {
  for_each                              = local.FilterlocalAciL3ExtSubnetIterationExport
  
  external_network_instance_profile_dn  = aci_external_network_instance_profile.localAciExternalNetworkInstanceProfileIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  description                           = "Allowed"
  ip                                    = "${each.value.ALLOWED_PREFIX}/${each.value.ALLOWED_CIDR}"
  annotation                            = "orchestrator:terraform" 
  scope                                 = "${each.value.SCOPE}"
  
  relation_l3ext_rs_subnet_to_rt_summ   = aci_bgp_route_summarization.localAciBgpRouteSummarizationIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"].id
  
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"
resource "aci_contract" "localAciContractIterationL3Out" {
  for_each    = local.aci_external_network_instance_profile_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name        = join("_", [each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.VRF_NAME, each.value.NEXT_HOP_TYPE, "L3OUT-EPG", "CTR"])
  description = "Defines what communication is allowed to happen in and out of the L3out EPG"
  annotation  = "orchestrator:terraform" 
  prio        = "unspecified"
  scope       = "context"
  target_dscp = "unspecified"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/contract_subject
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"
resource "aci_contract_subject" "localAciContractSubjectIterationL3Out" {
  for_each              = local.aci_external_network_instance_profile_rows

  contract_dn           = aci_contract.localAciContractIterationL3Out["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  description           = "Defines what communication is allowed to happen in and out of the L3out EPG"
  name                  = join("_", [each.value.TENANT_NAME, each.value.ZONE_NAME, each.value.VRF_NAME, each.value.NEXT_HOP_TYPE, "L3OUT-EPG", "CTR", "SUBJ"])
  annotation            = "orchestrator:terraform" 
  cons_match_t          = "AtleastOne"
  prio                  = "unspecified"
  prov_match_t          = "AtleastOne"
  rev_flt_ports         = "yes"
  target_dscp           = "unspecified"
  apply_both_directions = "yes"
   
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/filter_entry
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"
resource "aci_contract_subject_filter" "localAciContractSubjectFilterIterationL3Out" {
  for_each              = local.aci_external_network_instance_profile_rows

  contract_subject_dn   = aci_contract_subject.localAciContractSubjectIterationL3Out["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  filter_dn             = aci_filter.localAciFilterIterationIPAny["${each.value.TENANT_NAME}"].id
  annotation            = "orchestrator:terraform"
  action                = "permit"
  directives            = ["log"]
  priority_override     = "default"

  lifecycle {
    ignore_changes = [
      annotation # Creates Noise; Ignoring to Silence
    ]
  }      
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/filter
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_filter" "localAciFilterIterationIPAny" {
  for_each    = local.aci_tenant_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name        = join("_",[each.value.TENANT_NAME, "IP", "ANY", "FILT"])
  description = "Filter for Any IP traffic"
  annotation  = "orchestrator:terraform" 
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/filter_entry
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_filter_entry" "localAciFilterEntryIterationIpAny" {
  for_each      = local.aci_tenant_rows

  filter_dn     = aci_filter.localAciFilterIterationIPAny["${each.value.TENANT_NAME}"].id
  annotation    = "orchestrator:terraform"
  name          = join("_",[each.value.TENANT_NAME, "ALLOW", "IP", "ANY"])
  apply_to_frag = "yes"
  arp_opc       = "unspecified"
  d_from_port   = "unspecified"
  d_to_port     = "unspecified"
  ether_t       = "ip"
  icmpv4_t      = "unspecified"
  icmpv6_t      = "unspecified"
  match_dscp    = "unspecified"
  prot          = "unspecified"
  s_from_port   = "unspecified"
  s_to_port     = "unspecified"
  stateful      = "yes"

}

###############################################
#####  SWITCHPORT CONFIGURATION WORKFLOW ######
###############################################

/*
# THIS RESOURCE WAS NOT WORKING WITH THE CISCO
# DEVNET SANDBOX AS EXPECTED; GETTING 200s
# BUT RESOURCE NOT BEING CREATED; CREATED 
# REGULAR REST CALL

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/aci_rest_managed
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_rest_managed" "localAciLeafInterfaceLinkLevelPolicyIteration" {
  for_each            = local.aci_leaf_interface_link_level_policy_rows

  dn                  = "uni/infra/hintfpol-${upper(each.value.POLICY_NAME)}"
  class_name          = "fabricHIfPol"
  content             = {
    name              = upper(each.value.POLICY_NAME)
    descr             = "created via Terraform CI/CD Pipeline"
    #annotation        = "orchestrator:terraform" #Annotation is not supported in content per APIC Error
    autoNeg           = lower(each.value.AUTONEG)
    dfeDelayMs        = each.value.DFEDELAYMS
    emiRetrain        = lower(each.value.EMIRETRAIN)
    fecMode           = lower(each.value.FECMODE)
    linkDebounce      = each.value.LINKDEBOUNCE
    portPhyMediaType  = lower(each.value.PORTPHYMEDIATYPE)
    speed             = can(regex("[0-9]+", each.value.SPEED)) ? each.value.SPEED : lower(each.value.SPEED)

  }
}
*/


# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/rest
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_rest" "localAciLeafInterfaceLinkLevelPolicyIteration" {
  for_each   = local.aci_leaf_interface_link_level_policy_rows

  path       = "/api/node/mo/uni/infra/hintfpol-${upper(each.value.POLICY_NAME)}.json"
  payload = <<EOF
{
  "fabricHIfPol": {
    "attributes": {
      "dn" : "uni/infra/hintfpol-${upper(each.value.POLICY_NAME)}",
      "name" : "${upper(each.value.POLICY_NAME)}",
      "autoNeg" : "${lower(each.value.AUTONEG)}",
      "dfeDelayMs" : "${each.value.DFEDELAYMS}",
      "emiRetrain" : "${lower(each.value.EMIRETRAIN)}",
      "fecMode" : "${lower(each.value.FECMODE)}",
      "linkDebounce" : "${each.value.LINKDEBOUNCE}",
      "portPhyMediaType" : "${lower(each.value.PORTPHYMEDIATYPE)}",
      "speed" : "${can(regex("[0-9]+", each.value.SPEED)) ? each.value.SPEED : lower(each.value.SPEED)}",
      "rn" : "hintfpol-${upper(each.value.POLICY_NAME)}",
      "status" : "created"
    },
    "children": []
  }
}
  EOF
}


# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/lacp_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_lacp_policy" "localAciLacpActivePolicyIteration" {
  for_each    = local.aci_lacp_policy_rows

  name        = each.value.POLICY_NAME
  description = "created via Terraform CI/CD Pipeline"
  annotation  = "orchestrator:terraform"
  ctrl        = each.value.CONTROL
  max_links   = each.value.MAX_LINKS
  min_links   = each.value.MIN_LINKS
  mode        = each.value.MODE
  
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/cdp_interface_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_cdp_interface_policy" "localAciCdpInterfacePolicyIteration" {
  for_each    = local.aci_cdp_interface_policy_rows

  name        = each.value.POLICY_NAME
  admin_st    = each.value.ADMIN_STATE
  annotation  = "orchestrator:terraform"
  description = "created via Terraform CI/CD Pipeline"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/lldp_interface_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_lldp_interface_policy" "localAciLldpInterfacePolicyIteration" {
  for_each    = local.aci_lldp_interface_policy_rows

  description = "created via Terraform CI/CD Pipeline"
  name        = each.value.POLICY_NAME
  admin_rx_st = each.value.ADMIN_RECIEVE_STATE
  admin_tx_st = each.value.ADMIN_TRANSMIT_STATE
  annotation  = "orchestrator:terraform"

} 

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/miscabling_protocol_interface_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_miscabling_protocol_interface_policy" "localAciMiscablingProtocolInterfacePolicy" {
  for_each    = local.aci_miscabling_protocol_interface_policy_rows

  description = "created via Terraform CI/CD Pipeline"
  name        = each.value.POLICY_NAME
  admin_st    = each.value.ADMIN_STATE
  annotation  = "orchestrator:terraform"

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/spanning_tree_interface_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_spanning_tree_interface_policy" "localAciSpanningTreeInterfacePolicyIteration" {
  for_each    = local.aci_spanning_tree_interface_policy_rows

  name        = each.value.POLICY_NAME
  annotation  = "orchestrator:terraform"
  description = "created via Terraform CI/CD Pipeline"
  ctrl        = each.value.CONTROL
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l2_interface_policy
# resource index key is "${each.value.POLICY_NAME}"
resource "aci_l2_interface_policy" "localAciL2InterfacePolicyIteration" {
  for_each    = local.aci_l2_interface_policy_rows 

  name        = each.value.POLICY_NAME
  annotation  = "orchestrator:terraform"
  description = "created via Terraform CI/CD Pipeline"
  qinq        = each.value.Q_In_Q
  vepa        = each.value.vETHPORT_AGG
  vlan_scope  = each.value.VLAN_SCOPE
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_access_port_policy_group
# resource index key is "${each.value.TENANT_NAME}:${each.value.ENDPOINT_MAKE}:${each.value.ENDPOINT_MODEL}:${each.value.ENDPOINT_OS}:${each.value.ENDPOINT_INTERFACE_TYPE}" 
resource "aci_leaf_access_port_policy_group" "localAciLeafAccessPortPolicyGroupPhysical" {
  for_each                      = local.FilterlocalAciLeafAccessPortPolicyGroupPhysical
  
  name                          = join("_",[each.value.TENANT_NAME, each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"])
  description                   = join(" ",["Affects all", each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE, "interface policy settings within tenant", each.value.TENANT_NAME])
  annotation                    = "orchestrator:terraform"
  
  # Attachable Access Entity Profile:
  relation_infra_rs_att_ent_p   = lower(each.value.TENANT_NAME) != "global" ? aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationPhysical["${each.value.TENANT_NAME}"].id : aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationPhysical.id
  
  # L2 Interface Policy:
  relation_infra_rs_l2_if_pol   = aci_l2_interface_policy.localAciL2InterfacePolicyIteration["${each.value.L2_POLICY_NAME}"].id 

  # Spanning Treee Interface Policy:
  relation_infra_rs_stp_if_pol  = aci_spanning_tree_interface_policy.localAciSpanningTreeInterfacePolicyIteration["${each.value.STP_POLICY_NAME}"].id 

  # CDP Neighbors Interface Policy:
  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.localAciCdpInterfacePolicyIteration["${each.value.CDP_POLICY_NAME}"].id 

  # Miscabling Procotol Interface Policy:
  relation_infra_rs_mcp_if_pol  = aci_miscabling_protocol_interface_policy.localAciMiscablingProtocolInterfacePolicy["${each.value.MCP_POLICY_NAME}"].id 

  # LLDP Interface Policy:
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.localAciLldpInterfacePolicyIteration["${each.value.LLDP_POLICY_NAME}"].id 

  lifecycle {
    ignore_changes = [
      relation_infra_rs_qos_egress_dpp_if_pol,
      relation_infra_rs_l2_inst_pol,
      relation_infra_rs_qos_ingress_dpp_if_pol,
      relation_infra_rs_fc_if_pol,
      relation_infra_rs_mon_if_infra_pol,
      relation_infra_rs_qos_sd_if_pol,
      relation_infra_rs_qos_pfc_if_pol,
      relation_infra_rs_dwdm_if_pol,
      relation_infra_rs_span_v_dest_grp,
      relation_infra_rs_copp_if_pol,
      relation_infra_rs_l2_port_security_pol,
      relation_infra_rs_l2_port_auth_pol,
      relation_infra_rs_netflow_monitor_pol,
      relation_infra_rs_h_if_pol,
      relation_infra_rs_qos_dpp_if_pol,
      relation_infra_rs_macsec_if_pol,
      relation_infra_rs_poe_if_pol,
      relation_infra_rs_stormctrl_if_pol,
      relation_infra_rs_span_v_src_grp
    ]
  }  

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_access_port_policy_group
# resource index key is "${each.value.TENANT_NAME}:${each.value.ENDPOINT_MAKE}:${each.value.ENDPOINT_MODEL}:${each.value.ENDPOINT_OS}:${each.value.ENDPOINT_INTERFACE_TYPE}" 
resource "aci_leaf_access_port_policy_group" "localAciLeafAccessPortPolicyGroupExternal" {
  for_each    = local.FilterlocalAciLeafAccessPortPolicyGroupExternal
  
  name        = join("_",[each.value.TENANT_NAME, each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"])
  description = join(" ",["Affects all", each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE, "interface policy settings within tenant", each.value.TENANT_NAME])
  annotation  = "orchestrator:terraform"
  
  #Attachable Access Entity Profile:
  relation_infra_rs_att_ent_p   = lower(each.value.TENANT_NAME) != "global" ? aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationExternal["${each.value.TENANT_NAME}"].id : aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationExternal.id

  # L2 Interface Policy:
  relation_infra_rs_l2_if_pol   = aci_l2_interface_policy.localAciL2InterfacePolicyIteration["${each.value.L2_POLICY_NAME}"].id 

  # Spanning Treee Interface Policy:
  relation_infra_rs_stp_if_pol  = aci_spanning_tree_interface_policy.localAciSpanningTreeInterfacePolicyIteration["${each.value.STP_POLICY_NAME}"].id 

  # CDP Neighbors Interface Policy:
  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.localAciCdpInterfacePolicyIteration["${each.value.CDP_POLICY_NAME}"].id 

  # Miscabling Procotol Interface Policy:
  relation_infra_rs_mcp_if_pol  = aci_miscabling_protocol_interface_policy.localAciMiscablingProtocolInterfacePolicy["${each.value.MCP_POLICY_NAME}"].id 

  # LLDP Interface Policy:
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.localAciLldpInterfacePolicyIteration["${each.value.LLDP_POLICY_NAME}"].id 

  lifecycle {
    ignore_changes = [
      relation_infra_rs_qos_egress_dpp_if_pol,
      relation_infra_rs_l2_inst_pol,
      relation_infra_rs_qos_ingress_dpp_if_pol,
      relation_infra_rs_fc_if_pol,
      relation_infra_rs_mon_if_infra_pol,
      relation_infra_rs_qos_sd_if_pol,
      relation_infra_rs_qos_pfc_if_pol,
      relation_infra_rs_dwdm_if_pol,
      relation_infra_rs_span_v_dest_grp,
      relation_infra_rs_copp_if_pol,
      relation_infra_rs_l2_port_security_pol,
      relation_infra_rs_l2_port_auth_pol,
      relation_infra_rs_netflow_monitor_pol,
      relation_infra_rs_h_if_pol,
      relation_infra_rs_qos_dpp_if_pol,
      relation_infra_rs_macsec_if_pol,
      relation_infra_rs_poe_if_pol,
      relation_infra_rs_stormctrl_if_pol,
      relation_infra_rs_span_v_src_grp
    ]
  }  

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_access_bundle_policy_group
# resource index key is "${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"
resource "aci_leaf_access_bundle_policy_group" "localAciLeafAccessBundlePolicyGroupIterationPhysical" {
  for_each                        = local.FilterlocalAciLeafAccessBundlePolicyGroupIterationPhysical

  name                            = lower(each.value.BOND_TYPE) == "vpc" ? join("_",["VPC", "L2", each.value.TENANT_NAME, each.value.ENDPOINT_NAME, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"]) : join("_",["PC", "L2", each.value.TENANT_NAME, each.value.ENDPOINT_NAME, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"])
  annotation                      = "orchestrator:terraform"
  description                     = join(" ",[each.value.ENDPOINT_NAME, each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE ])
  lag_t                           = lower(each.value.BOND_TYPE) == "vpc" ? "node" : "link"

  #Attachable Access Entity Profile:
  relation_infra_rs_att_ent_p     = lower(each.value.TENANT_NAME) != "global" ? aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationPhysical["${each.value.TENANT_NAME}"].id : aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationPhysical.id
  
  # LACP Policy:
  relation_infra_rs_lacp_pol      = aci_lacp_policy.localAciLacpActivePolicyIteration["${each.value.LACP_POLICY_NAME}"].id 

  # L2 Interface Policy:
  relation_infra_rs_l2_if_pol     = aci_l2_interface_policy.localAciL2InterfacePolicyIteration["${each.value.L2_POLICY_NAME}"].id 

  # Spanning Treee Interface Policy:
  relation_infra_rs_stp_if_pol    = aci_spanning_tree_interface_policy.localAciSpanningTreeInterfacePolicyIteration["${each.value.STP_POLICY_NAME}"].id 

  # CDP Neighbors Interface Policy:
  relation_infra_rs_cdp_if_pol    = aci_cdp_interface_policy.localAciCdpInterfacePolicyIteration["${each.value.CDP_POLICY_NAME}"].id 

  # Miscabling Procotol Interface Policy:
  relation_infra_rs_mcp_if_pol    = aci_miscabling_protocol_interface_policy.localAciMiscablingProtocolInterfacePolicy["${each.value.MCP_POLICY_NAME}"].id 

  # LLDP Interface Policy:
  relation_infra_rs_lldp_if_pol   = aci_lldp_interface_policy.localAciLldpInterfacePolicyIteration["${each.value.LLDP_POLICY_NAME}"].id 

  lifecycle {
    ignore_changes = [
      relation_infra_rs_span_v_src_grp,
      relation_infra_rs_stormctrl_if_pol,
      relation_infra_rs_macsec_if_pol,
      relation_infra_rs_qos_dpp_if_pol,
      relation_infra_rs_h_if_pol,
      relation_infra_rs_netflow_monitor_pol,
      relation_infra_rs_l2_port_auth_pol,
      relation_infra_rs_l2_port_security_pol,
      relation_infra_rs_copp_if_pol,
      relation_infra_rs_span_v_dest_grp,
      relation_infra_rs_qos_pfc_if_pol,
      relation_infra_rs_qos_sd_if_pol,
      relation_infra_rs_mon_if_infra_pol,
      relation_infra_rs_fc_if_pol,
      relation_infra_rs_qos_ingress_dpp_if_pol,
      relation_infra_rs_qos_egress_dpp_if_pol,
      relation_infra_rs_l2_inst_pol
    ]
  } 

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/leaf_access_bundle_policy_group
# resource index key is "${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"
resource "aci_leaf_access_bundle_policy_group" "localAciLeafAccessBundlePolicyGroupIterationExternal" {
  for_each                        = local.FilterlocalAciLeafAccessBundlePolicyGroupIterationExternal

  name                            = lower(each.value.BOND_TYPE) == "vpc" ? join("_",["VPC", "L3", each.value.TENANT_NAME, each.value.ENDPOINT_NAME, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"]) : join("_",["PC", "L3", each.value.TENANT_NAME, each.value.ENDPOINT_NAME, each.value.ENDPOINT_INTERFACE_TYPE, "INT_POL_GRP"])
  annotation                      = "orchestrator:terraform"
  description                     = join(" ",[each.value.ENDPOINT_NAME, each.value.ENDPOINT_MAKE, each.value.ENDPOINT_MODEL, each.value.ENDPOINT_OS, each.value.ENDPOINT_INTERFACE_TYPE ])
  lag_t                           = lower(each.value.BOND_TYPE) == "vpc" ? "node" : "link"

  #Attachable Access Entity Profile:
  relation_infra_rs_att_ent_p     = lower(each.value.TENANT_NAME) != "global" ? aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationExternal["${each.value.TENANT_NAME}"].id : aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationExternal.id
  
  # LACP Policy:
  relation_infra_rs_lacp_pol      = aci_lacp_policy.localAciLacpActivePolicyIteration["${each.value.LACP_POLICY_NAME}"].id 

  # L2 Interface Policy:
  relation_infra_rs_l2_if_pol     = aci_l2_interface_policy.localAciL2InterfacePolicyIteration["${each.value.L2_POLICY_NAME}"].id 

  # Spanning Treee Interface Policy:
  relation_infra_rs_stp_if_pol    = aci_spanning_tree_interface_policy.localAciSpanningTreeInterfacePolicyIteration["${each.value.STP_POLICY_NAME}"].id 

  # CDP Neighbors Interface Policy:
  relation_infra_rs_cdp_if_pol    = aci_cdp_interface_policy.localAciCdpInterfacePolicyIteration["${each.value.CDP_POLICY_NAME}"].id 

  # Miscabling Procotol Interface Policy:
  relation_infra_rs_mcp_if_pol    = aci_miscabling_protocol_interface_policy.localAciMiscablingProtocolInterfacePolicy["${each.value.MCP_POLICY_NAME}"].id 

  # LLDP Interface Policy:
  relation_infra_rs_lldp_if_pol   = aci_lldp_interface_policy.localAciLldpInterfacePolicyIteration["${each.value.LLDP_POLICY_NAME}"].id 

  lifecycle {
    ignore_changes = [
      relation_infra_rs_span_v_src_grp,
      relation_infra_rs_stormctrl_if_pol,
      relation_infra_rs_macsec_if_pol,
      relation_infra_rs_qos_dpp_if_pol,
      relation_infra_rs_h_if_pol,
      relation_infra_rs_netflow_monitor_pol,
      relation_infra_rs_l2_port_auth_pol,
      relation_infra_rs_l2_port_security_pol,
      relation_infra_rs_copp_if_pol,
      relation_infra_rs_span_v_dest_grp,
      relation_infra_rs_qos_pfc_if_pol,
      relation_infra_rs_qos_sd_if_pol,
      relation_infra_rs_mon_if_infra_pol,
      relation_infra_rs_fc_if_pol,
      relation_infra_rs_qos_ingress_dpp_if_pol,
      relation_infra_rs_qos_egress_dpp_if_pol,
      relation_infra_rs_l2_inst_pol
    ]
  } 

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_port_selector
# resource index key is "${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"
resource "aci_access_port_selector" "localAciAccessPortSelectorIterationPhysical" {
  for_each                        = local.FilterlocalAciAccessPortSelectorIterationPhysical
  
  leaf_interface_profile_dn       = aci_leaf_interface_profile.localAciLeafInterfaceProfileIteration["${each.value.NODE_ID}"].id
  name                            = join("_", ["Eth", each.value.NODE_SLOT, each.value.NODE_PORT])
  description                     = join("_", [each.value.ENDPOINT_NAME, each.value.ENDPOINT_SLOT, each.value.ENDPOINT_PORT])
  access_port_selector_type       = "range"
  annotation                      = "orchestrator:terraform"
  relation_infra_rs_acc_base_grp  = lower(each.value.BOND_ENABLED) == "false" ? aci_leaf_access_port_policy_group.localAciLeafAccessPortPolicyGroupPhysical["${each.value.TENANT_NAME}:${each.value.ENDPOINT_MAKE}:${each.value.ENDPOINT_MODEL}:${each.value.ENDPOINT_OS}:${each.value.ENDPOINT_INTERFACE_TYPE}"].id : aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical["${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].id
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_port_block
# resource index key is "${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"
resource "aci_access_port_block" "localAciAccessPortBlockIterationPhysical" {
  for_each                          = local.FilterlocalAciAccessPortSelectorIterationPhysical

  access_port_selector_dn           = aci_access_port_selector.localAciAccessPortSelectorIterationPhysical["${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"].id
  name                              = join("_", ["Eth", each.value.NODE_SLOT, each.value.NODE_PORT])
  description                       = join("_", [each.value.ENDPOINT_NAME, each.value.ENDPOINT_SLOT, each.value.ENDPOINT_PORT])
  annotation                        = "orchestrator:terraform"
  from_card                         = "${each.value.NODE_SLOT}"
  from_port                         = "${each.value.NODE_PORT}"
  to_card                           = "${each.value.NODE_SLOT}"
  to_port                           = "${each.value.NODE_PORT}"

  lifecycle {
    ignore_changes = [
      relation_infra_rs_acc_bndl_subgrp
    ]
  }   
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_port_selector
# resource index key is "${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"
resource "aci_access_port_selector" "localAciAccessPortSelectorIterationExternal" {
  for_each                        = local.FilterlocalAciAccessPortSelectorIterationExternal
  
  leaf_interface_profile_dn       = aci_leaf_interface_profile.localAciLeafInterfaceProfileIteration["${each.value.NODE_ID}"].id
  name                            = join("_", ["Eth", each.value.NODE_SLOT, each.value.NODE_PORT])
  description                     = join("_", [each.value.ENDPOINT_NAME, each.value.ENDPOINT_SLOT, each.value.ENDPOINT_PORT])
  access_port_selector_type       = "range" 
  annotation                      = "orchestrator:terraform"
  relation_infra_rs_acc_base_grp  = lower(each.value.BOND_ENABLED) == "false" ? aci_leaf_access_port_policy_group.localAciLeafAccessPortPolicyGroupExternal["${each.value.TENANT_NAME}:${each.value.ENDPOINT_MAKE}:${each.value.ENDPOINT_MODEL}:${each.value.ENDPOINT_OS}:${each.value.ENDPOINT_INTERFACE_TYPE}"].id : aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationExternal["${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].id
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/access_port_block
# resource index key is "${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"
resource "aci_access_port_block" "localAciAccessPortBlockIterationExternal" {
  for_each                          = local.FilterlocalAciAccessPortSelectorIterationExternal

  access_port_selector_dn           = aci_access_port_selector.localAciAccessPortSelectorIterationExternal["${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"].id
  name                              = join("_", ["Eth", each.value.NODE_SLOT, each.value.NODE_PORT])
  description                       = join("_", [each.value.ENDPOINT_NAME, each.value.ENDPOINT_SLOT, each.value.ENDPOINT_PORT])
  annotation                        = "orchestrator:terraform"
  from_card                         = "${each.value.NODE_SLOT}"
  from_port                         = "${each.value.NODE_PORT}"
  to_card                           = "${each.value.NODE_SLOT}"
  to_port                           = "${each.value.NODE_PORT}"

  lifecycle {
    ignore_changes = [
      relation_infra_rs_acc_bndl_subgrp
    ]
  }   
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/epg_to_static_path
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME }:${each.value.APPLICATION_NAME}:${each.value.DOT1Q_ENABLED}:${each.value.VLAN_ID}:${each.value.POD_ID}:${each.value.NODE_ID}:${each.value.NODE_SLOT}:${each.value.NODE_PORT}"
resource "aci_epg_to_static_path" "localAciEpgToStaticPathIterationNonbond" {
  for_each            = local.aci_epg_to_static_path_nonbond_rows

  application_epg_dn  = aci_application_epg.localAciApplicationEndpointGroupIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  tdn                 = "topology/pod-${each.value.POD_ID}/paths-${each.value.NODE_ID}/pathep-[eth${each.value.NODE_SLOT}/${each.value.NODE_PORT}]"
  annotation          = "orchestrator:terraform"
  encap               = "vlan-${each.value.VLAN_ID}"
  instr_imedcy        = "immediate"
  mode                = lower(each.value.DOT1Q_ENABLED) == "true" ? "regular" : "native"
  
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/epg_to_static_path
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME }:${each.value.APPLICATION_NAME}:${each.value.DOT1Q_ENABLED}:${each.value.VLAN_ID}:${each.value.POD_ID}:${each.value.NODE_ID}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE }"
resource "aci_epg_to_static_path" "localAciEpgToStaticPathIterationPortChannel" {
  for_each            = local.aci_epg_to_static_path_portchannel_rows


  application_epg_dn  = aci_application_epg.localAciApplicationEndpointGroupIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  tdn                 = lower(each.value.MULTI_TENANT) == "false" ? "topology/pod-${each.value.POD_ID}/protpaths-${each.value.NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical["${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]" : "topology/pod-${each.value.POD_ID}/protpaths-${each.value.NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical["GLOBAL:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]" 
  annotation          = "orchestrator:terraform"
  encap               = "vlan-${each.value.VLAN_ID}"
  instr_imedcy        = "immediate"
  mode                = lower(each.value.DOT1Q_ENABLED) == "true" ? "regular" : "native"    
   
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/epg_to_static_path
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME }:${each.value.APPLICATION_NAME}:${each.value.DOT1Q_ENABLED}:${each.value.VLAN_ID}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE }"
resource "aci_epg_to_static_path" "localAciEpgToStaticPathIterationVirtualPortChannel" {
  for_each            = local.aci_epg_to_static_path_virtualportchannel_rows


  application_epg_dn  = aci_application_epg.localAciApplicationEndpointGroupIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.APPLICATION_NAME}"].id
  tdn                 = lower(each.value.MULTI_TENANT) == "false" ? "topology/pod-${each.value.POD_ID}/protpaths-${each.value.ODD_NODE_ID}-${each.value.EVEN_NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical["${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]" : "topology/pod-${each.value.POD_ID}/protpaths-${each.value.ODD_NODE_ID}-${each.value.EVEN_NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical["GLOBAL:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]" 
  annotation          = "orchestrator:terraform"
  encap               = "vlan-${each.value.VLAN_ID}"
  instr_imedcy        = "immediate"
  mode                = lower(each.value.DOT1Q_ENABLED) == "true" ? "regular" : "native"    
   
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/logical_node_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"
resource "aci_logical_node_profile" "localAciLogicalNodeProfileIterationSviVpc" {
  for_each      = local.aci_logical_node_profile_rows
  
  l3_outside_dn = aci_l3_outside.localAciL3OutsideIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  description   = join(" ", ["Node Profile for", join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "as specified by Terraform CICD pipeline."])
  name          = join("_", [join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "NODE", "PROF"])
  annotation    = "orchestrator:terraform"
  target_dscp   = each.value.TARGET_DSCP

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/logical_node_to_fabric_node
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}"
resource "aci_logical_node_to_fabric_node" "localAciLogicalNodeToFabricNodeIterationSviVpcOddNode" {
  for_each                  = local.aci_logical_node_to_fabric_node_rows 

  logical_node_profile_dn   = aci_logical_node_profile.localAciLogicalNodeProfileIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"].id
  tdn                       = "topology/pod-${each.value.POD_ID}/node-${each.value.ODD_NODE_ID}"
  annotation                = "orchestrator:terraform"
  config_issues             = each.value.CONFIG_ISSUES
  rtr_id                    = "${each.value.ODD_NODE_RTR_ID}"
  rtr_id_loop_back          = each.value.RTR_ID_LOOP_BACK 
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/logical_node_to_fabric_node
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}"
resource "aci_logical_node_to_fabric_node" "localAciLogicalNodeToFabricNodeIterationSviVpcEvenNode" {
  for_each                  = local.aci_logical_node_to_fabric_node_rows 

  logical_node_profile_dn   = aci_logical_node_profile.localAciLogicalNodeProfileIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"].id
  tdn                       = "topology/pod-${each.value.POD_ID}/node-${each.value.EVEN_NODE_ID}"
  annotation                = "orchestrator:terraform"
  config_issues             = each.value.CONFIG_ISSUES
  rtr_id                    = "${each.value.EVEN_NODE_RTR_ID}"
  rtr_id_loop_back          = each.value.RTR_ID_LOOP_BACK 
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/data-sources/l3out_static_route
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}" 
resource "aci_l3out_static_route" "localAciL3OutStaticRouteIterationSviVpcOddNode" {
  for_each        = local.aci_l3out_static_route_rows

  fabric_node_dn  = aci_logical_node_to_fabric_node.localAciLogicalNodeToFabricNodeIterationSviVpcOddNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}"].id
  ip              = "${each.value.RT_NTWK_PFX}/${each.value.RT_NTWK_CIDR}"
  aggregate       = each.value.AGGREGATE
  annotation      = "orchestrator:terraform"
  pref            = each.value.ADMIN_DIST 
  rt_ctrl         = each.value.RT_CTRL
  description     = "created via Terraform CI/CD Pipeline"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/data-sources/l3out_static_route
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}" 
resource "aci_l3out_static_route" "localAciL3OutStaticRouteIterationSviVpcEvenNode" {
  for_each        = local.aci_l3out_static_route_rows

  fabric_node_dn  = aci_logical_node_to_fabric_node.localAciLogicalNodeToFabricNodeIterationSviVpcEvenNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}"].id
  ip              = "${each.value.RT_NTWK_PFX}/${each.value.RT_NTWK_CIDR}"
  aggregate       = each.value.AGGREGATE
  annotation      = "orchestrator:terraform"
  pref            = each.value.ADMIN_DIST 
  rt_ctrl         = each.value.RT_CTRL
  description     = "created via Terraform CI/CD Pipeline"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_static_route_next_hop
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}" 
resource "aci_l3out_static_route_next_hop" "localAciL3OutNodeProfFabEvenNodeDefRtNextHopNgfwIterationSviVpcOddNode" {
  for_each              = local.aci_l3out_static_route_rows

  static_route_dn       = aci_l3out_static_route.localAciL3OutStaticRouteIterationSviVpcOddNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}"].id
  nh_addr               = each.value.NEXT_HOP_IP
  annotation            = "orchestrator:terraform"
  pref                  = each.value.ADMIN_DIST
  nexthop_profile_type  = "prefix"
  description           = "created via Terraform CI/CD Pipeline"

  lifecycle {
    ignore_changes = [
      relation_ip_rs_nexthop_route_track,
      relation_ip_rs_nh_track_member
    ]
  }

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_static_route_next_hop
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}" 
resource "aci_l3out_static_route_next_hop" "localAciL3OutNodeProfFabEvenNodeDefRtNextHopNgfwIterationSviVpcEvenNode" {
  for_each              = local.aci_l3out_static_route_rows

  static_route_dn       = aci_l3out_static_route.localAciL3OutStaticRouteIterationSviVpcEvenNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.POD_ID}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_RTR_ID}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_RTR_ID}:${each.value.RT_NTWK_PFX}:${each.value.RT_NTWK_CIDR}:${each.value.NEXT_HOP_IP}"].id
  nh_addr               = each.value.NEXT_HOP_IP
  annotation            = "orchestrator:terraform"
  pref                  = each.value.ADMIN_DIST
  nexthop_profile_type  = "prefix"
  description           = "created via Terraform CI/CD Pipeline"

  lifecycle {
    ignore_changes = [
      relation_ip_rs_nexthop_route_track,
      relation_ip_rs_nh_track_member
    ]
  }

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/logical_interface_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"
resource "aci_logical_interface_profile" "localAciLogicalInterfaceProfileIterationSviVpc" {
  for_each                = local.aci_logical_interface_profile_rows
  
  logical_node_profile_dn = aci_logical_node_profile.localAciLogicalNodeProfileIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"].id
  description             = join(" ", ["Interface Profile for", join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "as specified by Terraform CICD pipeline."])
  name                    = join("_", [join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "NODE", "INT", "PROF"])
  annotation              = "orchestrator:terraform"
  prio                    = each.value.PRIO

  lifecycle {
    ignore_changes = [
      relation_l3ext_rs_pim_ip_if_pol,
      relation_l3ext_rs_pim_ipv6_if_pol,
      relation_l3ext_rs_igmp_if_pol,
      relation_l3ext_rs_l_if_p_to_netflow_monitor_pol,
      relation_l3ext_rs_egress_qos_dpp_pol,
      relation_l3ext_rs_ingress_qos_dpp_pol,
      relation_l3ext_rs_l_if_p_cust_qos_pol,
      relation_l3ext_rs_nd_if_pol 
    ]
  }  
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_path_attachment
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"
resource "aci_l3out_path_attachment" "localAciL3OutPathAttachmentIterationSviVpc" {
  for_each                      = local.aci_l3out_path_attachment_rows

  logical_interface_profile_dn  = aci_logical_interface_profile.localAciLogicalInterfaceProfileIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.EVEN_NODE_ID}"].id
  target_dn                     = lower(each.value.MULTI_TENANT) == "false" ? "topology/pod-${each.value.POD_ID}/protpaths-${each.value.ODD_NODE_ID}-${each.value.EVEN_NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationExternal["${each.value.TENANT_NAME}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]" : "topology/pod-${each.value.POD_ID}/protpaths-${each.value.ODD_NODE_ID}-${each.value.EVEN_NODE_ID}/pathep-[${aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationExternal["GLOBAL:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}"].name}]"
  if_inst_t                     = "ext-svi"
  description                   = join(" ", ["Interface Configuration for", join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "as specified by Terraform CICD pipeline."])
  annotation                    = "orchestrator:terraform"
  autostate                     = each.value.AUTO_STATE
  encap                         = "vlan-${each.value.VLAN_ID}"
  encap_scope                   = each.value.ENCAP_SCOPE
  ipv6_dad                      = each.value.IPV6_DAD
  ll_addr                       = each.value.LL_ADDR
  mac                           = each.value.MAC_ADDR 
  mode                          = lower(each.value.DOT1Q_ENABLED) == "true" ? "regular" : "native"
  mtu                           = each.value.MTU 
  target_dscp                   = each.value.TARGET_DCSP

  lifecycle {
    ignore_changes = [
      addr
    ]
  }    
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_vpc_member
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}" 
resource "aci_l3out_vpc_member" "localAciL3OutVpcMemberIterationSviVpcOddNode" {
  for_each      = local.aci_l3out_path_attachment_rows
  
  leaf_port_dn  = aci_l3out_path_attachment.localAciL3OutPathAttachmentIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"].id
  side          = "A"
  addr          = "${each.value.ODD_NODE_IP}/${each.value.NETWORK_CIDR}"
  annotation    = "orchestrator:terraform"
  ipv6_dad      = each.value.IPV6_DAD
  ll_addr       = each.value.LL_ADDR
  description   = join(" ", ["Interface Configuration for", each.value.ODD_NODE_ID, "as specified by Terraform CICD pipeline."])
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_vpc_member
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}" 
resource "aci_l3out_vpc_member" "localAciL3OutVpcMemberIterationSviVpcEvenNode" {
  for_each      = local.aci_l3out_path_attachment_rows
  
  leaf_port_dn  = aci_l3out_path_attachment.localAciL3OutPathAttachmentIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"].id
  side          = "B"
  addr          = "${each.value.EVEN_NODE_IP}/${each.value.NETWORK_CIDR}"
  annotation    = "orchestrator:terraform"
  ipv6_dad      = each.value.IPV6_DAD
  ll_addr       = each.value.LL_ADDR
  description   = join(" ", ["Interface Configuration for", each.value.EVEN_NODE_ID, "as specified by Terraform CICD pipeline."])
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_path_attachment_secondary_ip
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}" 
resource "aci_l3out_path_attachment_secondary_ip" "localAciL3OutPathAttachmentSecondaryIpIterationSviVpcOddNode" {
  for_each                  = local.aci_l3out_path_attachment_rows
  
  l3out_path_attachment_dn  = aci_l3out_vpc_member.localAciL3OutVpcMemberIterationSviVpcOddNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"].id
  addr                      = "${each.value.SHARED_IP}/${each.value.NETWORK_CIDR}"
  annotation                = "orchestrator:terraform"
  description               = join(" ", ["Interface Configuration for", join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "as specified by Terraform CICD pipeline."])
  ipv6_dad                  = each.value.IPV6_DAD
  dhcp_relay                = each.value.DHCP_RELAY
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_path_attachment_secondary_ip
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}" 
resource "aci_l3out_path_attachment_secondary_ip" "localAciL3OutPathAttachmentSecondaryIpIterationSviVpcEvenNode" {
  for_each                  = local.aci_l3out_path_attachment_rows
  
  l3out_path_attachment_dn  = aci_l3out_vpc_member.localAciL3OutVpcMemberIterationSviVpcEvenNode["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"].id
  addr                      = "${each.value.SHARED_IP}/${each.value.NETWORK_CIDR}"
  annotation                = "orchestrator:terraform"
  description               = join(" ", ["Interface Configuration for", join("-", [each.value.ODD_NODE_ID, each.value.EVEN_NODE_ID]), "as specified by Terraform CICD pipeline."])
  ipv6_dad                  = each.value.IPV6_DAD
  dhcp_relay                = each.value.DHCP_RELAY
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_timers
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}"
resource "aci_bgp_timers" "localAciBgpTimersIteration" {
  for_each     = local.aci_bgp_timers_rows

  tenant_dn    = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  description  = "created via Terraform CI/CD Pipeline"
  name         = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, "BGP_TMR"])
  annotation   = "orchestrator:terraform"
  gr_ctrl      = each.value.GRACEFUL_CONTROL
  hold_intvl   = each.value.HOLD_INTERVAL
  ka_intvl     = each.value.KEEPALIVE_INTERVAL
  max_as_limit = each.value.MAX_AS_LIMIT
  stale_intvl  = each.value.STALE_INTERVAL
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/rest
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}"
resource "aci_rest" "localAciBgpTimersToVrfAssociationIteration" {
  for_each     = local.aci_bgp_timers_rows

  path       = "/api/node/mo/uni/tn-${each.value.TENANT_NAME}/ctx-${each.value.VRF_NAME}/rsbgpCtxPol.json"
  payload = <<EOF
{
  "fvRsBgpCtxPol": {
    "attributes": {
      "tnBgpCtxPolName": "${each.value.TENANT_NAME}_${each.value.VRF_NAME}_BGP_TMR"
    },
    "children": []
  }
}
  EOF
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_address_family_context
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_bgp_address_family_context" "localAciBgpAddressFamilyContextIteration" {
  for_each      = local.aci_bgp_address_family_context_rows

  tenant_dn     = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name          = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "PG_BGP_AFC"])
  description   = "created via Terraform CI/CD Pipeline"
  annotation    = "orchestrator:terraform"
  ctrl          = each.value.CONTROL_STATE
  e_dist        = each.value.EBGP_ADMIN_DISTANCE
  i_dist        = each.value.IBGP_ADMIN_DISTANCE
  local_dist    = each.value.LOCAL_ADMIN_DISTANCE
  max_ecmp      = each.value.MAX_EBGP_ECMP
  max_ecmp_ibgp = each.value.MAX_IBGP_ECMP
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/vrf_to_bgp_address_family_context
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_vrf_to_bgp_address_family_context" "localAciVrfToBgpAddresFamilyContextIteration" {
  for_each                      = local.aci_bgp_address_family_context_rows
  vrf_dn                        = aci_vrf.localAciVrfIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}" ].id
  bgp_address_family_context_dn = aci_bgp_address_family_context.localAciBgpAddressFamilyContextIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"].id
  address_family                = "ipv4-ucast"
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_route_summarization
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_bgp_route_summarization" "localAciBgpRouteSummarizationIteration" {
  for_each              = local.aci_bgp_route_summarization_rows

  tenant_dn             = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name                  = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "BGP_RT_POL"])
  description           = "created via Terraform CI/CD Pipeline"
  attrmap               = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "ATTR_MAP"])
  ctrl                  = each.value.CONTROL_STATE
  address_type_controls = each.value.ADDRESS_TYPE_CONTROLS
}

/*
# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_best_path_policy
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_bgp_best_path_policy" "localAciBgpBestPathPolicyIteration" {
  for_each    = local.aci_bgp_best_path_policy_rows 

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name        = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "BGP_PATH_POL"])
  annotation  = "orchestrator:terraform"
  description = "created via Terraform CI/CD Pipeline"
  ctrl        = "${each.value.CONTROL_STATE}"
}
*/

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_peer_prefix
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_bgp_peer_prefix" "localAciBgpPeerPrefixIteration" {
  for_each     = local.aci_bgp_peer_prefix_rows 

  tenant_dn    = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name         = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "BGP_PEER_PFX"])
  description  = "created via Terraform CI/CD Pipeline"
  action       = each.value.ACTION
  annotation   = "orchestrator:terraform"
  max_pfx      = each.value.MAX_PREFIX
  restart_time = each.value.RESTART_TIME
  thresh       = each.value.THRESHOLD
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_route_control_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_bgp_route_control_profile" "localAciBgpRouteControlProfileIterations" {
  for_each                   = local.aci_bgp_route_control_profile_rows
  
  parent_dn                  = aci_l3_outside.localAciL3OutsideIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  name                       = join("_",[each.value.TENANT_NAME, each.value.VRF_NAME, each.value.PEER_GROUP, "BGP_RT_CTRL_PROF"])
  annotation                 = "orchestrator:terraform"
  description                = "created via Terraform CI/CD Pipeline"
  route_control_profile_type = each.value.ROUTE_CONTROL_PROFILE_TYPE
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/l3out_bgp_external_policy
# resource index key is "${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"
resource "aci_l3out_bgp_external_policy" "localAciL3OutBgpExternalPolicyIteration" {
  for_each      = local.FilterlocalAciL3OutBgpExternalPolicyIteration 

  l3_outside_dn = aci_l3_outside.localAciL3OutsideIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  annotation    = "orchestrator:terraform"
  description   = "created via Terraform CI/CD Pipeline"
}

# https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.AS_NUMBER}:${each.value.PEER_IP}"
resource "random_string" "localAciBgpPeerConnectivityProfileIterationsPassword" {
  for_each    = local.aci_bgp_peer_connectivity_profile_rows

  length      = 16
  special     = false
  lower       = true
  min_lower   = 1 
  upper       = true
  min_upper   = 1 
  numeric     = true
  min_numeric = 1

  lifecycle{
    ignore_changes = all
  } 
}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/bgp_peer_connectivity_profile
# resource index key is "${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.AS_NUMBER}:${each.value.PEER_IP}"
resource "aci_bgp_peer_connectivity_profile" "localAciBgpPeerConnectivityProfileIterations" {
  for_each                      = local.aci_bgp_peer_connectivity_profile_rows

  parent_dn                     = aci_l3out_path_attachment.localAciL3OutPathAttachmentIterationSviVpc["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}:${each.value.ODD_NODE_ID}:${each.value.ODD_NODE_IP}:${each.value.EVEN_NODE_ID}:${each.value.EVEN_NODE_IP}:${each.value.SHARED_IP}:${each.value.ENDPOINT_NAME}:${each.value.ENDPOINT_INTERFACE_TYPE}:${each.value.VLAN_ID}"].id
  addr                          = each.value.PEER_IP
  description                   = "created via Terraform CI/CD Pipeline"
  addr_t_ctrl                   = lower(each.value.PEER_ADDRESS_TYPE) != "null" ? [each.value.PEER_ADDRESS_TYPE] : []
  allowed_self_as_cnt           = lower(each.value.ALLOWED_LOCAL_AS_COUNT) != "null" ? each.value.ALLOWED_LOCAL_AS_COUNT : null
  annotation                    = "orchestrator:terraform"
  ctrl                          = lower(each.value.BGP_CONTROLS) != "null" ? [each.value.BGP_CONTROLS] : []
  password                      = random_string.localAciBgpPeerConnectivityProfileIterationsPassword[each.key].result
  peer_ctrl                     = lower(each.value.PEER_CONTROLS) != "null" ? [each.value.PEER_CONTROLS] : []
  private_a_sctrl               = lower(each.value.PRIVATE_AS_ACTION) != "null" && each.value.PRIVATE_AS_ACTION != "null" ? [each.value.PRIVATE_AS_ACTION] : []
  ttl                           = lower(each.value.TTL) != "null" ? each.value.TTL : null
  weight                        = lower(each.value.WEIGHT) != "null" ? each.value.WEIGHT : null
  as_number                     = lower(each.value.AS_NUMBER) != "null" ? each.value.AS_NUMBER : null
  local_asn                     = lower(each.value.LOCAL_ASN) != "null" ? each.value.LOCAL_ASN : null
  local_asn_propagate           = lower(each.value.LOCAL_ASN_PROP) != "null" ? each.value.LOCAL_ASN_PROP : null
  admin_state                   = lower(each.value.ADMIN_STATE) != "null" ? each.value.ADMIN_STATE : null

  relation_bgp_rs_peer_pfx_pol  = aci_bgp_peer_prefix.localAciBgpPeerPrefixIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}:${each.value.PEER_GROUP}"].id
}



/*
*/