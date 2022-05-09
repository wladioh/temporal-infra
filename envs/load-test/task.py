# https://cloud.google.com/architecture/distributed-load-testing-using-gke
# https://docs.locust.io/en/stable/index.html
# https://www.blazemeter.com/blog/locust-monitoring-with-grafana-in-just-fifteen-minutes
# https://github.com/GoogleCloudPlatform/distributed-load-testing-using-kubernetes
# https://medium.com/devopsturkiye/locust-real-time-monitoring-with-grafana-66654bb4b32
# https://docs.locust.io/en/2.8.1/running-in-docker.html#running-in-docker

import time
from locust import task, FastHttpUser, between

class HelloWorldUser(FastHttpUser):
    wait_time = between(1, 5)

    def on_start(self):
        self.client.post("/catalog/v1", json={
                "title": "Teste",
                "price": 10.0,
                "description": "",
                "sku": "1234567"
        })

    @task
    def hello_world(self):
        self.client.post("/stock/v1", json={
            "name": "Teste",
            "quantity": 10,
            "sku": "1234567"
        })    
        response = self.client.post("/cart/v1", "9c5dd5d8-55dd-47e1-8722-83b55fb21b6c", name="/cart")
        if response.status_code != 200:
            print("Response status code:", response.status_code)
            print("Response text:", response.text)
            response.failure("Got wrong response")

        cartId = response.json()["id"];
        if cartId is None:
            response.failure("cartId is null")

        for item_id in range(10):
            self.client.post(f"/cart/v1/{cartId}/item", name="/item", json={
                "sku": "1234567",
                "quantity": 1
            })
            time.sleep(1)
        self.client.post(f"/cart/v1/{cartId}/paymethod", name="/paymethod", json={
                "method":"BOLETO"
            })   
        time.sleep(1)  
        orderRequest = self.client.post(f"/order/v1", name="/order", json=
            {
                "cartId": cartId
            })
        time.sleep(1) 
        orderId =orderRequest.json();
        payment = self.client.get(f"/payment/v1/order/{orderId}", name="/get payment")
        paymentId = payment.json()["id"];
        self.client.put(f"/payment/v1/{paymentId}", json="PAID", name="/confirm payment")
       