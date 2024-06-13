variable "directories" {
  description = "The list of directories to be created."
  type        = list(object({
    path      = string # (Required) The absolute path to the directory.
    overwrite = optional(bool) # (Optional) Whether to delete preexisting nodes at the path. Defaults to false.
    mode      = optional(number) # (Optional) The directory's permission mode. Note that the mode must be properly specified as a decimal value, not octal (i.e. 0755 -> 493).
    uid       = optional(number) # (Optional) The user ID of the owner.
    gid       = optional(number) # (Optional) The group ID of the owner.
  }))
  default = [ ]
}

variable "disks" {
    description = "The list of disks to be configured and their options."
    type     = list(object({
      device        = string # (Required) The absolute path to the device. Devices are typically referenced by the /dev/disk/by-* symlinks.
      wipe_table    = optional(bool) # (Optional) Whether or not the partition tables shall be wiped. When true, the partition tables are erased before any further manipulation. Otherwise, the existing entries are left intact.
      partitions    = optional(list(object({ # (Optional) The list of partitions and their configuration for this particular disk..
          label     = optional(string) # (Optional) The PARTLABEL for the partition.
          number    = optional(number) # (Optional) The partition number, which dictates it’s position in the partition table (one-indexed). If zero, use the next available partition slot.
          sizemib   = optional(number) # (Optional) The size of the partition (in MiB). If zero, the partition will fill the remainder of the disk.
          startmib  = optional(number) # (Optional) The start of the partition (in MiB). If zero, the partition will be positioned at the earliest available part of the disk.
          type_guid = optional(string) # (Optional) The GPT partition type GUID. If omitted, the default will be 0FC63DAF-8483-4772-8E79-3D69D8477DE4 (Linux filesystem data).
    })))
  }))
  default = [ ]
}

variable "files" {
    description = "The list of files to be written."
    type = list(object({
        path = string # (Required) The absolute path to the file.
        overwrite = optional(bool) # (Optional) Whether to delete preexisting nodes at the path. Defaults to false.
        content = optional(object({ # (Optional) Block to provide the file content inline.
            mime    = string # (Required) MIME format of the content (default text/plain).
            content = string # (Required) Content of the file.
        })) 
        source = optional(object({ # (Optional) Block to retrieve the file content from a remote location.
            source = string  # (Required) The URL of the file contents. Supported schemes are http, https, tftp, s3, and data. When using http, it is advisable to use the verification option to ensure the contents haven't been modified.
            compression = optional(string) # (Optional) The type of compression used on the contents (null or gzip). Compression cannot be used with S3.
            verification =optional(string) # (Optional) The hash of the config, in the form <type\>-<value\> where type is either sha512 or sha256. If compression is specified, the hash describes the decompressed file.
            http_headers = optional(list(object({ # (Optional) A list of HTTP headers to be added to the request.
                name = string # (Required) The header name.
                value = string # (Required) The header contents.
            }))) # 
        })) # 
        mode = optional(number) # (Optional) The file's permission mode. Note that the mode must be properly specified as a decimal value, not octal (i.e. 0755 -> 493).
        uid = optional(number) # (Optional) The user ID of the owner.
        gid = optional(number) # (Optional) The group ID of the owner.
    }))
    default = [ ]
}

variable "filesystems" {
  description = "The list of filesystems to be configured and/or used in the ignition_file, ignition_directory, and ignition_link resources."
  type = list(object({
    device          = string # (Required) The absolute path to the device. Devices are typically referenced by the /dev/disk/by-* symlinks.
    format          = string # (Required) The filesystem format (ext4, btrfs, xfs, vfat, or swap).
    wipe_filesystem = optional(bool) # (Optional) Whether or not to wipe the device before filesystem creation.
    label           = optional(string) # (Optional) The label of the filesystem.
    uuid            = optional(string) # (Optional) The uuid of the filesystem.
    options         = optional(list(string)) # (Optional) Any additional options to be passed to the format-specific mkfs utility.
    path            = optional(string) # (Optional) The mount-point of the filesystem while Ignition is running relative to where the root filesystem will be mounted. This is not necessarily the same as where it should be mounted in the real root, but it is encouraged to make it the same.
    with_mount_unit = optional(bool) # (Optional) Whether or not to create a systemd mount unit for the filesystem.
  }))
  default = [ ]
}

