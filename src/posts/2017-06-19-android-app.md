<!--
{
  "title": "Android Application",
  "date": "2017-05-18T12:28:03+09:00",
  "category": "",
  "tags": ["android"],
  "draft": true
}
-->


# TODO

- Application process main function
  - ActivityThread
  - follow Zygote steps (ZygoteConnection.Arguments)
- IPC architecture (Binder)
- WindowManager, SurfaceFlinger


```
[ Data structure (App) ]
ActivityThread
'-' ApplicationThread (< ApplicationThreadNative < Binder, IApplicationThread)
'-' Looper

[ Data structure (system service) ]
ActivityManagerService (< ActivityManagerNative < Binder)

ServiceManagerProxy < IServiceManager
'-' ServiceManagerNative (as mRemote) (< Binder < IBinder, < IServiceManager)

[ Data structure (around IPC) ]
Binder < IBinder
BpBinder < IBinder
ProcessState
IPCThreadState


[ Code path ]
- ((static init ?))
- ActivityThread.main =>
  - Looper.prepareMainLooper =>
    - prepare => sThreadLocal.set(new Looper)
    - sMainLooper = myLooper
  - new ActivityThread =>
    - ((non-static init))
    - mAppThread = new ApplicationThread() =>
      - ApplicationThreadNative => Binder.attachInterface(this, "android.app.IApplicationThread")
    - mLooper = Looper.myLooper()
  - ActivityThread.attach(false) =>
    - RuntimeInit.setApplicationObject(mAppThread.asBinder())
    - ActivityManagerNative.getDefault => Singleton<IActivityManager>.get => create =>
      - IBinder b = ServiceManager.getService("activity") =>
        - getIServiceManager =>
          - BinderInternal.getContextObject =>
            - (cpp) android_os_BinderInternal_getContextObject =>
              - ProcessState::self => new ProcessState =>
                - open_driver => open("/dev/binder" ..) and mmap
              - ProcessState::getContextObject =>
                - getStrongProxyForHandle => new BpBinder (as IBinder)
          - ServiceManagerNative.asInterface =>
            - new ServiceManagerProxy => mRemote = (BpBinder)
        - ServiceManagerProxy.getService("activity") =>
          - mRemote.transact(GET_SERVICE_TRANSACTION, ..) (TODO: what do we get here ?)=>
            - (cpp) BpBinder.transact =>
              - IPCThreadState::transact =>
                - writeTransactionData => ...
                - waitForResponse =>
                  - while(1) talkWithDriver =>
                    - do while ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr)
      - IActivityManager am = asInterface(b) => new ActivityManagerProxy(b) => mRemote = b
    - ActivityManagerProxy.attachApplication =>
      - mRemote.transact(ATTACH_APPLICATION_TRANSACTION, ..) => (IPC serialization ? when/how ?) =>
        - ActivityManagerNative.onTransact (case ATTACH_APPLICATION_TRANSACTION) =>
          - ActivityManagerService.attachApplication => attachApplicationLocked(IApplicationThread thread, int pid) =>
            - ProcessRecord app = mPidsSelfLocked.get(pid)
            - ProcessRecord.makeActive =>
              - baseProcessTracker = tracker.getProcessStateLocked
              - baseProcessTracker.makeActive => ?
            - updateProcessForegroundLocked ?
            - thread.bindApplication => ?
            - mStackSupervisor.attachApplicationLocked => ?
            - mServices.attachApplicationLocked => ?
  - Looper.loop =>
    - for (;;)
      - Message msg = queue.next
      - msg.target.dispatchMessage => ...
```
