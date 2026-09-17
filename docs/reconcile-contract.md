# kubebuilder - reconcile

## Reconciler

- **Input** - A namespaced object. The controller-runtime doesn't receive the object to avoid working on an outdated object.
The work of the reconciler is to converge to the desired state. Receiving an outdated state might override the real data and worse
introduce new workload that was unecessary.
- **Idempotency** - In our case, the controller is creating a namespace, deployment, pod and ingress. In case of non-idempotency,
Reruning the reconciler would fail due to collision on already existing objects. The reconciler on all sync should be able to produce the same output which is the desired state. If the desired state is already present, it should not end in failure and just proceed with the next task/object in the queue.
- **Level-triggered vs edge-triggered** The reconciler gets handed an object at its current state and not its transition. This works well with idempotency as the reconciler always runs against the up to date value instead of watching a series of transition and trying to converge the desired state through each one while the object could be staled long ago, unecessary workload
