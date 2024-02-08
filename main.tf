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