variable "groups" {
  description = "The list of groups to be added."
  type = list(object({
    name          = string # (Required) The groupname for the account.
    password_hash = optional(string) # (Optional) The encrypted password for the account.
    gid           = optional(number) # (Optional) The group ID of the new account.
  }))
  default = [ ]
}

variable "kernel_arguments" {
  description = "Parametes that describe the desired kernel arguments."
  type = object({
    shouldexist    = optional(list(string)) # (Optional) The list of kernel arguments that should exist.
    shouldnotexist = optional(list(string)) # (Optional) The list of kernel arguments that should not exist.
  })
  default =  { }
  
}

variable "links" {
  description = "The list of links to be created."
  type = list(object({
    path      = string # (Required) The absolute path to the link.
    target    = string # (Required) The target path of the link.
    overwrite = optional(bool) # (Optional) Overwrite the link, if it already exists.
    hard      = optional(bool) # (Optional) A symbolic link is created if this is false, a hard one if this is true.
    uid       = optional(number) # (Optional) The user ID of the owner.
    gid       = optional(number) # (Optional) The group ID of the owner.
  }))
  default = [ ]
}

variable "luks" {
  description = "value of the luks key in the ignition config"
  type = list(object({
    name         = string # (Required) The name to use for the resulting luks device.
    device       = string # (Required) The absolute path to the device. Devices are typically referenced by the /dev/disk/by-* symlinks.
    discard      = optional(bool) #(Optional) Whether to issue discard commands to the underlying block device when blocks are freed. Enabling this improves performance and device longevity on SSDs and space utilization on thinly provisioned SAN devices, but leaks information about which disk blocks contain data. If omitted, it defaults to false.
    label        = optional(string) # (Optional) The label of the luks device.
    open_options = optional(string) #  (Optional) Any additional options to be passed to cryptsetup luksOpen. Supported options will be persistently written to the luks volume.
    options      = optional(string) # (Optional) Any additional options to be passed to cryptsetup luksFormat.
    uuid         = optional(number) # (Optional) The uuid of the luks device.
    wipe_volume  = optional(bool) # (Optional) Whether or not to wipe the device before luks creation.
    key_file     = optional(object({ # (Optional) Options related to the contents of the key file.
      source       = string # (Required) The URL of the key file. Supported schemes are http, https, tftp, s3, arn, gs, and data. When using http, it is advisable to use the verification option to ensure the contents haven’t been modified.
      compression  = optional(string) # (Optional) The type of compression used on the key file (null or gzip). Compression cannot be used with S3.
      http_headers = optional(list(object({ # (Optional) A list of HTTP headers to be added to the request. Available for http and https source schemes only
        name  = string # (Required) The name of the header.
        value = string # (Required) The value of the header.
      })))
      verification = string # (Required) The verification method to use for the key file. Supported methods are none, sha256, sha512, and sha512-224.
    }))
    clevis = optional(object({  # (Optional) Describes the clevis configuration for the luks device.
      tang = optional(list(object({ # (Optional) Describes a tang server. Every server must have a unique url.  If specified, all other clevis options must be omitted.
        url           = string # (Required) Url of the tang server.
        thumbprint    = optional(string) # (Optional) Thumbprint of a trusted signing key.
        advertisement = optional(string) # (Optional) The advertisement JSON. If not specified, the advertisement is fetched from the tang server during provisioning.
      })))
      tpm2      = optional(bool) # (Optional) Whether or not to use a tpm2 device.
      threshold = optional(number) # (Optional) Sets the minimum number of pieces required to decrypt the device. Default is 1.
      custom    = optional(object({ # (Optional) Overrides the clevis configuration. The pin & config will be passed directly to clevis luks bind. If specified, all other clevis options must be omitted.
        pin           = optional(string) # (Optional) The clevis pin.
        config        = optional(string) # (Optional) The clevis configuration JSON.
        needs_network = optional(bool) # (Optional) Whether or not the device requires networking.
      })) 
    }))
  }))
  default = [ ]
}

variable "arrays" {
  description = "The list of RAID arrays to be configured."
  type = list(object({
    name    = string # (Required) The name to use for the resulting md device.
    level   = string # (Required) The redundancy level of the array (e.g. linear, raid1, raid5, etc.).
    devices = list(string) # (Required) The list of devices (referenced by their absolute path) in the array.
    spares  = optional(number) # (Optional) The number of spares (if applicable) in the array.
  }))
  default = [ ]
}

