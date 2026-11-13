/// Consumer-owned operation state; no work or timers are owned by the button.
enum MorphOperationState { idle, loading, success, error }

/// Width policy during an operation.
enum MorphOperationPresentation { preserveWidth, compact }
