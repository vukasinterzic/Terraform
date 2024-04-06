#this file contains outputs of KeyVault module

output "kv_id_out" {
  value = azurerm_key_vault.kv1.id
}

output "kv_name_out" {
  value = azurerm_key_vault.kv1.name
}

output "secret_user_out" {
    value = azurerm_key_vault_secret.xyz-user.name
}

output "secret_password_out" {
    value = azurerm_key_vault_secret.xyz-password.name
}