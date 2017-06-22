<!--
{
  "title": "Android Platform",
  "date": "2017-05-18T12:28:03+09:00",
  "category": "",
  "tags": ["android"],
  "draft": true
}
-->


# Summery

- IPC architecture (servicemanager, Binder, in-kernel driver)
- Userspace bootstrap (PID1, Zygote, SystemServer)
- platform build system
  - depot_tools (python 2 required)
- application build system
  - sdklib.jar
  - gradle outpus e.g. build/intermidiates/classes, manifest
- logging/debugging infrastructure (platform, application)
- adb, shell implementation
  - adb root
  - am, pm commands
  - am start -W net.hiogawa.androidstarter/.MainActivity
- lifecycle of
  - package (pm)
  - process (am)
  - components
  - activity (am)
  - view (drawing)


# AOSP source structure

Android source arthicture and build artifacts:

```
- system/core/
  - init/            (android PID1)
  - rootdir/         (PID1 config files)
    - init.rc, init.zygote64.rc
- frameworks/base/
  - core/
    - android/...        (application library e.g. android.app.Activity)
    - com/android/...    (internal libraries e.g. com.android.internal.os.ZygoteInit)
  - services/
    - java/com/android/server/SystemServer.java (SystemServer)
    - core/java/com/android/server/...          (ActivityManagerService, WindowManagerService, ...)
  - cmds/
    - app_process/
    - am/
    - pm/
    - ...
- frameworks/native/
  - opengl/, libs/binder (C part of SDK ?)
  - services/...         (surfaceflinger, ...)
  - cmds/
    - cmd/               (shell tool cmd)
    - servicemanager/    (the king of binder ?)
- prebuilts/
  - android-emulator/
  - qemu-kernel/
```


# Userspace bootstrap

```
# Give adb root
$ adb root

# Filter out kernel thread and format
$ adb shell ps | awk '$3!=2' | awk '{ printf "%-20s%-10s%-10s%-10s\n", $1, $2, $3, $9 }'
USER                PID       PPID                
root                1         0         /init                         <= PID1
root                2         0         kthreadd  
root                917       1         /sbin/ueventd
logd                1244      1         /system/bin/logd
root                1252      1         /system/bin/debuggerd
root                1253      1         /system/bin/debuggerd64
root                1254      1         /system/bin/vold
root                1256      1252      debuggerd:signaller
root                1257      1253      debuggerd64:signaller
root                1292      1         /sbin/healthd
root                1295      1         /system/bin/lmkd
system              1296      1         /system/bin/servicemanager    <= servicemanager
system              1297      1         /system/bin/surfaceflinger
shell               1301      1         /system/bin/sh                <= shell
root                1350      1         zygote64                      <= zygote
root                1351      1         zygote    
audioserver         1352      1         /system/bin/audioserver
cameraserver        1353      1         /system/bin/cameraserver
drm                 1354      1         /system/bin/drmserver
root                1355      1         /system/bin/installd
keystore            1356      1         /system/bin/keystore
mediacodec          1357      1         media.codec
media               1358      1         /system/bin/mediadrmserver
mediaex             1359      1         media.extractor
media               1360      1         /system/bin/mediaserver
root                1361      1         /system/bin/netd
radio               1362      1         /system/bin/rild
system              1364      1         /system/bin/fingerprintd
system              1365      1         /system/bin/gatekeeperd
root                1369      1         /system/xbin/perfprofd
system              1590      1350      system_server                 <= SystemServer
u0_a52              1660      1350      com.android.inputmethod.latin
u0_a26              1665      1350      com.android.systemui
media_rw            1671      1254      /system/bin/sdcard
radio               1800      1350      com.android.phone
system              1815      1350      com.android.settings
u0_a14              2000      1350      com.google.android.ext.services
u0_a10              2026      1350      android.process.media
u0_a13              2034      1350      com.google.android.gms.persistent
u0_a27              2065      1351      com.google.android.googlequicksearchbox:interactor
u0_a19              2098      1350      com.android.launcher3
u0_a13              2167      1350      com.google.process.gapps
u0_a27              2182      1351      com.google.android.googlequicksearchbox:search
u0_a57              2202      1350      com.google.android.music:main
u0_a13              2329      1350      com.google.android.gms
u0_a2               2384      1350      com.android.providers.calendar
u0_a32              2523      1350      com.google.android.calendar
u0_a64              2605      1350      com.google.android.gm
u0_a13              2667      1350      com.google.android.gms.unstable
u0_a13              2707      1350      com.google.android.gms.ui
u0_a51              2845      1351      com.google.android.talk
root                2866      1         /sbin/adbd                        <= root adbd
u0_a69              2918      1350      com.google.android.youtube
u0_a51              3081      1351      com.google.android.talk:matchstick
u0_a65              3142      1350      com.android.printspooler
u0_a1               3619      1350      android.process.acore
u0_a70              3666      1350      net.hiogawa.androidstarter        <= My test app
root                3686      2866      ps        
```


