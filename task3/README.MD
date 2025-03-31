First, to ensure my Slack script was working correctly, I needed to create a deployment that was doomed to fail.

To do this, I created a deployment for the nginx server (nginx-doomed.yaml).

In order to make sure the deployment failed and produced image-related errors, I did the following:

	- Enabled our Cisco VPN, which seems to interfere with Kubernetes' ability to pull images from the web.
	- Intentionally introduced an error in the image name (e.g., nginx:1:26).

Once the deployment was created, it attempted to spin up pods. As expected, errors started appearing:

	$ kubectl get events --watch

	0s          Warning   Failed              pod/nginx-doomed-depl-69b689d8bb-88qdc    Error: InvalidImageName
	0s          Warning   Failed              pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Failed to pull image "nginx:1.26.3-alpine": error pulling image configuration: download failed after attempts=6: dial tcp 104.16.98.215:443: i/o timeout
	0s          Warning   Failed              pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Error: ErrImagePull
	0s          Warning   InspectFailed       pod/nginx-doomed-depl-69b689d8bb-tg6sv    Failed to apply default image tag "nginx:1:26": couldn't parse image name "nginx:1:26": invalid reference format

	---
	0s          Warning   Failed              pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Failed to pull image "nginx:1.26.3-alpine": error pulling image configuration: download failed after attempts=6: dial tcp 104.16.100.215:443: i/o timeout
	0s          Warning   Failed              pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Error: ErrImagePull
	0s          Normal    BackOff             pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Back-off pulling image "nginx:1.26.3-alpine"
	0s          Warning   Failed              pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Error: ImagePullBackOff
	0s          Normal    Pulling             pod/nginx-doomed-depl-6f6d6fdd6f-gtbp8    Pulling image "nginx:1.26.3-alpine"


Additionally, I researched common image-related errors to ensure my script covered them all.

The biggest issue I encountered was making the script check all namespaces, not just the default one. 

While searching for a solution, I ended up (metaphorically) building a helicopter just to get groceries. -.-

The realization hit me when I was almost done writing the send-slack-notifications.sh script. That's when I simplified and updated the script to the current version you see now.

And the results of my work can be seen in slack_notifications.png.

Since this is meant to be a simple script, I kept it concise and made it print only four key variables:

1. Pod Name

I decided to keep the full pod name rather than extracting the deployment name because the deployment name is already embedded within the pod name.

If needed, extracting just the deployment name can be done like this:

	deployment_name=$(echo "$pod_name" | awk -F'-' '{print $1"-"$2"-"$3}')

Alternatively, we could modify the kubectl get events command to include a complex awk expression, but since Kubernetes events don't explicitly store deployment names, this would make the command unnecessarily long.

Another variable would be defining in this case:

	deployment_name=$(echo "$line" | awk '{print $#}')

where '#' represents the field number where the deployment name appears.

However, I prefer the first option to keep the kubectl command simpler.

2. Namespace

This is helpful when multiple namespaces exist in the cluster, allowing me to quickly identify where the issue is occurring.

3. Error Message

Some errors, like InvalidImageName, are very specific and can immediately point to the problem. Seeing the error message in Slack helps reduce troubleshooting time.

4. Timestamp

When the error message is unclear (e.g., ImagePullBackOff), the timestamp helps locate the issue in the event logs. This allows me to check what happened before or after the event to gather more details.