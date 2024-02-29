output "localAciBgpPeerConnectivityProfileIterationsPassword" {
  value = { for key, pw in random_password.localAciBgpPeerConnectivityProfileIterationsPassword : key => pw.result }
  description = "Mapping of BGP peer keys to their generated passwords."
  sensitive = false
}
