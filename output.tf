output "automation_account_name" {
  value = module.automation_account.name
}

output "resourcegroup_name" {
  value = module.resourcegroup.name
}


output "user_assigned_identity_name" {
  value = module.auto_m_id_name.result
}
