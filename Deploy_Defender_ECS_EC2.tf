resource "aws_ecs_task_definition" "prisma" {

  container_definitions = <<EOF

[
 {
  "image": "registry-auth.twistlock.com/tw_dgsfsdfsdfsdfsdfaflpf0tc/twistlock/defender:defender_21_04_439",
  "name": "twistlock_defender",
  "memory": 512,
  "essential": true,
  "readonlyRootFilesystem": true,
  "privileged": true,
  "volumesFrom": [],
  "environment": [
    {
      "name": "DEFENDER_LISTENER_TYPE",
      "value": "none"
    },
    {
      "name": "DEFENDER_TYPE",
      "value": "ecs"
    },
    {
      "name": "DEFENDER_CLUSTER",
      "value": ""
    },
    {
      "name": "DOCKER_CLIENT_ADDRESS",
      "value": "/var/run/docker.sock"
    },
    {
      "name": "LOG_PROD",
      "value": "true"
    },
    {
      "name": "WS_ADDRESS",
      "value": "wss://us-west1.cloud.twistlock.com:443"
    },
    {
      "name": "INSTALL_BUNDLE",
      "value": "eyJzZWNyZXRzIjp7IwibWljcm9zZWdDb21wYXRpYmxlIjpmYWxzZX0="
    },
    {
      "name": "HOST_CUSTOM_COMPLIANCE_ENABLED",
      "value": "false"
    }
  ],
  "mountPoints": [
  {
    "containerPath": "/var/lib/twistlock",
    "sourceVolume": "data-folder"
  },
  {
    "containerPath": "/var/run",
    "sourceVolume": "docker-sock-folder"
  },
  {
    "readOnly": true,
    "containerPath": "/etc/passwd",
    "sourceVolume": "passwd"
  },
  {
    "containerPath": "/run",
    "sourceVolume": "iptables-lock-folder"
  },
  {
    "containerPath": "/dev/log",
    "sourceVolume": "syslog-socket"
  }
]
}
]
EOF

  volume { 
    name = "data-folder"
    host_path = "/var/lib/twistlock/"
  }
 

  volume {
    name = "docker-sock-folder"
    host_path = "/var/run"
  }

 

  volume {
    name =  "syslog-socket"
    host_path =  "/dev/log"
  }

 

  volume {
    name = "passwd"
    host_path = "/etc/passwd"
  }



  volume {
    name = "iptables-lock-folder"
    host_path = "/run"
  }

  

  memory                   = "512"
  family = "PrismaDefender"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  pid_mode                 = "host"

tags = {

      Name                  = "prismacloud"
      business_unit         = "INFRA"
}
}

 

resource "aws_ecs_service" "prisma_service" {
  name            = "twistlock" 
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prisma.arn
  scheduling_strategy = "DAEMON"

#  iam_role        = aws_iam_role.ecs_service.name
}

