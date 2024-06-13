#  This Terraform configuration file defines the Ignition configuration for an Immutable OS Stack.
#  It uses the community-terraform-providers/ignition provider version 2.3.3 or higher.
#  The Ignition configuration includes directories, disks, files, filesystems, groups, kernel arguments,
#  links, LUKS encryption, RAID arrays, systemd units, and users.
#  The data blocks retrieve information from variables and generate the rendered Ignition configuration.
#  The output block returns the rendered Ignition configuration.

terraform {
  required_providers {
    ignition  = {
      source  = "community-terraform-providers/ignition"
      version = ">= 2.3.4"
    }
  }
}

# Data block for retrieving directory information
data "ignition_directory" "directories" {
    for_each  = { for i, v in var.directories : tostring(i) => v }
    path      = each.value.path
    overwrite = each.value.overwrite
    mode      = each.value.mode
    uid       = each.value.uid
    gid       = each.value.gid
}

# Data block for retrieving disk information
data "ignition_disk" "disks" {
    for_each   = { for i, v in var.disks : tostring(i) => v }
    device     = each.value.device
    wipe_table = each.value.wipe_table
    dynamic "partition" { 
        for_each = each.value.partitions == null ? [] : each.value.partitions
        content {
            label     = partition.value.label
            number    = partition.value.number
            sizemib   = partition.value.sizemib
            startmib  = partition.value.startmib
            type_guid = partition.value.type_guid
        }
    }
}

# Data block for retrieving file information
data "ignition_file" "files" {
  for_each = { for i, v in var.files : tostring(i) => v } 
  path = each.value.path
  overwrite = each.value.overwrite
  dynamic "content" {
    for_each = each.value.content == null ? {} : { "content" = each.value.content }
    content {
      mime = each.value.content.mime
      content = each.value.content.content
    }
  }
  dynamic "source" {
    for_each = each.value.source == null ? {} : { "source" = each.value.source } 
    content {
      source = each.value.source.source
      compression = each.value.source.compression
      verification = each.value.source.verification
      dynamic "http_headers" {
        for_each = each.value.source.http_headers == null ? [] : each.value.source.http_headers
        content {
          name = http_headers.value.name
          value = http_headers.value.value
        }
      }
    }
  }
  mode = each.value.mode
  uid = each.value.uid
  gid = each.value.gid
}

# Data block for retrieving filesystem information
data "ignition_filesystem" "filesystems" {
    for_each = { for i, v in var.filesystems : tostring(i) => v }
    device = each.value.device
    format = each.value.format
    wipe_filesystem = each.value.wipe_filesystem
    label = each.value.label
    uuid = each.value.uuid
    options = each.value.options
    path = each.value.path
}

# Data block for retrieving group information
data "ignition_group" "groups" {
    for_each = { for i, v in var.groups : tostring(i) => v }
    name = each.value.name
    password_hash = each.value.password_hash
    gid = each.value.gid
}

# Data block for retrieving kernel argument information
data "ignition_kernel_arguments" "kernel_arguments" {
    shouldexist    = var.kernel_arguments.shouldexist
    shouldnotexist = var.kernel_arguments.shouldnotexist
} 

# Data block for retrieving link information
data "ignition_link" "links" {
    for_each = { for i, v in var.links : tostring(i) => v }
    path = each.value.path
    target = each.value.target
    overwrite = each.value.overwrite
    hard = each.value.hard
    uid = each.value.uid
    gid = each.value.gid
}

# Data block for retrieving LUKS encryption information
data "ignition_luks" "luks" {
    for_each = { for i, v in var.luks : tostring(i) => v }
    name = each.value.name
    device = each.value.device
    discard = each.value.discard
    label = each.value.label
    open_options = each.value.open_options
    options = each.value.options
    uuid = each.value.uuid
    wipe_volume = each.value.wipe_volume
    dynamic "key_file" {
      for_each = each.value.key_file == null ? {} : { key_file = each.value.key_file}
      content {
        source = each.value.key_file.source
        compression = each.value.key_file.compression
        
      }
    }
    dynamic "clevis" {
      for_each = each.value.clevis == null ? {} : { clevis = each.value.clevis }
      content {
        dynamic "tang" {
          for_each = each.value.clevis.tang == null ? {} : { tang = each.value.clevis.tang }
          content {
            url = tang.value.url
            thumbprint = tang.value.thumbprint
            advertisement = tang.value.advertisement
          }
        }
        tpm2 = each.value.clevis.tpm2
        threshold = each.value.clevis.threshold
        dynamic "custom" {
          for_each = each.value.clevis.custom == null ? {} : { custom = each.value.clevis.custom }  
          content {
            pin = each.value.clevis.custom.pin
            config = each.value.clevis.custom.config
            needs_network = each.value.clevis.custom.needs_network
          }
        }
      }
    }
}

