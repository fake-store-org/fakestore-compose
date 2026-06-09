#!/bin/bash
# queues for local
awslocal sqs create-queue --queue-name order-paid-queue --region us-east-1
awslocal sqs create-queue --queue-name confirm-reservation-event --region us-east-1