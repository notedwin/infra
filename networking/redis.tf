#create an elasticache t2.micro redis cache
resource "aws_elasticache_cluster" "redis" {
    cluster_id      = "attack-map-redis"
    engine          = "redis"
    node_type       = "cache.t2.micro"
    num_cache_nodes = 1
    port = 6379
    subnet_group_name = aws_elasticache_subnet_group.default.name
    security_group_ids = [aws_security_group.lambda_sg.id]    
}

resource "aws_elasticache_subnet_group" "default" {
  name        = "subnet-group-redis"
  subnet_ids  = [aws_subnet.private-subnet.id]
}


resource "aws_security_group" "redis_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
      cidr_blocks = [aws_subnet.private-subnet.cidr_block]
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}