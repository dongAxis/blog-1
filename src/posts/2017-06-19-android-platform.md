<!--
{
  "title": "Android Platform",
  "date": "2017-06-19T12:28:03+09:00",
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


# Logging

- ActivityManagerDebugConfig (is this build-time only configuration ?)

```
# - show only system log
# - output long format
# - filter only ActivityManager's log (others are "S"ilent)
$ adb shell logcat -b system -v long ActivityManager:* *:S
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
  - ZygoteServer.runSelectLoop =>
    - peers = new ArrayList<ZygoteConnection>()
    - while (true)
      - Os.poll
      - ZygoteConnection.runOnce =>
        - pid = Zygote.forkAndSpecialize => nativeForkAndSpecialize
        - (for pid == 0)
          - handleChildProc => ZygoteInit.zygoteInit => ...
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

Notes

- Activity stack management
- Activity view transition/animation
- thanks to http://dsas.blog.klab.org/archives/52003951.html#startActivityLocked3

```
[ Data structure ]
ActivityManagerService
'-' ActivityStarter
  '-' ActivityRecord mStartActivity
  '-' ActivityStack mSourceStack, mTargetStack
  '-' ActivityStackSupervisor
    '-' IStatusBarService
    '-' ActivityStack mHomeStack, mFocusedStack
    '-' mXXXActivities (e.g. mStoppingActivities, mFinishingActivities)
    '-' RecentTasks (< ArrayList<TaskRecord>)

TaskRecord
'-' ActivityStack
  '-' mXXXActivity
'-' ArrayList<ActivityRecord>
  '-* ActivityRecord
    '-' ActivityInfo
    '-' Intent
    '-' ActivityRecord (resultTo)
    '-' ProcessRecord (hosting process)


[ Starting activity from shell]
("am start net.hiogawa.androidstarter/.MainActivity")
- Am.main => new Am, Am.run => onRun =>
  - mAm = ActivityManagerNative.getDefault
  - mPm = IPackageManager.Stub.asInterface(ServiceManager.getService("package"))
  - runStart =>
    - makeIntent => Intent.parseCommandArgs =>
      - new Intent
      - ComponentName.unflattenFromString("com.example.android/.MainActivity") =>
        - ComponentName("com.example.android", "com.example.android.MainActivity")
      - Intent.setComponent
    - (if intent is not explicit one (i.e. Intent.getComponent is null), which is not the current case)
      - IPackageManager.queryIntentActivities ...
    - IActivityManager.startActivityAsUser => (IPC to SystemServer ...)

- ActivityManagerService.startActivityAsUser =>
  - ActivityStarter.startActivityMayWait =>
    - ActivityInfo aInfo = mSupervisor.resolveActivity
    - startActivityLocked =>
      - .. bunch of checking (e.g. ActivityStackSupervisor.checkStartAnyActivityPermission) ..
      - r = new ActivityRecord(..)
      - startActivityUnchecked (with doResume = true) =>
        - setInitialState =>
          - mStartActivity = r
          - mDoResume = doResume
        - setTaskToCurrentTopOrCreateNewTask ? =>
          - mTargetStack = computeStackFocus
        - ActivityStack.startActivityLocked =>
          - TaskRecord.addActivityToTop
          - TaskRecord.setFrontOfTask
          - ProcessRecord proc = r.app
          - (if proc == null) showStartingIcon = true
          - WindowManagerService.prepareAppTransition => ?
          - ActivityRecord.showStartingWindow =>
            - WindowManagerService.setAppStartingWindow => ?
        - ActivityManagerService.setFocusedActivityLocked => ...
        - ActivityStackSupervisor.resumeFocusedStackTopActivityLocked =>
          - ActivityStack.resumeTopActivityUncheckedLocked =>
            - resumeTopActivityInnerLocked(prev ..) =>
              - ActivityRecord next = topRunningActivityLocked
              - (TODO: huge code, I wanna see all with ActivityManagerDebugConfig turned on ...)
              - if next.app == null (i.e. there's no activity hosting this activity)
                - ActivityStackSupervisor.startSpecificActivityLocked =>
                  - ProcessRecord app = newProcessRecordLocked
                  - startSpecificActivityLocked =>
                    - ActivityManagerService.startProcessLocked(ProcessRecord app ..) =>
                      - isActivityProcess = (entryPoint == null)
                      - entryPoint = "android.app.ActivityThread"
                      - startResult = Process.start(entryPoint ..) =>
                        - ZygoteProcess.start => startViaZygote =>
                          - zygoteSendArgsAndGetResult => (IPC with Zygote process, SEE ABOVE)
                      - mPidsSelfLocked.put(startResult.pid, app)
```


# User application

- lifecycle
  - [x] package
  - [x] process
  - threads
  - components
  - [x] activity
  - view

```
[ Data structure ]
ActivityThread, Window (PhoneWindow), ViewRootImpl, ...TODO
Activity

[ process initialization ]

- ActivityThread.main (SEE ABOVE for this entry from ActivityManagerService) =>
  - Looper.prepareMainLooper =>
    - prepare => sThreadLocal.set(new Looper)
    - sMainLooper = myLooper
  - new ActivityThread =>
    - ((non-static init))
    - mAppThread = new ApplicationThread() =>
      - ApplicationThreadNative => Binder.attachInterface(this, "android.app.IApplicationThread")
    - mLooper = Looper.myLooper()
    - mH = new H (< Handler) =>
      - mLooper = Looper.myLooper
      - mQueue = mLooper.mQueue
      - mAsynchronous = false
  - ActivityThread.attach(false) (false means non system server process) =>
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
          - mRemote.transact(GET_SERVICE_TRANSACTION, ..) =>
            - (cpp) BpBinder.transact =>
              - IPCThreadState::transact =>
                - writeTransactionData => ...
                - waitForResponse =>
                  - while(1) talkWithDriver =>
                    - do while ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr)
      - IActivityManager am = asInterface(b) => new ActivityManagerProxy(b) => mRemote = b
    - ActivityManagerProxy.attachApplication =>
      - mRemote.transact(ATTACH_APPLICATION_TRANSACTION, ..) => ((IPC to service)) =>
        - ActivityManagerNative.onTransact (case ATTACH_APPLICATION_TRANSACTION) =>
          - ActivityManagerService.attachApplication => attachApplicationLocked(IApplicationThread thread, int pid) =>
            - ProcessRecord app = mPidsSelfLocked.get(pid)
            - ProcessRecord.makeActive => ...
            - thread.bindApplication => ((IPC to app)) =>
              - ApplicationThread.bindApplication(processName, appInfo, .. instrumentationName ..) =>
                - new AppBindData
                - data.processName = processName
                - data.appInfo = appInfo
                - data.instrumentationName = instrumentationName
                - Handler.sendMessage(H.BIND_APPLICATION ..) =>
                  - (another thread ?) H.handleMessage => handleBindApplication =>
                    - data.info (LoadedApk) = getPackageInfoNoCheck
                    - appContext = ContextImpl.createAppContext(this ..) => ?
                    - Application app = LoadedApk.makeApplication =>
                      - Instrumentation.newApplication =>
                        - Class.newInstance => new android.app.Application
                        - Application.attach => ContextWrapper.attachBaseContext
                    - Instrumentation.callApplicationOnCreate => Application.onCreate
            - ActivityStackSupervisor.attachApplicationLocked(app) =>
              - ActivityRecord hr = ..
              - realStartActivityLocked(hr, app ..) =>
                - r.app = app
                - app.activities.add(r)
                - app.thread.scheduleLaunchActivity(new Intent(r.intent) ..) => ((IPC to app)) =>
                  - scheduleLaunchActivity =>
                    - r = new ActivityClientRecord
                    - sendMessage(H.LAUNCH_ACTIVITY, r) => handleLaunchActivity => (SEE BELOW Activity lifecycle)
            - ActiveServices.attachApplicationLocked => ..
  - Looper.loop =>
    - for (;;)
      - Message msg = queue.next
      - msg.target.dispatchMessage =>
        - (Actually above main thread handler is called here ?)
```


- Activity lifecycle

```
- handleLaunchActivity =>
  - Activity a = performLaunchActivity =>
    - ComponentName component = Intent.getComponent
    - Instrumentation.newActivity =>
      - Class.newInstance => new new.hiogawa.androidstarter.MainActivity
    - Activity.attach =>
      - mWindow = new PhoneWindow (< Window)
      - mUiThread = Thread.currentThread
      - mWindow.setWindowManager => ..
      - mWindowManager = mWindow.getWindowManager
    - Instrumentation.callActivityOnCreate =>
      - Activity.performCreate =>
        - MainActivity.onCreate =>
          - (application code for example)
          - super.onCreate => .. mCalled = true
          - Activity.setContentView => (SEE BELOW for view detail)
        - performCreateCommon =>
          - ActivityTransitionState.setEnterActivityOptions
    - r.activity = activity
  - handleResumeActivity =>
    - performResumeActivity => .. Activity.onResume
    - View decor = r.window.getDecorView
    - ViewManager wm = a.getWindowManager
    - wm.addView(decor) => WindowManagerImpl.addView => WindowManagerGlobal.addView =>
      - root = new ViewRootImpl =>
        - (non-static init)
          - mTraversalRunnable = new TraversalRunnable
          - mHandler = new ViewRootHandler
        - mWindowSession = WindowManagerGlobal.getWindowSession
        - mAttachInfo = new View.AttachInfo(.. mHandler)
        - mChoreographer = Choreographer.getInstance
        - mDisplayManager = (DisplayManager)context.getSystemService(Context.DISPLAY_SERVICE)
        - ...
      - root.setView =>
        - mDisplayManager.registerDisplayListener(mDisplayListener, mHandler) ?
        - enableHardwareAcceleration => mAttachInfo.mHardwareRenderer = ThreadedRenderer.create =>
          - new ThreadedRenderer =>
            - long rootNodePtr = nCreateRootRenderNode => ?
            - mRootNode = RenderNode.adopt
            - mNativeProxy = nCreateProxy => ?
            - ProcessInitializer.sInstance.init => ?
        - requestLayout => scheduleTraversals =>
          - mChoreographer.postCallback(Choreographer.CALLBACK_TRAVERSAL, mTraversalRunnable ..) =>
            - postCallbackDelayed => postCallbackDelayedInternal =>
              - mCallbackQueues[callbackType].addCallbackLocked
              - scheduleFrameLocked => scheduleVsyncLocked =>
                - FrameDisplayEventReceiver.scheduleVsync (< DisplayEventReceiver) => nativeScheduleVsync ...
        - mInputChannel = new InputChannel
        - mWindowSession.addToDisplay => (IPC ?)
        - mInputEventReceiver = new WindowInputEventReceiver(mInputChannel, ..)
```


- View lifecycle
  - https://developer.android.com/topic/performance/rendering/profile-gpu.html#sam
  - https://developer.android.com/training/material/animations.html#Touch
  - https://developer.android.com/training/transitions/overview.html
  - https://skia.org/
  - input hit testing and callback (or scheduling)
    - input is not passed from ActivityManagerService ?
    - inputflinger, InputManagerService, WindowManagerService ?
  - View.onLayout, View.onDraw (follow TextView for example (harfbuzz, freetype backend ?))
  - what's the cpu work for skia gpu backend mode ?
    - mask bits creation from path or glyph is cpu work
    - how about translation, rotate ?
      - I think these transformation too since these transformation affects mask creation and at least anti aliasing
      - but, actually we're doing those kinds of animation on GPU, aren't we ?
    - all SkPaint effects can be on GPU (maybe not for crazy path filter)
  - renderer, drawable setup ?

```
[ Data structure ]
ViewRootImpl
'-' AttachInfo
  '-' ThreadedRenderer (mHardwareRenderer)
'-' Surface (this has some deal with ThreadedRenderer's existence ?)
'-' IWindowSession


[ Procedure ]
- Activity.setContentView =>
  - PhoneWindow.setContentView =>
    - installDecor =>
      - mDecor = generateDecor =>
        - new DecorContext =>
        - new DecorView => FrameLayout => ViewGroup => View =>
          - ...
          - mRenderNode = RenderNode.create => new RenderNode =>
            - mNativeRenderNode = nCreate => (cpp) android_view_RenderNode_create =>
              - new RenderNode (Skia wrapper ?)
      - mContentParent = generateLayout =>
        - ..
      - mXXXTransition = ... (e.g. mEnterTransition)
    - (forget FEATURE_CONTENT_TRANSITIONS for now)
    - mContentParent.addView (i.e. ViewGroup.addView) =>
      - requestLayout (View.requestLayout) =>
        - ViewRootImpl.requestLayoutDuringLayout => mLayoutRequesters.add(view)
        - AttachInfo.mViewRequestingLayout = this
      - invalidate => invalidateInternal => .. propagate damage to parent
      - addViewInner =>
        - mTransition.addChild
        - child.assignParent
        - ..

- DisplayEventReceiver.dispatchVsync (from cpp, different thread for this event receiver ?) =>
  - FrameDisplayEventReceiver.onVsync =>
    - FrameHandler.sendMessage ..
      - Choreographer.doFrame =>
        - doCallbacks(Choreographer.CALLBACK_INPUT, frameTimeNanos) => ?
        - doCallbacks(Choreographer.CALLBACK_ANIMATION, frameTimeNanos) => ?
        - doCallbacks(Choreographer.CALLBACK_TRAVERSAL, frameTimeNanos) =>
          - mCallbackQueues[callbackType].extractDueCallbacksLocked
          - ViewRootImpl.TraversalRunnable.run (this is queued from ViewRootImpl.scheduleTraversals) =>
            - doTraversal => performTraversals =>
              - measureHierarchy ? (this could call performMeasure ?)
              - relayoutWindow => IWindowSession.relayout => ?
              - mAttachInfo.mHardwareRenderer.initialize(mSurface) => ?
              - mSurface.allocateBuffers => ?
              - mAttachInfo.mHardwareRenderer.setup (ThreadedRenderer.setup) => ?
              - performMeasure => mView.measure (i.e. DecorView.measure) => View.measure =>
                - DecorView.onMeasure => FrameLayout.onMeasure (as super) =>
                  - View.setMeasuredDimension => ...
                  - for children, child.measure ... (recursively) (SEE BELOW for TextView's example, which is leaf case)
              - performLayout =>
                - DecorView.layout (as View.layout) => DecorView.onLayout => FrameLayout.onLayout (as super) => child.layout ...
                - (there could be mLayoutRequesters and go to DecorView.layout again, but doing something smart here)
              - mAttachInfo.mTreeObserver.dispatchOnPreDraw (for example TextView register this callback)
              - performDraw =>
                - draw =>
                  - scrollToRectOrFocus => ...
                  - mAttachInfo.mHardwareRenderer.draw(mView, mAttachInfo, this) (as ThreadedRenderer.draw) =>
                    - updateRootDisplayList(view) =>
                      - updateViewTreeDisplayList => view.updateDisplayListIfDirty =>
                        - DisplayListCanvas canvas = renderNode.start(width, height) => ...
                        - (if layerType == LAYER_TYPE_SOFTWARE) canvas.drawBitmap ...
                        - (otherwise) draw(canvas) =>
                          - onDraw (as DecorView.onDraw) => ...
                          - dispatchDraw (as ViewGroup.dispatchDraw) =>
                            - for each mChildren (View[]), drawChild(canvas, child ..) => child.draw(canvas) (recursively ..)
                          - onDrawForeground =>
                            - onDrawScrollIndicators =>
                            - onDrawScrollBars =>
                            - foreground.draw => ...
                      - DisplayListCanvas canvas = mRootNode.start
                      - canvas.drawRenderNode => ?
                    - nSyncAndDrawFrame => (cpp) ?
        - doCallbacks(Choreographer.CALLBACK_COMMIT, frameTimeNanos) => ? (is this custom animation specific concept ?)
```


- Example: TextView

```
[ Data structure ]
View
'-' RenderNode
'-' ForegroundInfo
  '-' Drawable
'-' Context
'-' ListenerInfo
  '-' OnClickListener
  '-' OnLongClickListener
  '-' ...
'-' mMeasuredWidth, mMeasuredHeight (measure pass's result)
'-' mLeft, mRight, mTop, ... (layout pass's result)


TextView < View
'-' mTextColor, mHintTextColor (additional styles)
'-' Drawables
  '-' Drawable[4]
'-' text.Layout
'-' CharSequence (mHint)
'-' TextPaint
'-' Editor


[ Procedure ]
- TextView.onMeasure() =>
  -

- TextView.onLayout()

- TextView.onDraw =>
  -
```
