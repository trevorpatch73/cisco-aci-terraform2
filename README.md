# cisco-aci-terraform2

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7.2 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | 2.13.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | 2.13.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aci_access_port_block.localAciAccessPortBlockIterationExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/access_port_block) | resource |
| [aci_access_port_block.localAciAccessPortBlockIterationPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/access_port_block) | resource |
| [aci_access_port_selector.localAciAccessPortSelectorIterationExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/access_port_selector) | resource |
| [aci_access_port_selector.localAciAccessPortSelectorIterationPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/access_port_selector) | resource |
| [aci_access_switch_policy_group.localAciAccessSwitchPolicyGroupIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/access_switch_policy_group) | resource |
| [aci_application_epg.localAciApplicationEndpointGroupIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/application_epg) | resource |
| [aci_application_profile.localAciApplicationProfileIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/application_profile) | resource |
| [aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/attachable_access_entity_profile) | resource |
| [aci_attachable_access_entity_profile.localAciAttachableEntityAccessProfileIterationPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/attachable_access_entity_profile) | resource |
| [aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/attachable_access_entity_profile) | resource |
| [aci_attachable_access_entity_profile.localAciGlobalAttachableEntityAccessProfileIterationPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/attachable_access_entity_profile) | resource |
| [aci_bgp_address_family_context.localAciBgpAddressFamilyContextIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_address_family_context) | resource |
| [aci_bgp_peer_connectivity_profile.localAciBgpPeerConnectivityProfileIterations](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_peer_connectivity_profile) | resource |
| [aci_bgp_peer_prefix.localAciBgpPeerPrefixIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_peer_prefix) | resource |
| [aci_bgp_route_control_profile.localAciBgpRouteControlProfileIterations](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_route_control_profile) | resource |
| [aci_bgp_route_summarization.localAciBgpRouteSummarizationIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_route_summarization) | resource |
| [aci_bgp_timers.localAciBgpTimersIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bgp_timers) | resource |
| [aci_bridge_domain.localAciBridgeDomainIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/bridge_domain) | resource |
| [aci_cdp_interface_policy.localAciCdpInterfacePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/cdp_interface_policy) | resource |
| [aci_contract.localAciContractIterationEpgInbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract) | resource |
| [aci_contract.localAciContractIterationEpgOutbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract) | resource |
| [aci_contract_subject.localAciContractSubjectIterationEpgInbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject) | resource |
| [aci_contract_subject.localAciContractSubjectIterationEpgOutbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject) | resource |
| [aci_contract_subject.localAciNodeMgmtOobCtrSubj](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject) | resource |
| [aci_contract_subject_filter.localAciContractSubjectFilterIterationEpgInbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject_filter) | resource |
| [aci_contract_subject_filter.localAciContractSubjectFilterIterationEpgOutbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject_filter) | resource |
| [aci_contract_subject_filter.localAciNodeMgmtOobCtrSubjFiltAssoc](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/contract_subject_filter) | resource |
| [aci_epg_to_contract.localAciEpgToContractIterationInbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_contract) | resource |
| [aci_epg_to_contract.localAciEpgToContractIterationOutbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_contract) | resource |
| [aci_epg_to_contract.localAciSrcEpgConsumeDstEpgContractIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_contract) | resource |
| [aci_epg_to_domain.localAciEpgToPhysicalDomainIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_domain) | resource |
| [aci_epg_to_static_path.localAciEpgToStaticPathIterationNonbond](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_static_path) | resource |
| [aci_epg_to_static_path.localAciEpgToStaticPathIterationPortChannel](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_static_path) | resource |
| [aci_epg_to_static_path.localAciEpgToStaticPathIterationVirtualPortChannel](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/epg_to_static_path) | resource |
| [aci_external_network_instance_profile.localAciExternalNetworkInstanceProfileIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/external_network_instance_profile) | resource |
| [aci_fabric_node_member.localAciFabricNodeMemberIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/fabric_node_member) | resource |
| [aci_filter.localAciFiltersIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/filter) | resource |
| [aci_filter.localAciNodeMgmtOobCtrSubjFilt](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/filter) | resource |
| [aci_filter_entry.localAciNodeMgmtOobCtrSubjFiltArpIterations](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/filter_entry) | resource |
| [aci_filter_entry.localAciNodeMgmtOobCtrSubjFiltProtocolTcpIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/filter_entry) | resource |
| [aci_filter_entry.localAciNodeMgmtOobCtrSubjFiltProtocolUdpIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/filter_entry) | resource |
| [aci_l2_interface_policy.localAciL2InterfacePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l2_interface_policy) | resource |
| [aci_l3_domain_profile.localAciExternalDomainIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3_domain_profile) | resource |
| [aci_l3_ext_subnet.localAciL3ExtSubnetIterationExport](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3_ext_subnet) | resource |
| [aci_l3_ext_subnet.localAciL3ExtSubnetIterationImport](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3_ext_subnet) | resource |
| [aci_l3_outside.localAciL3OutsideIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3_outside) | resource |
| [aci_l3out_bgp_external_policy.localAciL3OutBgpExternalPolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_bgp_external_policy) | resource |
| [aci_l3out_path_attachment.localAciL3OutPathAttachmentIterationSviVpc](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_path_attachment) | resource |
| [aci_l3out_path_attachment_secondary_ip.localAciL3OutPathAttachmentSecondaryIpIterationSviVpcEvenNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_path_attachment_secondary_ip) | resource |
| [aci_l3out_path_attachment_secondary_ip.localAciL3OutPathAttachmentSecondaryIpIterationSviVpcOddNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_path_attachment_secondary_ip) | resource |
| [aci_l3out_static_route.localAciL3OutStaticRouteIterationSviVpcEvenNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_static_route) | resource |
| [aci_l3out_static_route.localAciL3OutStaticRouteIterationSviVpcOddNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_static_route) | resource |
| [aci_l3out_static_route_next_hop.localAciL3OutNodeProfFabEvenNodeDefRtNextHopNgfwIterationSviVpcEvenNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_static_route_next_hop) | resource |
| [aci_l3out_static_route_next_hop.localAciL3OutNodeProfFabEvenNodeDefRtNextHopNgfwIterationSviVpcOddNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_static_route_next_hop) | resource |
| [aci_l3out_vpc_member.localAciL3OutVpcMemberIterationSviVpcEvenNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_vpc_member) | resource |
| [aci_l3out_vpc_member.localAciL3OutVpcMemberIterationSviVpcOddNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/l3out_vpc_member) | resource |
| [aci_lacp_policy.localAciLacpActivePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/lacp_policy) | resource |
| [aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_access_bundle_policy_group) | resource |
| [aci_leaf_access_bundle_policy_group.localAciLeafAccessBundlePolicyGroupIterationPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_access_bundle_policy_group) | resource |
| [aci_leaf_access_port_policy_group.localAciLeafAccessPortPolicyGroupExternal](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_access_port_policy_group) | resource |
| [aci_leaf_access_port_policy_group.localAciLeafAccessPortPolicyGroupPhysical](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_access_port_policy_group) | resource |
| [aci_leaf_interface_profile.localAciLeafInterfaceProfileIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_interface_profile) | resource |
| [aci_leaf_profile.localAciLeafProfileIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/leaf_profile) | resource |
| [aci_lldp_interface_policy.localAciLldpInterfacePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/lldp_interface_policy) | resource |
| [aci_logical_interface_profile.localAciLogicalInterfaceProfileIterationSviVpc](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/logical_interface_profile) | resource |
| [aci_logical_node_profile.localAciLogicalNodeProfileIterationSviVpc](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/logical_node_profile) | resource |
| [aci_logical_node_to_fabric_node.localAciLogicalNodeToFabricNodeIterationSviVpcEvenNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/logical_node_to_fabric_node) | resource |
| [aci_logical_node_to_fabric_node.localAciLogicalNodeToFabricNodeIterationSviVpcOddNode](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/logical_node_to_fabric_node) | resource |
| [aci_maintenance_group_node.localAciMaintenanceGroupNodeIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/maintenance_group_node) | resource |
| [aci_maintenance_policy.localAciMaintenanceGroupPolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/maintenance_policy) | resource |
| [aci_miscabling_protocol_interface_policy.localAciMiscablingProtocolInterfacePolicy](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/miscabling_protocol_interface_policy) | resource |
| [aci_node_mgmt_epg.localAciNodeMgmtEpg](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/node_mgmt_epg) | resource |
| [aci_physical_domain.localAciPhysicalDomainIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/physical_domain) | resource |
| [aci_pod_maintenance_group.localAciPodMaintenanceGroupIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/pod_maintenance_group) | resource |
| [aci_ranges.localAciExternalDomainVlanPoolRangesIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/ranges) | resource |
| [aci_ranges.localAciPhysicalDomainVlanPoolRangesIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/ranges) | resource |
| [aci_rest.localAciBgpTimersToVrfAssociationIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest) | resource |
| [aci_rest.localAciRestLeafProfilePolicyAttachmentIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest) | resource |
| [aci_rest_managed.localAciExternalEpgToContractIterationInbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest_managed) | resource |
| [aci_rest_managed.localAciExternalEpgToContractIterationOutbound](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest_managed) | resource |
| [aci_rest_managed.localAciLeafInterfaceLinkLevelPolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest_managed) | resource |
| [aci_rest_managed.localAciMaintenanceGroupSchedulePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest_managed) | resource |
| [aci_rest_managed.localAciNodeMgmtOobCtr](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/rest_managed) | resource |
| [aci_spanning_tree_interface_policy.localAciSpanningTreeInterfacePolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/spanning_tree_interface_policy) | resource |
| [aci_static_node_mgmt_address.localAciStaticNodeMgmtAddressIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/static_node_mgmt_address) | resource |
| [aci_subnet.localAciSubnet](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/subnet) | resource |
| [aci_tenant.localAciTenantIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/tenant) | resource |
| [aci_vlan_pool.localAciExternalDomainVlanPoolIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vlan_pool) | resource |
| [aci_vlan_pool.localAciPhysicalDomainVlanPoolIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vlan_pool) | resource |
| [aci_vpc_domain_policy.localAciVpcDomainPolicyIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vpc_domain_policy) | resource |
| [aci_vpc_explicit_protection_group.localAciVpcExplictProtectionGroupIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vpc_explicit_protection_group) | resource |
| [aci_vrf.localAciVrfIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vrf) | resource |
| [aci_vrf_snmp_context.localAciVrfSnmpContextIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vrf_snmp_context) | resource |
| [aci_vrf_snmp_context_community.localAciVrfSnmpContectCommunityIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vrf_snmp_context_community) | resource |
| [aci_vrf_to_bgp_address_family_context.localAciVrfToBgpAddresFamilyContextIteration](https://registry.terraform.io/providers/ciscodevnet/aci/2.13.2/docs/resources/vrf_to_bgp_address_family_context) | resource |
| [random_string.localAciBgpPeerConnectivityProfileIterationsPassword](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CISCO_ACI_APIC_IP_ADDRESS"></a> [CISCO\_ACI\_APIC\_IP\_ADDRESS](#input\_CISCO\_ACI\_APIC\_IP\_ADDRESS) | MAPS TO ENVIRONMENTAL VARIABLE TF\_VAR\_CISCO\_ACI\_APIC\_IP\_ADDRESS | `string` | n/a | yes |
| <a name="input_CISCO_ACI_TERRAFORM_PASSWORD"></a> [CISCO\_ACI\_TERRAFORM\_PASSWORD](#input\_CISCO\_ACI\_TERRAFORM\_PASSWORD) | MAPS TO ENVIRONMENTAL VARIABLE TF\_VAR\_CISCO\_ACI\_TERRAFORM\_PASSWORD | `string` | n/a | yes |
| <a name="input_CISCO_ACI_TERRAFORM_USERNAME"></a> [CISCO\_ACI\_TERRAFORM\_USERNAME](#input\_CISCO\_ACI\_TERRAFORM\_USERNAME) | MAPS TO ENVIRONMENTAL VARIABLE TF\_VAR\_CISCO\_ACI\_TERRAFORM\_USERNAME | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_localAciBgpPeerConnectivityProfileIterationsPassword"></a> [localAciBgpPeerConnectivityProfileIterationsPassword](#output\_localAciBgpPeerConnectivityProfileIterationsPassword) | Mapping of BGP peer keys to their generated passwords. |
<!-- END_TF_DOCS -->