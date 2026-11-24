module "ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"

  name                      = "${var.cluster_name}-ebs-csi"
  attach_aws_ebs_csi_policy = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.26"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  enable_cluster_creator_admin_permissions = true

  enabled_log_types                      = var.control_plane_log_types
  cloudwatch_log_group_retention_in_days = var.log_retention_days

  kms_key_deletion_window_in_days = 7

  addons = {
    vpc-cni = {
      before_compute = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        env = {
            ENABLE_PREFIX_DELEGATION = "true"
            WARM_PREFIX_TARGET = "1"
        }
      })
    }

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}
    coredns    = {}

    aws-ebs-csi-driver = {
      pod_identity_association = [{
        role_arn        = module.ebs_csi_pod_identity.iam_role_arn
        service_account = "ebs-csi-controller-sa"
      }]
      configuration_values = jsonencode({
        controller = {
          extraVolumeTags = var.tags
        }
      })
    }

    metrics-server = {}
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types
      capacity_type = var.capacity_type

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      launch_template_tags = var.tags
    }
  }
}

