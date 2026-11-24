locals {
  name = "atlas-${var.environment}"
  tags = { Project = "atlas", Environment = var.environment, ManagedBy = "terraform", Owner = var.owner }
}

module "network" {
  source             = "../../modules/network"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  single_nat_gateway = var.single_nat_gateway
  enable_flow_log    = var.enable_flow_log
}

module "cluster" {
  source                       = "../../modules/cluster"
  cluster_name                 = local.name
  kubernetes_version           = var.kubernetes_version
  vpc_id                       = module.network.vpc_id
  subnet_ids                   = module.network.private_subnet_ids
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  node_instance_types          = var.node_instance_types
  capacity_type                = var.capacity_type
  node_min_size                = var.node_min_size
  node_max_size                = var.node_max_size
  node_desired_size            = var.node_desired_size
  log_retention_days           = var.log_retention_days
  control_plane_log_types      = var.control_plane_log_types
  tags                         = local.tags
}