- servicemanager.rc (/system/bin/servicemanager)

```
TODO
```


- init.zygote64.rc (/system/bin/app_process64 -Xzygote /system/bin --zygote --start-system-server)

```
(app_main.c)
- main =>
  - AppRuntime runtime (where AppRuntime < AndroidRuntime)
  - AndroidRuntime::start("com.android.internal.os.ZygoteInit" ..) =>
    - JniInvocation::init => ?
    - startVm
    - AppRuntime::onVmCreated
    - jclass startClass = env->FindClass
    - env->GetStaticMethodID(startClass, "main" ..)
    - env->CallStaticVoidMethod(startClass, startMeth ..) => (GO TO ZygoteInit.main)

(ZygoteInit.java)
- ZygoteInit.main =>
  - new ZygoteServer
  - ZygoteServer.registerServerSocket =>
    - new FileDescriptor
    - new LocalServerSocket
  - startSystemServer =>
    - String args[] = { ..., "com.android.server.SystemServer" }
    - new ZygoteConnection.Arguments
    - pid = Zygote.forkSystemServer => (cpp) nativeForkSystemServer
    - (for pid == 0 (i.e. for child))
      - handleSystemServerProcess =>
        - ZygoteInit.zygoteInit => RuntimeInit.applicationInit => invokeStaticMain
  - ZygoteServer.runSelectLoop => ?
```


- com.android.server.SystemServer

```
[ Data structure (App) ]
ActivityThread
'-' ApplicationThread (< ApplicationThreadNative < Binder, IApplicationThread)
'-' Looper

LoadedApk
'-' ApplicationInfo
'-* ActivityInfo
'-* ServiceInfo

Intent
'-' String mAction;
'-' Uri mData;
'-' String mType;
'-' String mPackage;
'-' Bundle mExtras;


[ Data structure (system service) ]
ActivityManagerService::Lifecycle (< SystemService)
'-' ActivityManagerService

ActivityManagerService (< ActivityManagerNative < Binder)
'-' SystemServiceManager
'-' ProcessRecord mHomeProcess
'-' ActivityThread mSystemThread
'-' WindowManagerService
'-' UiHandler (e.g. handles SHOW_NOT_RESPONDING_UI_MSG)
'-' MainHandler
'-' Handler mBgHandler

ServiceManagerProxy < IServiceManager
'-' BpBinder (cpp) < IBinder, < IServiceManager


[ Data structure (around IPC) ]
Binder < IBinder
BpBinder < IBinder
ProcessState
IPCThreadState

- SystemServer.main =>
  - new SystemServer
  - SystemServer.run =>
    - Looper.prepareMainLooper
    - createSystemContext =>
      - ActivityThread.systemMain =>
        - new ActivityThread
        - ActivityThread.attach (different path from normal app) =>
          - ActivityThread.getSystemContext =>
            - ContextImpl.createSystemContext =>
              - new LoadedApk
              - new ContextImpl
          - ContextImpl context = ContextImpl.createAppContext => new ContextImpl
          - context.mPackageInfo.makeApplication => newApplication ...
          - Application.onCreate => ?
    - System.loadLibrary("android_servers") (see base/services/Android.mk) =>
      - JNI_OnLoad =>
        - register_android_server_ActivityManagerService
        - ... ?
    - new SystemServiceManager
    - LocalServices.addService(SystemServiceManager.class ...)
    - startBootstrapServices =>
      - SystemServiceManager.startService(Installer.class) => ?
      - SystemServiceManager.startService(ActivityManagerService.Lifecycle.class) =>
        - (some reflection e.g. Class.forName and Class.getConstructor)
          new ActivityManagerService::Lifecycle =>
          - new ActivityManagerService(context) =>
            - new ServiceThread and start
            - new MainHandler
            - new UiHandler
            - new IntentFirewall
            - new ActivityStackSupervisor
            - new ActivityStarter
            - ...
        - ActivityManagerService::Lifecycle.onStart =>
          - ActivityManagerService.start =>
            - LocalServices.addService(ActivityManagerInternal.class, new LocalService())
      - ActivityManagerService.setSystemServiceManager
      - SystemServiceManager.startService(DisplayManagerService.class) => ?
      - PackageManagerService.main => ?
      - SystemServiceManager.startService(UserManagerService.LifeCycle.class) => ?
      - ActivityManagerService.setSystemProcess =>
        - ServiceManager.addService(Context.ACTIVITY_SERVICE (= "activity") ..) =>
          - (initialize central Binder and a lot more happens ...)
        - ...
    - startCoreServices => BatteryService, UsageStatsService, ...
    - startOtherServices =>
      - WindowManagerService.main => ?
      - ServiceManager.addService(Context.WINDOW_SERVICE, wm)
      - ActivityManagerService.setWindowManager
      - DisplayManagerService.windowManagerAndInputReady => ?
      - WindowManagerService.displayReady => ?
      - SystemServiceManager.startService(MOUNT_SERVICE_CLASS)
      - new StatusBarManagerService
      - .. and much more services (e.g. telephony, wifi, ...)
      - SystemServiceManager.startBootPhase(SystemService.PHASE_LOCK_SETTINGS_READY)
      - SystemServiceManager.startBootPhase(SystemService.PHASE_SYSTEM_SERVICES_READY)
      - WindowManagerService.systemReady => ?
      - DisplayManagerService.systemReady => ?
      - ActivityManagerService.systemReady => ?
    - Looper.loop => ...
```


