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

  relation_fv_rs_ctx = aci_vrf.localAciVrfIteration["${each.value.TENANT_NAME}:${each.value.VRF_NAME}"].id

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
resource "aci_attachable_access_entity_profile" "localAciAttachableEntityAccessProfileIteration" {
  for_each                = local.aci_attachable_access_entity_profile_rows

  name                    = join("_", [each.value.TENANT_NAME,"PHYS", "AAEP"])
  description             = join(" ", [each.value.TENANT_NAME, " AAEP allows access to the associated tenant in a NCI Mode via Terraform from a CI/CD Pipeline."])
  annotation              = "orchestrator:terraform"
  relation_infra_rs_dom_p = [aci_physical_domain.localAciPhysicalDomainIteration["${each.value.TENANT_NAME}"].id]

}

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/attachable_access_entity_profile
# resource index key is NULL
resource "aci_attachable_access_entity_profile" "localAciGlobalAttachableEntityAccessProfileIteration" {
  name                    = "GLOBAL_PHYS_AAEP"
  description             = "Global AAEP for all tenants"
  annotation              = "orchestrator:terraform"

  # Attached to all physical domains created by terraform
  relation_infra_rs_dom_p = values(aci_physical_domain.localAciPhysicalDomainIteration)[*].id

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
resource "aci_l3_ext_subnet" "localAciL3ExtSubnetIteration" {
  for_each                              = local.aci_l3_ext_subnet_rows
  
  external_network_instance_profile_dn  = aci_external_network_instance_profile.localAciExternalNetworkInstanceProfileIteration["${each.value.TENANT_NAME}:${each.value.ZONE_NAME}:${each.value.VRF_NAME}:${each.value.NEXT_HOP_TYPE}"].id
  description                           = "Allowed"
  ip                                    = "${each.value.ALLOWED_PREFIX}/${each.value.ALLOWED_CIDR}"
  annotation                            = "orchestrator:terraform" 
  scope                                 = ["${each.value.SCOPE}"]

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

# https://registry.terraform.io/providers/CiscoDevNet/aci/2.13.2/docs/resources/filter
# resource index key is "${each.value.TENANT_NAME}"
resource "aci_filter" "localAciContractFilterIterationIPAny" {
  for_each    = local.aci_tenant_rows

  tenant_dn   = aci_tenant.localAciTenantIteration["${each.value.TENANT_NAME}"].id
  name        = join("_",[each.value.TENANT_NAME, "IP", "ANY", "FILT"])
  description = "Filter for Any IP traffic"
  annotation  = "orchestrator:terraform" 
}

/*

*/