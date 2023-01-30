#!/bin/bash

terraform apply -auto-approve -target aws_sqs_queue.archive_notification
./scripts/configure_cluster.sh