# ActivityManagerService

```
$ am start com.example.android/.MainActivity

- main => run => onRun =>
  - onRun
  - ComponentName.unflattenFromString("com.example.android/.MainActivity") =>
    - ComponentName("com.example.android", "com.example.android.MainActivity")
```


# User application

```
[ Application main code path ]
(am start -W net.hiogawa.androidstarter/.MainActivity)

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
              - javaObjectForIBinder => ??
          - ServiceManagerNative.asInterface =>
            - BpBinder.queryLocalInterface ?? or
            - new ServiceManagerProxy => mRemote = (BpBinder)
        - ServiceManagerProxy.getService("activity") =>
          - mRemote.transact(GET_SERVICE_TRANSACTION, ..) (TODO: what is "activity" remote process ?)=>
            - (cpp) BpBinder.transact =>
              - IPCThreadState::transact =>
                - writeTransactionData => ...
                - waitForResponse =>
                  - while(1) talkWithDriver =>
                    - do while ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr)
      - IActivityManager am = asInterface(b) => new ActivityManagerProxy(b) => mRemote = b
    - ActivityManagerProxy.attachApplication =>
      - mRemote.transact(ATTACH_APPLICATION_TRANSACTION, ..) => (IPC ?) =>
        - ActivityManagerNative.onTransact (case ATTACH_APPLICATION_TRANSACTION) =>
          - ActivityManagerService.attachApplication => attachApplicationLocked(IApplicationThread thread, int pid) =>
            - ProcessRecord app = mPidsSelfLocked.get(pid)
            - ProcessRecord.makeActive =>
              - baseProcessTracker = ProcessStatsService.getProcessStateLocked =>
                - ProcessStats.getProcessStateLocked => ?? ProcessState ..?
              - baseProcessTracker.makeActive => ?
            - updateProcessForegroundLocked ?
            - thread.bindApplication => (IPC ?) => ApplicationThread.bindApplication
              - mRemote.transact(BIND_APPLICATION_TRANSACTION, )
            - mStackSupervisor.attachApplicationLocked => ?
            - mServices.attachApplicationLocked => ?
  - Looper.loop =>
    - for (;;)
      - Message msg = queue.next
      - msg.target.dispatchMessage => ...
```