# Data block for retrieving RAID array information
data "ignition_raid" "arrays" {
    for_each = { for i, v in var.arrays : tostring(i) => v }
    name = each.value.name
    level = each.value.level
    devices = each.value.devices
    spares = each.value.spares
}

# Data block for retrieving systemd unit information
data "ignition_systemd_unit" "systemd_units" {
    for_each = { for i, v in local.combined_systemd_units : tostring(i) => v }
    name = each.value.name
    enabled = each.value.enabled
    mask = each.value.mask
    content = each.value.content 
    dynamic "dropin" {
      for_each = each.value.dropin == null ? [] : each.value.dropin
      content {
        name = dropin.value.name
        content = dropin.value.content
      }
    }
}

# Data block for retrieving user information
data "ignition_user" "users" {
    for_each = { for i, v in var.users : tostring(i) => v }
    name = each.value.name
    password_hash = each.value.password_hash
    ssh_authorized_keys = each.value.ssh_authorized_keys
    uid = each.value.uid
    gecos = each.value.gecos
    home_dir = each.value.home_dir
    no_create_home = each.value.no_create_home
    primary_group = each.value.primary_group
    groups = each.value.groups
    no_user_group = each.value.no_user_group
    no_log_init = each.value.no_log_init
    shell = each.value.shell
    system = each.value.system
}

# Data block for generating the rendered Ignition configuration
data "ignition_config" "config" {
    directories      = [ for directory in values(data.ignition_directory.directories) : directory.rendered ]
    disks            = [ for disk in values(data.ignition_disk.disks) : disk.rendered ]
    files            = [ for file in values(data.ignition_file.files) : file.rendered ]
    filesystems      = [ for filesystem in values(data.ignition_filesystem.filesystems) : filesystem.rendered ]
    groups           = [ for group in values(data.ignition_group.groups) : group.rendered ]
    kernel_arguments = data.ignition_kernel_arguments.kernel_arguments.rendered
    links            = [ for link in values(data.ignition_link.links) : link.rendered]
    luks             = [ for luks in values(data.ignition_luks.luks) : luks.rendered  ]
    arrays           = [ for array in values(data.ignition_raid.arrays) : array.rendered ]
    systemd          = [ for unit in values(data.ignition_systemd_unit.systemd_units) : unit.rendered ]
    users            = [ for user in values(data.ignition_user.users) : user.rendered ]
    dynamic "tls_ca" {
      for_each = var.tls_ca == null ? [] : var.tls_ca 
      content {
        source       = tls_ca.value.source
        compression  = tls_ca.value.compression
        verification = tls_ca.value.verification
        dynamic "http_headers" {
          for_each = tls_ca.value.http_headers == null ? [] : tls_ca.value.http_headers
          content {
            name = http_headers.value.name
            value = http_headers.value.value
          }
        }
      }
    }
    dynamic "merge" {
      for_each = var.merge == null ? [] : var.merge 
      content {
        source       = merge.value.source
        compression  = merge.value.compression
        verification = merge.value.verification
        dynamic "http_headers" {
          for_each = merge.value.http_headers == null ? [] : merge.value.http_headers
          content {
            name = http_headers.value.name
            value = http_headers.value.value
          }
        }
      }
    }
    dynamic "replace" {
      for_each = var.replace == null ? [] : var.replace 
      content {
        source       = replace.value.source
        compression  = replace.value.compression
        verification = replace.value.verification
        dynamic "http_headers" {
          for_each = replace.value.http_headers == null ? [] : replace.value.http_headers
          content {
            name = http_headers.value.name
            value = http_headers.value.value
          }
        }
      }
    }
}

# Output block for returning the rendered Ignition configuration
output "ignition_config" {
  value = data.ignition_config.config.rendered
}
