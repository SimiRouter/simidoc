# Usage and audit log permissions

This guide explains role-based visibility in Usage Logs and Audit Logs, and how to identify the channel that actually handled a request.

## Usage Logs

### Super administrators

Super administrators can view complete logs for all users. In [Usage Logs](https://api.dwchainless.com/usage-logs/common), choose **Only Errors** in the type filter to show error calls from every user. The filter keeps errors that occurred during retries, even when the final request succeeded.

The channel column identifies the channel that actually handled the request. When investigating routing, use the actual channel, model, status, and request ID in the log rather than relying only on the model name shown by the client.

### Administrators

Administrators can view only their own request, recharge, management-operation, and error-call logs. Username, role, and URL parameters cannot expand this scope. Administrators do not get a global **Only Errors** filter, but their own error records remain visible according to their permissions.

### Regular users

Regular users can view only their own request, recharge, and administrator-operation logs. They cannot view error logs or another user's logs.

## Audit Logs

Super administrators can view audit events for all users and filter by username. Administrators and regular users are restricted to audit events belonging to the currently authenticated account; page parameters cannot expand this server-side scope.

## Channel status updates

The audit event `channel.status_update` means **channel status update**. It records a manual status operation on one channel. The current code accepts an enabled or manually disabled target status; `changed=false` means the request succeeded but the channel state did not change. Batch operations use `channel.status_update_batch`. Check the event details, operator, and timestamp for the specific operation.

## Troubleshooting

1. Confirm the time range and request ID.
2. For a global error investigation, a super administrator should choose **Only Errors**.
3. Check the actual channel, model, and status instead of relying only on the client label.
4. For timeouts, 5xx responses, or interrupted streams, inspect existing logs and the request ID before retrying to avoid duplicate charges.