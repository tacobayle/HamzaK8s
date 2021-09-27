#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "avi_password" {}
variable "avi_username" {}
variable "avi_vsphere_user" {}
variable "avi_vsphere_password" {}
variable "avi_vsphere_server" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
variable "docker_registry_email" {}

#
# Other Variables
#
variable "vcenter" {
  type = map
  default = {
    dc = "wdc-06-vc12"
    cluster = "wdc-06-vc12c01"
    datastore = "wdc-06-vc12c01-vsan"
    resource_pool = "wdc-06-vc12c01/Resources"
    folder = "Hamza_K8S"
    networkMgmt = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
  }
}

variable "controller" {
  default = {
    cpu = 16
    memory = 32768
    disk = 256
//    count = "1"
    cluster = false
    floating_ip = "10.41.134.130"
    version = "21.1.1-9045"
    wait_for_guest_net_timeout = 4
    private_key_path = "~/.ssh/cloudKey"
    environment = "VMWARE"
    dns =  ["10.23.108.1", "10.23.108.2"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "true" # true is required for LSC Cloud
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.avicreds.json"
    public_key_path = "~/.ssh/cloudKey.pub"
  }
}

variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 2
    memory = 4096
    disk = 20
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-focal-20.04-cloudimg-template"
    avisdkVersion = "21.1.1"
    username = "ubuntu"
  }
}

variable "ansible" {
  type = map
  default = {
    version = "2.10.7"
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.54"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v5.93"
    k8sInstallUrl = "https://github.com/tacobayle/ansibleK8sInstall"
    k8sInstallTag = "v1.56"
  }
}

variable "vmw" {
  default = {
    name = "dc1_vcenter"
    datacenter = "wdc-06-vc12"
    dhcp_enabled = "true"
    domains = [
      {
        name = "avi.com"
      }
    ]
    management_network = {
      name = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
      dhcp_enabled = "true"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
    }
    network_vip = {
      name = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
      ipStartPool = "230"
      ipEndPool = "249"
      cidr = "100.64.133.0/24"
      type = "V4"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
      dhcp_enabled = "no"
    }
    virtualservices = {
      http = [
      ]
      dns = [
        {
          name = "app-dns"
          services: [
            {
              port = 53
            }
          ]
        }
      ]
    }
    kubernetes = {
      workers = {
        count = 2
      }
      ako = {
        deploy = false
      }
      clusters = [
        {
          name = "cluster1" # cluster name
          netplanApply = true
          username = "ubuntu" # default username dor docker and to connect
          version = "1.21.3-00" # k8s version
          namespaces = [
            {
              name= "ns1"
            },
            {
              name= "ns2"
            },
            {
              name= "ns3"
            },
          ]
          ako = {
            namespace = "avi-system"
            version = "1.5.1"
            helm = {
              url = "https://projects.registry.vmware.com/chartrepo/ako"
            }
          }
          arePodsReachable = "false" # defines in values.yml if dynamic route to reach the pods
          serviceEngineGroup = {
            name = "seg-cluster1"
            ha_mode = "HA_MODE_SHARED"
            min_scaleout_per_vs = "2"
            vcenter_folder = Hamza_K8S"
          }
          networks = {
            pod = "192.168.0.0/16"
          }
          docker = {
            version = "5:20.10.7~3-0~ubuntu-bionic"
          }
          service = {
            type = "ClusterIP"
          }
          interface = "ens224" # interface used by k8s
          cni = {
            url = "https://docs.projectcalico.org/manifests/calico.yaml"
            name = "calico" # calico or antrea
          }
          master = {
            cpu = 8
            memory = 16384
            disk = 80
            network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
            wait_for_guest_net_routable = "false"
            template_name = "ubuntu-bionic-18.04-cloudimg-template"
            netplanFile = "/etc/netplan/50-cloud-init.yaml"
          }
          worker = {
            cpu = 4
            memory = 8192
            disk = 40
            network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
            wait_for_guest_net_routable = "false"
            template_name = "ubuntu-bionic-18.04-cloudimg-template"
            netplanFile = "/etc/netplan/50-cloud-init.yaml"
          }
        },
        {
          name = "cluster2"
          netplanApply = true
          username = "ubuntu"
          version = "1.21.3-00"
          namespaces = [
            {
              name= "ns1"
            },
            {
              name= "ns2"
            },
            {
              name= "ns3"
            },
          ]
          ako = {
            namespace = "avi-system"
            version = "1.5.1"
            helm = {
              url = "https://projects.registry.vmware.com/chartrepo/ako"
            }
          }
          arePodsReachable = "false"
          serviceEngineGroup = {
            name = "seg-cluster2"
            ha_mode = "HA_MODE_SHARED"
            min_scaleout_per_vs = "2"
            vcenter_folder = "Hamza_K8S"
          }
          networks = {
            pod = "192.168.1.0/16"
          }
          docker = {
            version = "5:20.10.7~3-0~ubuntu-bionic"
          }
          service = {
            type = "ClusterIP"
          }
          interface = "ens224"
          cni = {
            url = "https://github.com/vmware-tanzu/antrea/releases/download/v0.13.4/antrea.yml"
            name = "antrea"
          }
          master = {
            count = 1
            cpu = 8
            memory = 16384
            disk = 80
            network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
            wait_for_guest_net_routable = "false"
            template_name = "ubuntu-bionic-18.04-cloudimg-template"
            netplanFile = "/etc/netplan/50-cloud-init.yaml"
          }
          worker = {
            cpu = 4
            memory = 8192
            disk = 40
            network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
            wait_for_guest_net_routable = "false"
            template_name = "ubuntu-bionic-18.04-cloudimg-template"
            netplanFile = "/etc/netplan/50-cloud-init.yaml"
          }
        }
      ]
    }
  }
}