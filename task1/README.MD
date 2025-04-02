Here you can find the list of the K8 components I’ve decided to use for my Nginx deployment.

Additional comments about the individual components' code can be found in the corresponding YAML files.

1. ResourceQuota (nginx-resource-quota.yaml)

While I am the sole user of my local Kubernetes setup, I still introduced the resource quota as part of resource management to control the CPU and RAM resources that my namespace can utilize.

In a production environment, it is important because this ensures Kubernetes can track and manage resource usage within a namespace. For instance, if a pod exceeds the RAM limit of the namespace, the pod will be killed, preventing the entire node from going down.

2. ConfigMap (nginx-configMap.yaml)

A ConfigMap acts as a settings file for our app inside Kubernetes. Instead of hardcoding configurations (such as URLs, database settings*, or logs) inside the container, we store them in a ConfigMap.

    * It’s important to note that ConfigMap does not provide encryption or secrecy. If we needed to specify sensitive data, like a DB username and password for the application, we should have used the Secret component (or another third-party tool) to keep the data private.

Since no sensitive data was passed to Nginx, I didn't create the Secret file.

3. Deployment and Service (nginx-deployment.yaml)

My deployment YAML consists of two parts:

- Deployment: In this section, I've specified the number of replicas for the Nginx server, mounted the ConfigMap, defined the resource requests and limits (for resource management), and set up the liveness and readiness probes (to ensure the pods are resilient).

- Service: In this part, I've exposed the service via NodePort 30124. NodePort was used because this is a local installation. In a cloud environment, I would use the LoadBalancer type.

 4. Horizontal Pod Autoscaler (nginx-hpa.yaml)

The HPA was introduced to enable scalability for the deployment. It automatically scales the number of replicas based on CPU utilization.

This differs from vertical scaling (which is best for stateful apps), where Kubernetes assigns more resources (such as memory or CPU) to the existing pods in the workload.

5. Ingress (nginx-ingress.yaml)

The Ingress component in Kubernetes is used to manage external HTTP(S) traffic to services within the cluster. We need this to access the Nginx server via the http://nginx.wow URL.

---

After applying all of the listed YAML files and updating the hosts file to include the line 127.0.0.1 nginx.wow, I was able to access Nginx via the browser (nginx-wow.png).

There was only one issue I faced: setting up Prometheus and Grafana to fetch data from Nginx. Unfortunately, despite my best efforts, I couldn't establish the connection, no matter how hard I tried :( On the bright side, other dashboards (pre-built ones like Kubernetes / Compute Resources / Cluster or imported ones like 10518 | Pod Stats & Info) worked fine.