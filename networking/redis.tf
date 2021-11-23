#create an elasticache t2.micro redis cache
resource "aws_elasticache_cluster" "redis" {
    cluster_id      = "attack-map-redis"
    engine          = "redis"
    node_type       = "cache.t2.micro"
    num_cache_nodes = 1
    port = 6379
    security_group_ids = [
        "${aws_security_group.main-sg.id}",
    ]
}