variable "systemd_units" {
  description = "The list of systemd units. Describes the desired state of the systemd units."
  type = list(object({
    name      = string # (Required) The name of the unit. This must be suffixed with a valid unit type (e.g. thing.service).
    enabled   = optional(bool) # (Optional) Whether or not the service shall be enabled. When true, the service is enabled. In order for this to have any effect, the unit must have an install section. (default true)
    mask      = optional(bool) # (Optional) Whether or not the service shall be masked. When true, the service is masked by symlinking it to /dev/null.
    content  = optional(string) # (Optional) The contents of the unit.
    dropin   = optional(list(object({ # (Optional) The list of drop-ins for the unit.
      name     = string # (Required) The name of the drop-in. This must be suffixed with .conf.
      content  = string # (Optional) The contents of the drop-in.
    })))
  }))
  default = [ ]
}

variable "users" {
  description = "The list of accounts to be added."
  type        = list(object({
    name                = string # (Required) The username for the account.
    password_hash       = optional(string) # (Optional) The encrypted password for the account.
    ssh_authorized_keys = optional(list(string)) # (Optional) A list of SSH keys to be added to the user’s authorized_keys.
    uid                 = optional(number) # (Optional) The user ID of the new account.
    gecos               = optional(string) # (Optional) The GECOS field of the new account.
    home_dir            = optional(string) # (Optional) The home directory of the new account.
    no_create_home      = optional(bool) # (Optional) Whether or not to create the user’s home directory.
    primary_group       = optional(string) # (Optional) The name or ID of the primary group of the new account.
    groups              = optional(list(string)) # (Optional) The list of supplementary groups of the new account.
    no_user_group       = optional(bool) # (Optional) Whether or not to create a group with the same name as the user.
    no_log_init         = optional(bool) # (Optional) Whether or not to add the user to the lastlog and faillog databases.
    shell               = optional(string) # (Optional) The login shell of the new account.
    system              = optional(bool) # (Optional) Whether or not to make the account a system account. This only has an effect if the account doesn't exist yet.
  }))
  default      = [ ]
}

variable "tls_ca" {
  description = "The list of additional certificate authorities to be used for TLS verification when fetching over https."
  type        = list(object({
    source       = string # (Required) The URL of the config. Supported schemes are http, https, tftp, s3, and data. When using http, it is advisable to use the verification option to ensure the contents haven't been modified.
    compression  = optional(string) # (Optional) The type of compression used on the config (null or gzip). Compression cannot be used with S3.
    verification = optional(string) # (Optional) The hash of the config, in the form <type\>-<value\> where type is either sha512 or sha256. If compression is specified, the hash describes the decompressed config.
    http_headers = optional(list(object({ # (Optional) A list of HTTP headers to be added to the request.
      name = string # (Required) The header name.
      value = string # (Required) The header contents.  
    })))
  }))
  default     = [ ]
}

variable "merge" {
  description = "A list of the configs to be merged to the current config."
  type        = list(object({
    source       = string # (Required) The URL of the config. Supported schemes are http, https, tftp, s3, and data. When using http, it is advisable to use the verification option to ensure the contents haven't been modified.
    compression  = optional(string) # (Optional) The type of compression used on the config (null or gzip). Compression cannot be used with S3.
    verification = optional(string) # (Optional) The hash of the config, in the form <type\>-<value\> where type is either sha512 or sha256. If compression is specified, the hash describes the decompressed config.
    http_headers = optional(list(object({ # (Optional) A list of HTTP headers to be added to the request.
      name = string # (Required) The header name.
      value = string # (Required) The header contents.  
    })))
  }))
  default     = [ ]
}

variable "replace" {
  description = "A block with config that will replace the current."
  type        = list(object({
    source       = string # (Required) The URL of the config. Supported schemes are http, https, tftp, s3, and data. When using http, it is advisable to use the verification option to ensure the contents haven't been modified.
    compression  = optional(string) # (Optional) The type of compression used on the config (null or gzip). Compression cannot be used with S3.
    verification = optional(string) # (Optional) The hash of the config, in the form <type\>-<value\> where type is either sha512 or sha256. If compression is specified, the hash describes the decompressed config.
    http_headers = optional(list(object({ # (Optional) A list of HTTP headers to be added to the request.
      name = string # (Required) The header name.
      value = string # (Required) The header contents.  
    })))
  }))
  default     = [ ]
}