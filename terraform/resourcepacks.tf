
module "postgres_basic" {
  source = "github.com/humanitec-architecture/resource-packs-in-cluster//humanitec-resource-defs/postgres/basic"
  prefix = "qhd-"
}

resource "humanitec_resource_definition_criteria" "postgres_basic" {
  resource_definition_id = module.postgres_basic.id
  class                  = "default"
  force_delete           = true
}
