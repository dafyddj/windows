variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
}

variable "iso_url" {
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "virtualbox-vm" "guestadd" {
  attach_snapshot         = "installed"
  boot_wait               = "-1s"
  communicator            = "winrm"
  force_delete_snapshot   = true
  guest_additions_mode    = "attach"
  headless                = "${var.headless}"
  keep_registered         = true
  shutdown_command        = "${var.shutdown_command}"
  skip_export             = true
  target_snapshot         = "guestadded"
  virtualbox_version_file = ""
  vm_name                 = "${var.vm_name}"
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  sources = ["source.virtualbox-vm.guestadd"]

  provisioner "powershell" {
    inline = [<<-EOF
      $dl = (Get-Volume | ? FileSystemLabel -Like Vbox*).DriveLetter
      Write-Host "Installing Oracle TrustedPublisher certs..."
      Start-Process -Wait -WorkingDirectory $${dl}:\cert VBoxCertUtil -Args add-trusted-publisher,vbox*.cer,--root,vbox*.cer
      Write-Host "Installing VirtualBox Guest Additions..."
      Start-Process -Wait $${dl}:VBoxWindowsAdditions.exe -Args /S
      EOF
    ]
  }
}