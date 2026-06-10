ABOUT PROJECT
This was a school assignment. Directions was to integrate products from fakestoreapi and deploy on aws ec2.
I decided to create an inventory manually to further practise microservice architecture.

LOCAL DEVELOPMENT (docker-compose.local.yml)

Environment
Use .env.local for configuration. A Stripe Sandbox API key is required to create checkout sessions.

Inventory
The inventory is empty by default.
To manage stock: Manually add entries to the inventory database using the UUIDs from the products service.
Note: The system functions without manual stock entries. You can create reservations, but check-stock will not fail.

Payment (Stripe)
When paying in the sandbox, use Stripe's test card:
Number: 4242 4242 4242 4242
Exp: Any future date
CVC: Any
Mock Stripe Webhook (Locally)

To confirm payment manually:
Retrieve the stripe_session_id from the orders table in ordersdb or in the network tab under the success response.
Run:
Bash
curl -v -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
http://localhost:8083/api/local/confirm-payment/<STRIPE_SESSION_ID>

This marks the order as PAID, commits stock to Inventory, and deletes the reservation.

Important: Browser Cache
Cart items are saved in the browser's localStorage.
When restarting the products database: Clear localStorage as the product UUIDs may have changed.

PRODUCTION (docker-compose.yml)
Production requires AWS integration.

Stripe Webhook (EventBridge)
Use AWS EventBridge to handle Stripe events.
Event pattern:

JSON
{
"source": [{ "prefix": "aws.partner/stripe.com" }],
"detail-type": ["checkout.session.completed"],
"detail": {
"data": {
"object": {
"payment_status": ["paid"]
}
}
}
}

Connect this to the Order Paid SQS for the orders-service.

Reservation Confirmation
Create an SQS queue for the orders-service to publish confirm-reservation events for the inventory-service.

AWS / Docker swarm (docker-compose.aws)

Deployed using Docker Swarm across two AWS EC2 free tier instances. To stay within the memory constraints of the free tier, each service is configured with explicit JVM heap limits via JAVA_OPTS and Docker memory limits to prevent OOM crashes. Sensitive configuration and secrets are managed using AWS Parameter Store via the Spring Cloud AWS Parameter Store integration.
