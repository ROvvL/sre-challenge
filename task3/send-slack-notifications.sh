#!/bin/bash

# For the sake of convenience (and for not making this file even bigger), 
# I will not add comments for the parts of the code that were already explained previously. :)

# Here we are setting our Slack webhook URL
# Please do not forget to replace it with your webhook URL :)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXXXXXX"

# Function to send Slack notifications

send_slack_notification() {

# The 'local' lines are variable assignments inside the function. 
# This makes the variables local to the function, so in case we add more code to this bash file and have the same variables, 
# they will not interfere with each other.  
# $1, $2, $3, $4 are positional parameters, which are arguments passed to the function.
# When you call the 'send_slack_notification "$pod_name" "$namespace" "$reason" "$error_time"', the function assigns:
# $1 -> "pod_name" -> $pod_nam | $2 -> "namespace" -> $namespace | $3 -> "reason" -> $reason | $4 -> "error_time" -> $error_time

    local pod_name=$1
    local namespace=$2
    local reason=$3 
    local error_time=$4

# This line will help us to combine the variables we defined above into one wonderful message.
# \n adds a newline character before the value of the variable or text, making it appear on a new line when sent as a Slack message.
   
    local message="Pod *$pod_name* failed due to an incorrect image. \nNamespace: $namespace  \n$reason \nTime: $error_time"
    
# This curl command sends an HTTP POST request to Slack's incoming webhook URL to deliver the formatted message. 
# -X specifies the HTTP method to use in this request; POST is the HTTP method that sends data to the server.
# -H stands for header, and it specifies the content type of the request
# 'Content-type: application/json' tells the Slack server that the data being sent is in JSON format (since the Slack API expects JSON-formatted data)
# --data is used to specify the data to be sent with the POST request.
# "{\"text\": \"$message\"}" is the data being sent in JSON format. 
# Specifically, $message variable will contain the content of the message, which was previously constructed in the script.
# $SLACK_WEBHOOK_URL is a shell variable that holds the actual URL, which is the endpoint that receives the POST request to trigger Slack notifications.

    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$message\"}" "$SLACK_WEBHOOK_URL"
}

# Watch for failed pod events

# kubectl get events is used to track all the events we have on our cluster.
# --all-namespaces flag ensures that the events are retrieved from all namespaces in the cluster, not just the default namespace.
# --watch flag makes the kubectl get events command. continuously watch for changes to the events in the cluster.
# --field-selector flag allows us to filter the results based on certain criteria.
# reason=Failed filters the events to only show those with the reason field equal to Failed.
# -o custom-columns="..." this specifies the output format. Instead of the default tabular output, custom-columns allow us to define which fields we want to display and in what format. 
# "while" is a loop that reads each line of the output from the kubectl get events command.
# "read line" means that for each new event, the read command reads a single line of input from the stream and assigns it to the variable line.
# "do" keyword indicates the start of the block of code that will be executed for each line (event) received. 
# The code block inside the loop will be executed for every event that meets the filter criteria (reason=Failed).

kubectl get events --all-namespaces --watch --field-selector reason=Failed -o custom-columns="TIME:.lastTimestamp,REASON:.reason,POD:.involvedObject.name,NAMESPACE:.involvedObject.namespace,MESSAGE:.message" | while read line; do

# echo "$line" will print the value of the variable line to the next command in the pipeline.
# grep is a command-line tool used to search for patterns in text.
# -q stands for quiet mode. This means grep will not output anything to the terminal. 
# "ErrImagePull\|ImagePullBackOff\|InvalidImageName\|ErrImageNeverPull" is the search pattern passed to grep to check for multiple possible error conditions.
# \| is the regex operator for 'OR' in grep. It allows us to search for multiple patterns at once. 
# if...then is a statement. The 'if' checks if the command inside the parentheses (in this case, the echo "$line" | grep -q ...) returns a successful exit status (0).
# If grep finds any of the patterns listed, the exit status of grep will be 0, which will make the if condition true.
   
    if echo "$line" | grep -q "ErrImagePull\|ImagePullBackOff\|InvalidImageName\|ErrImageNeverPull"; then

# Extracting pod name, namespace, and the reason (error) from the event log

# error_time=$(...) here we define the variable. The result of the entire pipeline is assigned to the variable "error_time".
# awk is a text-processing tool that can be used to manipulate or extract specific columns from text based on a delimiter.
# '{print $1}' tells awk to print the 1th field from the line.
# The awk '{print $1}'  was used since the output of the kubectl get events... command returns the pod name in the 1st column (kubectl_get_events.png screenshot)
   
        error_time=$(echo "$line" | awk '{print $1}')

# Here we are printing the pod name which is located in the 3rd field.   

        pod_name=$(echo "$line" | awk '{print $3}')  

# The bunch of symbols is awk helped to compile the 5th "MESSAGE" field. 
# If we used a simple awk '{print $5}' it would return only the first word from the 5th field ("Error"). 

        reason=$(echo "$line" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}')

        namespace=$(echo "$line" | awk '{print $4}')

# Now, since we defined a lot of variables, it is time to call the function send_slack_notification to actually send the notification to Slack.
# This command triggers the send_slack_notification function and provides it with the relevant details about the pod failure 
#by passing these four variables ($pod_name, $namespace, $reason, $error_time).
        send_slack_notification "$pod_name" "$namespace" "$reason" "$error_time"

# fi is the closing statement for an if block in a Bash script.

    fi

# done is used to close a while or for loop in Bash.
# It marks the end of the loop's body and signifies that the loop should stop when the conditions are no longer met.
# But since we used the --watch flag in the kubectl command, the script will run until we stop it manually. 

done
