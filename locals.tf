locals {
  mount_units = [for fs in var.filesystems : {
    name     = "${trim(replace(fs.path, "/", "-"), "-")}.mount"
    enabled  = true
    mask     = false
    content  = <<-EOT
      [Unit]
      Requires=systemd-fsck@dev-disk-by\x2dpartlabel-${fs.label}.service
      After=systemd-fsck@dev-disk-by\x2dpartlabel-${fs.label}.service

      [Mount]
      Where=${fs.path}
      What=${fs.device}
      Type=${fs.format}

      [Install]
      RequiredBy=local-fs.target
    EOT
    dropin   = []
  } if fs.with_mount_unit == true]
  combined_systemd_units = concat(var.systemd_units, local.mount_units)
}
